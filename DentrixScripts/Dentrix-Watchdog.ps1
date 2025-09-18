# Paths to Dentrix executables / module files (adjust to your env)


# If you need to change users go to line 67
# Change BuiltIN\Users to whatever you need
# Completely AI generated for full transparency mainly looking to learn and test in my own enviornment this will stop more svcs/processes 
# and prevent users from relaunching Dentrix while maintenance is being performed # (eg. running Dentrix Utilities, DBCC CHECKDB, etc)

$dentrixInstallPaths = @(
    "C:\Program Files\Dentrix\Dentrix.exe",
    "C:\Program Files\Dentrix\Dexis.exe",
    "C:\Program Files\Dentrix\DxWeb.exe"
)
# You can add module DLLs or module folders here if modules are delivered as files.
$dentrixModulePaths = @(
    "C:\Program Files\Dentrix\Modules\ModuleA.dll",
    "C:\Program Files\Dentrix\Modules\ModuleB.dll"
)

$services = @(
    "DentrixSQL",
    "DentrixImageService",
    "DentrixUpdateService",
    "DentrixACEServer",
    "DentrixDtxService"
)

$processes = @(
    "Dentrix",
    "Dexis",
    "DxWeb"
)

function Stop-Dentrix {
    Write-Host "`n--- Stopping Dentrix Services ---`n"
    foreach ($svc in $services) {
        $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($s) {
            Write-Host "Stopping $svc..."
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
        }
    }

    Write-Host "`n--- Killing Dentrix Processes ---`n"
    foreach ($proc in $processes) {
        Get-Process -Name $proc -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "Killing process $($_.Name)..."
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    }
}

function Start-Dentrix {
    Write-Host "`n--- Restarting Dentrix Services ---`n"
    foreach ($svc in $services) {
        $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($s) {
            Write-Host "Starting $svc..."
            Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name $svc -ErrorAction SilentlyContinue
        }
    }
}

# Add a DENY ACL for the built-in Users group to prevent non-admins executing the files
# If you need to change Users do it here
function Deny-ExecuteForUsers {
    param(
        [string[]]$Paths,
        [string]$Account = "BUILTIN\Users"
    )
    foreach ($p in $Paths) {
        if (Test-Path $p) {
            try {
                $acl = Get-Acl -Path $p
                $denyRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    $Account,
                    [System.Security.AccessControl.FileSystemRights]::ReadAndExecute,
                    [System.Security.AccessControl.InheritanceFlags]::None,
                    [System.Security.AccessControl.PropagationFlags]::None,
                    [System.Security.AccessControl.AccessControlType]::Deny
                )
                # Avoid duplicate denies
                if (-not ($acl.Access | Where-Object { $_.IdentityReference -eq $Account -and $_.AccessControlType -eq "Deny" -and $_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::ReadAndExecute })) {
                    $acl.AddAccessRule($denyRule)
                    Set-Acl -Path $p -AclObject $acl
                    Write-Host "Added DENY Execute for $Account on $p"
                } else {
                    Write-Host "DENY already present on $p"
                }
            } catch {
                Write-Warning "Failed to set ACL on $p : $_"
            }
        } else {
            Write-Host "Path not found: $p"
        }
    }
}

# Remove the previously applied DENY rules (restore)
function Remove-DenyExecuteForUsers {
    param(
        [string[]]$Paths,
        [string]$Account = "BUILTIN\Users"
    )
    foreach ($p in $Paths) {
        if (Test-Path $p) {
            try {
                $acl = Get-Acl -Path $p
                $rulesToRemove = $acl.Access | Where-Object {
                    ($_.IdentityReference -eq $Account) -and ($_.AccessControlType -eq "Deny") -and ($_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::ReadAndExecute)
                }
                foreach ($r in $rulesToRemove) {
                    $acl.RemoveAccessRuleSpecific($r)
                }
                Set-Acl -Path $p -AclObject $acl
                Write-Host "Removed DENY Execute for $Account on $p"
            } catch {
                Write-Warning "Failed to remove ACL from $p : $_"
            }
        } else {
            Write-Host "Path not found: $p"
        }
    }
}

# Disable module files by removing read/execute for Users (same technique)
function Disable-DentrixModules {
    Write-Host "`n--- Disabling Dentrix modules (deny read/execute for Users) ---`n"
    Deny-ExecuteForUsers -Paths $dentrixModulePaths
    Deny-ExecuteForUsers -Paths $dentrixInstallPaths
}

function Enable-DentrixModules {
    Write-Host "`n--- Re-enabling Dentrix modules (remove deny) ---`n"
    Remove-DenyExecuteForUsers -Paths $dentrixModulePaths
    Remove-DenyExecuteForUsers -Paths $dentrixInstallPaths
}

# Create a scheduled task that runs as SYSTEM every 1 minute and invokes a small script that kills Dentrix processes if launched.
function Install-KillDentrixScheduledTask {
    param(
        [string]$TaskName = "KillDentrixWatcher",
        [string]$ScriptPath = "C:\Scripts\KillDentrix.ps1",
        [int]$IntervalMinutes = 1
    )

    # Ensure script folder exists
    $dir = Split-Path -Path $ScriptPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # Create the kill script
    $scriptContent = @'
$procNames = @("Dentrix","Dexis","DxWeb")
foreach ($p in $procNames) {
    Get-Process -Name $p -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        } catch {}
    }
}
'@

    $scriptContent | Out-File -FilePath $ScriptPath -Encoding UTF8 -Force

    # Build schtasks command to create a repeating task running as SYSTEM
    $action = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $interval = $IntervalMinutes

    # Delete existing task if present
    schtasks.exe /Delete /TN $TaskName /F 2>$null | Out-Null

    # Create scheduled task to run every $IntervalMinutes
    $createCmd = "schtasks.exe /Create /SC MINUTE /MO $interval /TN `"$TaskName`" /TR `"$action`" /RU SYSTEM /F"
    Write-Host "Creating scheduled task to kill Dentrix processes every $interval minute(s)..."
    Invoke-Expression $createCmd
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Scheduled task '$TaskName' created."
    } else {
        Write-Warning "Failed to create scheduled task. Exit code: $LASTEXITCODE"
    }
}

function Remove-KillDentrixScheduledTask {
    param([string]$TaskName = "KillDentrixWatcher")
    schtasks.exe /Delete /TN $TaskName /F 2>$null | Out-Null
    Write-Host "Scheduled task '$TaskName' removed (if it existed)."
}

# --- Main flow (example usage) ---
Write-Host "Stopping Dentrix services/processes..."
Stop-Dentrix

Write-Host "Disabling modules and preventing user relaunch..."
Disable-DentrixModules

Write-Host "Installing kill-watcher scheduled task..."
Install-KillDentrixScheduledTask -ScriptPath "C:\Scripts\KillDentrix.ps1" -IntervalMinutes 1

Write-Host "`nDentrix services/processes/modules disabled. Users will be unable to run Dentrix and watcher will kill attempts."
Write-Host "To restore, run the enable routine (Start services, remove denies, remove scheduled task)."

# Example restore commands (do not run automatically—keep commented)
<# 
# Remove task and restore permissions, then start services
Remove-KillDentrixScheduledTask
Enable-DentrixModules
Start-Dentrix
#>
