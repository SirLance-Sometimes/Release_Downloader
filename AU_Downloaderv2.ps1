[Cmdletbinding()]
param()
$logfile = "repo_download.log"
$StartTime = get-date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Start-Transcript -Path $logfile -Append -NoClobber
Write-Information "$StartTime Script started"
$ProgressPreference = 'SilentlyContinue'
function get-imports {
    Import-Module .\publish-config
    Import-Module .\get-confiugration
    Import-Module .\update-config

    Import-Module .\get-repoData
    
}
function main {
    get-imports
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



main
Write-Information $DebugPreference
$EndTime = Get-Date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Write-information "$EndTime Script finished"
#$TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
#Write-information "Script runtime was $($TimeSpan.Hours) hours, $($TimeSpan.Minutes) minutes, $($TimeSpan.Seconds) seconds."
Stop-Transcript