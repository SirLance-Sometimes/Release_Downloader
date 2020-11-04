function edit-config {
    param (
        [psobject]$config
    )
    write-debug "update-config config.items[0].exclude $($config.items[0].exclude)"
    write-debug "update-config config as json $(ConvertTo-Json $config)"
    ConvertTo-Json $config | out-file -FilePath parameters.json
}