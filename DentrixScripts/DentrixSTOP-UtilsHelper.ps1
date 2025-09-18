# Dentrix Maintenance Helper



# /*****************************************************************************************\#
#   Stops Dentrix services & processes, waits for user input, then restarts services        #
#\*****************************************************************************************/#

# Make sure that when you run you run via ConfigMgr, SCCM, or Intune? idk if we have that lol. or some way to deploy across the env

# Define Dentrix services (adjust names if needed) I haven't really had time to look in prod enviornments but this is what pops up on my (real copy)
$services = @(
    "DentrixSQL",
    "DentrixImageService",
    "DentrixUpdateService",
    "DentrixACEServer",
    "DentrixDtxService"
)

# Define Dentrix processes that poop-heads might open
$processes = @(
    "Dentrix",
    "Dexis",
    "DxWeb"
)

function Stop-Dentrix {
    Write-Host "`n--- Stopping Dentrix Services ---`n"

    foreach ($svc in $services) {
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
            Write-Host "Stopping $svc..."
            Stop-Service -Name $svc -Force
            Set-Service -Name $svc -StartupType Manual
        }
    }

    Write-Host "`n--- Killing Dentrix Processes ---`n"
    foreach ($proc in $processes) {
        Get-Process -Name $proc -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "Killing process $($_.Name)..."
            Stop-Process -Id $_.Id -Force
        }
    }
}

function Start-Dentrix {
    Write-Host "`n--- Restarting Dentrix Services ---`n"

    foreach ($svc in $services) {
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
            Write-Host "Starting $svc..."
            Set-Service -Name $svc -StartupType Automatic
            Start-Service -Name $svc
        }
    }
}

# --- Main Script Execution ---
Stop-Dentrix

Write-Host "`nDentrix services are stopped. Run your utilities now."
Read-Host -Prompt "Press Enter when ready to restart Dentrix"

Start-Dentrix

Write-Host "`nDentrix environment restored successfully."
