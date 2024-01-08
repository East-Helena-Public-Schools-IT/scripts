# EHPS Scripts
The scripts that we use here at East Helena Public Schools to help improve our efficiency.

## Using these scripts
You can clone the whole repository by doing
```bash
git clone https://github.com/East-Helena-Public-Schools-IT/scripts/tree/main
```
Or if you want just a specific file, go to it in Github then click "raw" on the top left of the text pane. This will give a URL that is just the string representation of the file. Copy that URL into one of the following commands on the target machine.

Powershell (Windows):
```bash
wget {url} -OutFile {name you want to save it as}
```
Bash (Linux / Mac):
```bash
wget {url}
```

Please note that some of the scripts have hard-coded values that are specific to our school district, such as [create-ad-user.ps1](https://github.com/East-Helena-Public-Schools-IT/scripts/blob/main/create-ad-user.ps1). This script has our school's names hard-coded into the script, but it should be trivial to modify it to your needs.
