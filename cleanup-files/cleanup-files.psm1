
function cleanup-files {
    param (
        [string]$folder,
        [string]$cleanupTypes
    )
    if($folder -eq ""){
        $path = ""
    }
    else {
        $path = $folder + "\"
    }
    foreach($type in $cleanupTypes){
        Remove-Item "$($path)*.$($cleanupTypes)"
    }
}