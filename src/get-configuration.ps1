
function get-configuration {
    param(
        [string]$configPath
    )
    try {
        $content = Get-Content $configPath -ErrorAction Stop | ConvertFrom-Json
        Write-Information "Configuration file parameters.json found and loaded"
        return $content
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        # if not found create a new configuration file
        Write-Information "Configuration file not found"
        publish-config
        return 0
    }
}