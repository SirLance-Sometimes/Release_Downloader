[Cmdletbinding()]
param()
$logfile = "repo_download.log"
$StartTime = get-date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Start-Transcript -Path $logfile -Append -NoClobber
Write-Information "$StartTime Script started"
$ProgressPreference = 'SilentlyContinue'

. .\src\publish-config.ps1
. .\src\get-configuration.ps1
. .\src\edit-config.ps1
. .\src\edit-repoItem.ps1
. .\src\get-repoData.ps1
. .\src\get-fileDownload.ps1
. .\src\remove-staleVersion.ps1

function main {
    $config = get-configuration -configPath "parameters.json"
    if ($config -eq 0) {
        exit
    }
    foreach ($repo in $config.items){
        Write-information "checking repo: $($repo.repository)"
        $repoData = get-repoData $repo
        write-debug "Repo files: $($repoData.files)"
        write-debug "Repo data: $($repoData)"
        if ($repoData.version -ne $repo.version ){                           # check if version is different
            Write-Information "$($repo.repository) has been updated"
            remove-staleVersion -folder $repo.folder -cleanupTypes $repo.cleanupTypes
            write-debug "config: $($config)"
            write-debug "config.filters $($config.filters)"
            get-fileDownload -fileList $repoData -folder $repo.folder -exclude $repo.exclude -filters $repo.filters # downloads the files and writes them to disk
            Write-debug "repo version before update: $($repo.version)"
            $repo.version = $repoData.version                                # This will set the value of the repo version to the current version here and in the $config varaible
            Write-Debug "repo version after update: $($repo.version)"
        }
        else {
            Write-Information "$($repo.repository) has not been updated."
        }
    }
    edit-config $config
}



main


Write-Information $DebugPreference
$EndTime = Get-Date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Write-information "$EndTime Script finished"
#$TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
#Write-information "Script runtime was $($TimeSpan.Hours) hours, $($TimeSpan.Minutes) minutes, $($TimeSpan.Seconds) seconds."
Stop-Transcript