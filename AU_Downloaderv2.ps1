function main {
    $config = get-confiugration
    foreach ($repo in $config.items){
        Write-Information "Checking repo: " + $repo.repository
        $repoData = get-repoData $repo
        Write-debug "repo data debug"
        write-debug "Repo files:" + $repoData.files
        write-debug "Repo data:" + $repoData
        if ($repoData.version -ne $repo.version ){                           # check if version is different
            Write-Information $repo.repository + " has been updated."
            get-filedownload -fileList $repoData -folder $repo.folder   # downloads the files and writes them to disk
            Write-debug "repo version before update:" + $repo.version
            $repo.version = $repoData.version                                # This will set the value of the repo version to the current version here and in the $config varaible
            Write-Debug "repo version after update: " + $repo.version
        }
        else {
            Write-Information $repo.repository + " has not been updated."
        }
    }
    update-config $config
}

function get-confiugration {
    try {
        $content = Get-Content parameters.json | ConvertFrom-Json
        Write-Information "Configuration file parameters.json found and loaded"
        return $content
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        # if not found create a new configuration file
        Write-Information "Configuration file not found"
    }
    
}

function get-repoData {
    param(
        [psobject]$repoConfigData
    )
    $repo = $repoConfigData.repository
    $repo_URL = "https://api.github.com/repos/$repo/releases"
    #Write-Host $repo_URL
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
    #write-host "repo full object"
    foreach ($item in $repoItems.assets) {
        #Write-Host "browser url in items"
        #write-host $item.browser_download_url
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
        [string]$folder
    )
    if($folder -eq ""){
        $path = ""
    }
    else {
        $path = $folder + "\"
    }
    foreach($file in $fileList.files){
        #todo This should be a check agaisn't a list from the configuration file, an exclude list.
        if($file.filename -ne "final.txt"){
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
    $config | ConvertTo-Json | out-file -FilePath parameters.json
    
}

main