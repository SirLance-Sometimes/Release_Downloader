[Cmdletbinding()]
param()
$logfile = "repo_download.log"
$StartTime = get-date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Start-Transcript -Path $logfile -Append -NoClobber
Write-Information "$StartTime Script started"
$ProgressPreference = 'SilentlyContinue'

Import-Module .\publish-config
Import-Module .\get-configuration
Import-Module .\update-config
Import-Module .\parse-repoItems
Import-Module .\get-repoData
Import-Module .\get-fileDownload
Import-Module .\cleanup-files

function main {
    $config = get-configuration -configPath "..\parameters.json"
    foreach ($repo in $config.items){
        Write-information "checking repo: $($repo.repository)"
        $repoData = get-repoData $repo
        write-debug "Repo files: $($repoData.files)"
        write-debug "Repo data: $($repoData)"
        if ($repoData.version -ne $repo.version ){                           # check if version is different
            Write-Information "$($repo.repository) has been updated"
            cleanup-files -folder $repo.folder -cleanupTypes $repo.cleanupTypes
            get-fileDownload -fileList $repoData -folder $repo.folder -exclude $repo.exclude -filters $repo.filters # downloads the files and writes them to disk
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



main

remove-Module publish-config
remove-Module get-configuration
remove-Module update-config
remove-Module parse-repoItems
remove-Module get-repoData
remove-Module get-fileDownload
remove-Module cleanup-files

Write-Information $DebugPreference
$EndTime = Get-Date -Format 'yyyy-mm-dd hh:mm:ss.fff'
Write-information "$EndTime Script finished"
#$TimeSpan = New-TimeSpan -Start $StartTime -End $EndTime
#Write-information "Script runtime was $($TimeSpan.Hours) hours, $($TimeSpan.Minutes) minutes, $($TimeSpan.Seconds) seconds."
Stop-Transcript