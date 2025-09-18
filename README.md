# Windows Server Automation for Dental Environments

Repo for a bunch of automation scripts, scripts to turn off the poopheads access to stuff when we need to (domain wide), still wip as i learn and have my buddy gpt help me like he helped for the readme i love wasting water : DDDDD

> LETS MAKE OUR LIFE EASIER


### Reqs
Install powershell 7
```powershell
winget search Microsoft.PowerShell
```

To install 
```powershell
winget install --id Microsoft.PowerShell --source winget
```

You can also replace "Microsoft.Powershell" with another version you might see like "Microsoft.Powershell.Preview"

should see >=v7 if not look MSDN below
---

vvvv

https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5
## Features

Automation scripts for starting, stopping, and restarting PMS services and modules

Tools for scheduling system maintenance and backups

Scripts for managing user sessions and permissions in a domain environment

Utility functions for server monitoring, logging, and troubleshooting

Deployment examples for pushing scripts across multiple workstations

## Example Use Cases

Dentrix Utilities: Stop all Dentrix-related services before running utilities, then restart them safely afterward
> This happened on like my 3rd day so i went home and made a script to stop the poop-heads from accessing dentrix when youre trying to run utils

Patch Management: Automate the process of preparing servers and clients for Windows Updates

User Management: Bulk add, remove, or disable users in Active Directory

Data Integrity: Schedule regular PMS database backup and verification tasks

## Requirements

PowerShell 5.1+ (or PowerShell Core where applicable -- **only tested with pwsh 7.1** but should work (hopefully))

Administrative privileges on the target systems

Domain admin if ur a baddie

#### Deployment

> Scripts can be deployed manually, through Group Policy (GPO), or with centralized management tools such as SCCM/MECM or Intune. Each script includes usage instructions and any prerequisites in the header comments. I'm prob gonna be pushing for this so we can get more work done with less stress and mistyping etc.
---
### Repository Structure
/DentrixScripts
-- dentrix scripts currently only holds Dentrix stop svcs script


/Eaglesoft stuff
-- i wanan make a backup db script


/Carestream stuff
-- WIP


/General stuff 
--i.e installing printers on multiple workstations at once 



### Contributing

Contributions are welcome. If you would like to add a new automation script or improve an existing one, please submit a pull request with clear documentation and testing notes. (im a dumbass so don't just push to prod run them by me and other people familiar with CLI/pwsh or ad. (im still learning so im testing in lab enviornments first and all scripts aren't on the repo yet. 

If you want to contribute, just msg me or talk to me (i know its scary im at the back of the room) 

AGAIN ANY CONTRIBUTION ADVICE OR ANYTHING IS SO MUCH APPRECIATED W COWORKERS
