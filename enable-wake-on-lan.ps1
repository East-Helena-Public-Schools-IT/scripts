$PPNuGet = Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq "Nuget" }
if (!$PPNuget) {
    Write-Host "Installing Nuget provider" -foregroundcolor Green
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}
$PSGallery = Get-PSRepository -Name PsGallery
if (!$PSGallery) {
    Write-Host "Installing PSGallery" -foregroundcolor Green
    Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
}
$PsGetVersion = (get-module PowerShellGet).version
if ($PsGetVersion -lt [version]'2.0') {
    Write-Host "Installing latest version of PowerShellGet provider" -foregroundcolor Green
    install-module PowerShellGet -MinimumVersion 2.2 -Force
    Write-Host "Reloading Modules" -foregroundcolor Green
    Remove-Module PowerShellGet -Force
    Remove-module PackageManagement -Force
    Import-Module PowerShellGet -MinimumVersion 2.2 -Force
    Write-Host "Updating PowerShellGet" -foregroundcolor Green
    Install-Module -Name PowerShellGet -MinimumVersion 2.2.3 -force
    write-host "You must rerun the script to succesfully set the WOL status. PowerShellGet was found out of date." -ForegroundColor red
}
Write-Host "Checking Manufacturer" -foregroundcolor Green
$Manufacturer = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
if ($Manufacturer -like "*Dell*") {
    Write-Host "Manufacturer is Dell. Installing Module and trying to enable Wake on LAN." -foregroundcolor Green
    Write-Host "Installing Dell Bios Provider" -foregroundcolor Green
    Install-Module -Name DellBIOSProvider -Force
    import-module DellBIOSProvider
    try {
        set-item -Path "DellSmBios:\PowerManagement\WakeOnLan" -value "LANOnly" -ErrorAction Stop
    } catch { write-host "an error occured. Could not set BIOS to WakeOnLan. Please try setting WOL manually" }
    # TODO: Disable deep sleep
    try {
      set-item -Path "DellSmBios:\PowerManagement\DeepSleepCtrl" -value "Disabled" -ErrorAction Stop 
    } catch { write-host "Couldn't disable deep sleep in the BIOS." }
}
write-host "Setting NIC to enable WOL" -ForegroundColor Green
$NicsWithWake = Get-CimInstance -ClassName "MSPower_DeviceWakeEnable" -Namespace "root/wmi"
foreach ($Nic in $NicsWithWake) {
    write-host "Enabling for NIC" -ForegroundColor green
    Set-CimInstance $NIC -Property @{Enable = $true }
}

Get-NetAdapter -Name *ethernet* | Enable-NetAdapterPowerManagement -WakeOnMagicPacket
# Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Energy-Efficient Ethernet" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Energy Efficient Ethernet" -DisplayValue "Off"
 # TODO: Disable "Turn on fast startup (recommened)"
 # TODO: Disable Fast Boot (maybe)