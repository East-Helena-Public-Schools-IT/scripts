# Get all the current remote printers
$printers = Get-printer | Where-Object Name -match ehps-print
if ($?) {
    Write-Host $printers
  
    Write-Host Removing printers
    foreach ($printer in $printers) {
        Write-Host Removing $printer.name
        Remove-Printer -Name $printer.Name
    }
    Write-Host Restarting print spooler
    Restart-Service -Name "Spooler"

    Write-Host Re-adding printers
    foreach ($printer in $printers) {
        Write-Host Adding $printer.name
        Add-Printer -ConnectionName $printer.Name
    }
}
Write-Host Done.