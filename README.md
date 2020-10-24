# AU_Updater

After writting this code, this repo is poorly named.  At some point I may change this to something along the lines of "git releases".

## Purpose and intent

My original objectives were to automate downloading the latest releases of the among us discord bot and among us capture program by denverquane.  In the process of trying to follow good coding practices I ended up with a powershell script/program that can pull any release artifacts and isn't tied specifically to the among us bot repos by denverquane.  The `parameters_template.json` file is targeted at these repositories because that was my intent.  However if you populate that template with any repo your interested in you can use this code to automate downloading the latest release of any repo(s).

## Parameters file

The script uses a parameters file to load the list of repos you wish to check and update.  This file is in json format.

The fields are 

```
{
    "items":  [
                  {
                      "name":  "Human friendly name of the repo, this is for you and doesn't have to match what is in git",
                      "repository":  "repo name, this will be what follow in the url for example: 'SirLance-Sometimes/AU_Updater' would be this repo",
                      "folder":  "this is a target folder you want to put the files in, which can be relative to the script.  This can be left an empty string if you want the files to be saved in the same folder as the script",
                      "version":  0,
                      "exclude": ["This is a list of files that you want to exclude from downloading.  You can leave this list empty if you like."]
                  }
              ]
}

```

The version number should start at 0 before you run the program.  After that the script will update the version as it downloads newer version of code.  This value is used to determine if the files need to be download.