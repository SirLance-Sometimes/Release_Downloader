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
    Write-Output "No configuration file was found, a template configuration file was built as parameter.json"
    Write-Output "Populate parameter.json with repo information to use this program"
    Write-Output "Program is exiting, rerun after paramters.json is populated"
    Write-Output "Press enter to exit"
    Pause
    exit
}