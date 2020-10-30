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