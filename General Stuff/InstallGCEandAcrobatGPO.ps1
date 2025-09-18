<#
.SYNOPSIS
    Installs Google Chrome and Adobe Acrobat Reader DC via GPO Startup Script.
.DESCRIPTION
    Checks if each app is installed; if missing, installs silently from network share.
    To be used as a GPO Startup Script under Computer Configuration.
.NOTES
    Place installers in \\DC01\Software\ 
    - Chrome: googlechromestandaloneenterprise64.msi
    - Acrobat: AcroRdrDCx6424001200058_en_US.msi (example version)
    - By default it will use the DC share, but you can change to W: drive if needed.
#>

# Define installer paths (network share accessible to Domain Computers) #somtimes will be Apps-01 or under the W drive just change to your need 


$ChromeInstaller = "\\DC01\Software\googlechromestandaloneenterprise64.msi"
$AcrobatInstaller = "\\DC01\Software\AcroRdrDC.msi"


# IF ITS NOT ON THE DC CHANGE IT TO THE WORK DRIVE LIKE SO JUST UNCOMMENT THE LINES BELOW AND COMMENT THE LINES ABOVE


#   $ChromeInstaller  = "W:\NFC\Installers\googlechromestandaloneenterprise64.msi" *remove the hashtag to remove comment (#) and asterisk until end of line.  
#   $AcrobatInstaller = "W:\NFC\Installers\AcroRdrDC.msi"



# Function to check if software is installed by DisplayName
function Test-Installed($Name) {
    $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
                             HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
        | Where-Object { $_.DisplayName -like "*$Name*" }
    return $apps
}

# Install Google Chrome if not installed
if (-not (Test-Installed "Google Chrome")) {
    Write-Output "Installing Google Chrome..."
    Start-Process "msiexec.exe" -ArgumentList "/i `"$ChromeInstaller`" /qn /norestart" -Wait -NoNewWindow
} else {
    Write-Output "Google Chrome already installed."
}

# Install Adobe Acrobat Reader DC if not installed
if (-not (Test-Installed "Adobe Acrobat Reader")) {
    Write-Output "Installing Adobe Acrobat Reader DC..."
    Start-Process "msiexec.exe" -ArgumentList "/i `"$AcrobatInstaller`" /qn /norestart" -Wait -NoNewWindow
} else {
    Write-Output "Adobe Acrobat Reader DC already installed."
}
