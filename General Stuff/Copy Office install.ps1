
<#
.SYNOPSIS
    Copies a target folder from the remote host usually to copy over large installer folders so u don't have to go thru 20 pcs
.DESCRIPTION
    Was made for office but can be changed to copy whatever remote dir from whatever server (as long as it's connected on the network lol) 
    It will copy the new folder to the desktop under the folder "Office install" this can be changed on dest line
.NOTES
    File Name      : RemoteCopier.ps1
    Author         : garrettoh the goat
    Prerequisite   : to be goated (pwsh 5.0 >=)
.LINK
    Script posted over:
    https://github.com/garrettoh/Sysadminscripts
.EXAMPLE
    Copy one folder (Office 2016 installer package) to desktop / Office installs
#>

$source = "\\gre-dexis\NFC_Staging\Office 2016 STD MAK"
$destination = Join-Path -Path $env:USERPROFILE -ChildPath "Desktop\Office install"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}

Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force -ErrorAction Stop

Write-Host "Files successfully copied to: $destination"
