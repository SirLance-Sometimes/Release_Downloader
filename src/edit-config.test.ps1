Describe 'edit-config' {
    . ./edit-config.ps1
    Set-Location "TestDrive:\"
    edit-config -config @{items=@(@{name="test1";exclude="test1Exclude"},@{name="test2";exclude="test2Exclude"})}
    It 'writes parameters.json file' {
        "TestDrive:\parameters.json" | Should Exist
    }
    Set-Location $psscriptroot
}