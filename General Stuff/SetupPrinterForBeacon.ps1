
# ================================
# Install 5 Printers via IP + Driver
# ================================
# Run as Administrator

# -------- Settings --------
# Path to Lexmark .INF driver
$lexmarkInf = "\\mil-server2k19\NFC_Staging\Printers\DR OFFICE LEXMARK M1342\Drivers\Print\GDI\LMUD1o40.inf"

# Driver names (verify with Get-PrinterDriver after install)
$hpDriver      = "HP Universal Printing PCL 6"
$lexmarkDriver = "Lexmark M1342 Series GDI"   # Update if Get-PrinterDriver shows a slightly different string

# Printer definitions
$printers = @(
    @{IP="10.0.0.220"; Name="HP-FRONT-SMALL"; Driver=$hpDriver},
    @{IP="10.0.0.221"; Name="HP-FRONT-BIG";   Driver=$hpDriver},
    @{IP="10.0.0.222"; Name="LEXMARK-DR";     Driver=$lexmarkDriver},
    @{IP="10.0.0.224"; Name="HP-DANIELLE";    Driver=$hpDriver},
    @{IP="10.0.0.225"; Name="HP-COLOR";       Driver=$hpDriver}
)

# -------- Driver Check & Install --------
Write-Host "Checking for Lexmark driver..."
$lexmarkInstalled = Get-PrinterDriver | Where-Object { $_.Name -like "*Lexmark*" }

if (-not $lexmarkInstalled) {
    Write-Host "Lexmark driver not found. Installing from $lexmarkInf..."
    pnputil /add-driver $lexmarkInf /install | Out-Null
    Write-Host "Lexmark driver installed."
}
else {
    Write-Host "Lexmark driver already installed: $($lexmarkInstalled.Name)"
}

# -------- Printer Setup --------
foreach ($printer in $printers) {
    $portName = "IP_" + $printer.IP
    Write-Host "Processing $($printer.Name) at $($printer.IP)..."

    # Create TCP/IP port if it doesn’t exist
    if (-not (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
        Add-PrinterPort -Name $portName -PrinterHostAddress $printer.IP
        Write-Host "  Added port $portName."
    }
    else {
        Write-Host "  Port $portName already exists."
    }

    # Install the printer if not already present
    if (-not (Get-Printer -Name $printer.Name -ErrorAction SilentlyContinue)) {
        Add-Printer -Name $printer.Name -DriverName $printer.Driver -PortName $portName
        Write-Host "  Installed printer $($printer.Name)."
    }
    else {
        Write-Host "  Printer $($printer.Name) already exists, skipping."
    }
}
