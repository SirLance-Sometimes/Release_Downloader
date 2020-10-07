$cap_folder = "amonguscapture"
# todo
# validate that the folder exists before using and/or create the folder if it doesn't

$bot_repo = "denverquane/amongusdiscord"
$cap_repo = "denverquane/amonguscapture"

$bot_releases = "https://api.github.com/repos/$bot_repo/releases"
$cap_releases = "https://api.github.com/repos/$cap_repo/releases"

# todo
# wrap the api calls and checks into a function

Write-Host Determining latest release
$bot_data = (Invoke-WebRequest $bot_releases | ConvertFrom-Json)[0]
$cap_data = (Invoke-WebRequest $cap_releases | ConvertFrom-Json)[0]

$bot_download_url = $bot_data.assets.browser_download_url
$cap_download_url = $cap_data.assets.browser_download_url

# todo 
# write the bot_data and cap_data .id value to a variable.  Keep track of these variables in a file.  Compare the two in order to determine if a new file
# even needs to be downloaded to save bandwidth


# todo
# wrap the downloading of the file into a function

$bot_filename = $bot_data.assets.name
$cap_filename = $cap_data.assets.name

$i = 0
foreach ($url in $bot_download_url)
{
    $tempfile = $bot_filename[$i]
    if ($tempfile -ne "final.txt")
    {
        #Write-Host $tempfile
        Invoke-WebRequest $url -OutFile $tempfile
    }
    $i ++
}

$i = 0
foreach ($url in $cap_download_url)
{
    
    $tempfile = $cap_filename[$i]
    Invoke-WebRequest $url -OutFile $tempfile
    Move-Item $tempfile $cap_folder\. -Force
    $i ++
}

