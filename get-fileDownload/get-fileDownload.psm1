function get-fileDownload {
    param (
        [psobject]$fileList,
        [string]$folder,
        [string]$exclude,
        [string]$filters
    )
    if($folder -eq ""){
        $path = ""
    }
    else {
        $path = $folder + "\"
    }
    Write-Debug "get-fileDownload $fileList.files $($fileList.files)"
    foreach($file in $fileList.files){
        #todo This should be a check agaisn't a list from the configuration file, an exclude list.
        Write-Debug "get-fileDownload file.filename $($file.filename)"
        Write-Debug "get-fileDownload exclude $($exclude)"
        # if ($filters -eq ""){
        #     # todo need to do something here?
        # }
        if( $exclude -notcontains $file.filename -and $file.filename -eq ( $file.filename | Select-String -Pattern $filters ) ){
            $temp_path = $path + $file.filename
            $request = $file.download_url
            Write-Debug "get-fileDownload file.download_url $($file.download_url)"
            Invoke-WebRequest $request -OutFile $temp_path
        }
    }
}