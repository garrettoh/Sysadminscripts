# PowerShell Script to Add 5 Network Printers by IP and Install Drivers
# Run as Administrator

# Define printer driver names (update as needed using Get-PrinterDriver)
$hpDriver      = "HP Universal Printing PCL 6"
$lexmarkDriver = "Lexmark Universal v2"

# Define printers (IP + Name + Driver)
$printers = @(
    @{IP="10.0.0.220"; Name="HP-FRONT-SMALL"; Driver=$hpDriver},
    @{IP="10.0.0.221"; Name="HP-FRONT-BIG";   Driver=$hpDriver},
    @{IP="10.0.0.222"; Name="LEXMARK-DR";     Driver=$lexmarkDriver},
    @{IP="10.0.0.224"; Name="HP-DANIELLE";    Driver=$hpDriver},
    @{IP="10.0.0.225"; Name="HP-COLOR";       Driver=$hpDriver}
)

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

