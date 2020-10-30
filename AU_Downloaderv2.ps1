[Cmdletbinding()]
param()
$logfile = "repo_download.log"
$StartTime = get-date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Start-Transcript -Path $logfile -Append -NoClobber
Write-Information "$StartTime Script started"
$ProgressPreference = 'SilentlyContinue'
function main {
    $config = get-confiugration
    foreach ($repo in $config.items){
        Write-information "checking repo: $($repo.repository)"
        $repoData = get-repoData $repo
        write-debug "Repo files: $($repoData.files)"
        write-debug "Repo data: $($repoData)"
        if ($repoData.version -ne $repo.version ){                           # check if version is different
            Write-Information "$($repo.repository) has been updated"
            cleanup-files -folder $repo.folder -cleanupTypes $repo.cleanupTypes
            get-filedownload -fileList $repoData -folder $repo.folder -exclude $repo.exclude -filters $repo.filters # downloads the files and writes them to disk
            Write-debug "repo version before update: $($repo.version)"
            $repo.version = $repoData.version                                # This will set the value of the repo version to the current version here and in the $config varaible
            Write-Debug "repo version after update: $($repo.version)"
        }
        else {
            Write-Information "$($repo.repository) has not been updated."
        }
    }
    update-config $config
}

function publish-config {
    $template = @{
        "items" = @(
            @{
                name = "";
                repository = "";
                folder = "";
                version = 0;
                excludeFiles = @()
            }
        )
    }

    $template | ConvertTo-Json | Out-File parameters.json
    Write-Host "No configuration file was found, a template configuration file was built as parameter.json"
    Write-Host "Populate parameter.json with repo information to use this program"
    Write-Host "Program is exiting, rerun after paramters.json is populated"
    Write-Host "Press enter to exit"
    Pause
    exit
}
function get-repoData {
    param(
        [psobject]$repoConfigData
    )
    $repo = $repoConfigData.repository
    $repo_URL = "https://api.github.com/repos/$repo/releases"
    Write-debug "get-repoData repo URL $($repo_URL)"
    try {
        $repoData = (Invoke-WebRequest $repo_URL | ConvertFrom-Json)[0]
    }
    catch [System.Net.WebException]{
        Write-Error "Network issue, repository is not accessible"
    }
    return parse-repoItems -repoItems $repoData
}

function parse-repoItems {
    param(
        [psobject]$repoItems
    )
    $data = New-Object -TypeName psobject
    $data | Add-Member -MemberType NoteProperty -Name "version" -Value $repoItems.id
    $data | Add-Member -MemberType NoteProperty -Name "files" -Value @()
    foreach ($item in $repoItems.assets) {
        Write-Debug "parse-repoItems item.browser_download_url: $($item.browser_download_url)"
        $repoValues = New-Object -TypeName psobject
        $repoValues | Add-Member -MemberType NoteProperty -Name download_url -Value $item.browser_download_url
        $repoValues | Add-Member -MemberType NoteProperty -Name filename -Value $item.name
        $data.files += $repoValues
    }
    return $data
}

function get-filedownload {
    param (
        [psobject]$fileList,
        [string]$folder,
        [string]$exclude,
        [string]$filters
    )
    if($folder -eq ""){
        $path = ""
    }
    else {
        $path = $folder + "\"
    }
    Write-Debug "get-filedownload $fileList.files $($fileList.files)"
    foreach($file in $fileList.files){
        #todo This should be a check agaisn't a list from the configuration file, an exclude list.
        Write-Debug "get-filedownload file.filename $($file.filename)"
        Write-Debug "get-filedownload exclude $($exclude)"
        if( $exclude -notcontains $file.filename -and $file.filename -eq ( $file.filename | Select-String -Pattern $filters ) ){
            $temp_path = $path + $file.filename
            $request = $file.download_url
            Write-Debug "get-filedownload file.download_url $($file.download_url)"
            Invoke-WebRequest $request -OutFile $temp_path
        }
    }
}

function cleanup-files {
    param (
        [string]$folder,
        [string]$cleanupTypes
    )
    if($folder -eq ""){
        $path = ""
    }
    else {
        $path = $folder + "\"
    }
    foreach($type in $cleanupTypes){
        Remove-Item "$($path)*.$($cleanupTypes)"
    }
}

function update-config {
    param (
        [psobject]$config
    )
    write-debug "update-config config.items[0].exclude $($config.items[0].exclude)"
    write-debug "update-config config as json $(ConvertTo-Json $config)"
    ConvertTo-Json $config | out-file -FilePath parameters.json
    
}

main
Write-Information $DebugPreference
$EndTime = Get-Date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Write-information "$EndTime Script finished"
#$TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
#Write-information "Script runtime was $($TimeSpan.Hours) hours, $($TimeSpan.Minutes) minutes, $($TimeSpan.Seconds) seconds."
Stop-Transcript