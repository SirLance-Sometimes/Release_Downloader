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