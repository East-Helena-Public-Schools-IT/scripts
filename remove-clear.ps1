# Stop Clear process
Stop-Process -Name 'Clear'
    
# Remove registery entries
Remove-Item -Path HKCU:\SOFTWARE\Clear -Recurse -Force -Verbose
Remove-Item -Path HKCU:\SOFTWARE\Clear.App -Recurse -Force -Verbose
Remove-Item -Path HKCU:\SOFTWARE\ClearBrowser -Recurse -Force -Verbose
Remove-Item -Path HKCU:\SOFTWARE\ClearBar -Recurse -Force -Verbose

# Remove clear's files
Remove-Item $env:LOCALAPPDATA\Clear -Force -Recurse
Remove-Item $env:LOCALAPPDATA\ClearBrowser -Force -Recurse
Remove-Item $env:LOCALAPPDATA\Programs\Clear -Force -Recurse
Remove-Item $env:LOCALAPPDATA\Temp\clearbrowser_topsites -Force
Remove-Item $env:APPDATA'\Microsoft\Windows\Start Menu\Programs\Clear.lnk'
Remove-Item $HOME\Desktop\Clear.lnk
Remove-Item $HOME\Downloads\*clear*

# Delete tasks
# -Comfirm:$false makes it so it doesn't ask for confirmation to delete each task
Unregister-ScheduledTask -TaskName "ClearStartAtLoginTask" -Confirm:$false
Unregister-ScheduledTask -TaskName "ClearUpdateChecker" -Confirm:$false