#requires -Modules parse-repoItems
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