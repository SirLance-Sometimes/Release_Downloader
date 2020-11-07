Describe 'publish-config' {
    . ./src\publish-config.ps1
    Set-Location "TestDrive:\"
    publish-config
    $config = get-content "TestDrive:\parameters.json" | convertfrom-json
    It 'Writes basic parameters.json file' {
        "TestDrive:\parameters.json" | Should Exist
    }
    It 'Should contain an array' {
        $config.items.GetType().BaseType.Name | Should be 'Array'
    }
    It 'Array should contain one item' {
        $config.items.length | Should be 1
    }
    It 'Should contain required keys' {
        # TODO figure out show to check if the keys output contains a specific key
        #'name' | Should -BeIn $config.items[0].keys
        #$config.items[0].keys | Should contain 'name'
        #$config[0].keys | Should contain 'repository'
        #$config[0].keys | Should contain 'folder'
        #$config[0].keys | Should contain 'version'
        #$config[0].keys | Should contain 'excludeFiles'
    }
    It 'Version should be 0' {
        $config.items[0].version | Should be 0
    }
    Set-Location $psscriptroot\..
}