# Rename an installed printer
$OldPrinterName = "HP-FRONT-SMALL"
$NewPrinterName = "HP-BOATCAPTAIN"

# Check if the old printer exists
$printer = Get-Printer -Name $OldPrinterName -ErrorAction SilentlyContinue

if ($printer) {
    Rename-Printer -Name $OldPrinterName -NewName $NewPrinterName
    Write-Host "Printer renamed from '$OldPrinterName' to '$NewPrinterName'."
} else {
    Write-Host "Printer '$OldPrinterName' not found."
}