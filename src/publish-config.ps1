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