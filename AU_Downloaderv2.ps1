[Cmdletbinding()]
param()
$logfile = "repo_download.log"
$StartTime = get-date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Start-Transcript -Path $logfile -Append -NoClobber
Write-Information "$StartTime Script started"
function main {
    $config = get-confiugration
    foreach ($repo in $config.items){
        Write-information "checking repo: $($repo.repository)"
        $repoData = get-repoData $repo
        write-debug "Repo files: $($repoData.files)"
        write-debug "Repo data: $($repoData)"
        if ($repoData.version -ne $repo.version ){                           # check if version is different
            Write-Information "$($repo.repository) has been updated"
            get-filedownload -fileList $repoData -folder $repo.folder -exclude $repo.exclude  # downloads the files and writes them to disk
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

function get-confiugration {
    try {
        $content = Get-Content parameters.json -ErrorAction Stop | ConvertFrom-Json
        Write-Information "Configuration file parameters.json found and loaded"
        return $content
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        # if not found create a new configuration file
        Write-Information "Configuration file not found"
        publish-config
    }
    
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
        [string[]]$exclude
    )
    if($folder -eq ""){
        $path = ""
    }
    else {
        $path = $folder + "\"
    }
    foreach($file in $fileList.files){
        #todo This should be a check agaisn't a list from the configuration file, an exclude list.
        #write-host $file.filename
        #write-host $exclude
        if( -not ($exclude -contains $file.filename)){
            $temp_path = $path + $file.filename
            $request = $file.download_url
            #Write-Host $file.download_url
            Invoke-WebRequest $request -OutFile $temp_path
        }
    }
}

function update-config {
    param (
        [psobject]$config
    )
    Move-Item parameters.json parameters.json.back -Force
    #$config.items[0].exclude
    #ConvertTo-Json $config
    $config | ConvertTo-Json | out-file -FilePath parameters.json
    
}

main
Write-Information $DebugPreference
$EndTime = Get-Date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Write-information "$EndTime Script finished"
#$TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
#Write-information "Script runtime was $($TimeSpan.Hours) hours, $($TimeSpan.Minutes) minutes, $($TimeSpan.Seconds) seconds."
Stop-Transcript