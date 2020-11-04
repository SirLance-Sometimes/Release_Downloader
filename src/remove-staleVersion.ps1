
function remove-staleVersion {
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
        try{
            Remove-Item "$($path)*.$($cleanupTypes)"
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            write-information "no files found"
        }
    }
}