# Windows Server Automation for Dental Environments

This repository contains a collection of automation scripts designed for Windows Server environments in dental practices. The primary focus is on supporting Practice Management Systems (PMS) such as Dentrix, Eaglesoft, and Carestream, while also providing general-purpose automation scripts for common administrative tasks.

## Purpose

Dental offices often run specialized PMS software that requires frequent maintenance, configuration, and monitoring. This repository provides automation solutions to simplify recurring tasks, reduce downtime, and improve operational efficiency for IT administrators.

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

PowerShell 5.1+ (or PowerShell Core where applicable) most have pwsh7 

Administrative privileges on the target systems

DA

Deployment

> Scripts can be deployed manually, through Group Policy (GPO), or with centralized management tools such as SCCM/MECM or Intune. Each script includes usage instructions and any prerequisites in the header comments. I'm prob gonna be pushing for this so we can get more work done with less stress and mistyping etc.

### Repository Structure
/Dentrix
    Stop-DentrixServices.ps1
    Start-DentrixServices.ps1
/Eaglesoft
    Backup-EaglesoftDB.ps1
/General
    Restart-Services.ps1
    User-Management.ps1
/Deployment
    Deploy-Script-GPO.md
    Deploy-Script-SCCM.md

### Contributing

Contributions are welcome. If you would like to add a new automation script or improve an existing one, please submit a pull request with clear documentation and testing notes. (im a dumbass so don't just push to prod run them by me and other people familiar with CLI/pwsh or ad. (im still learning so im testing in lab enviornments first and all scripts aren't on the repo yet. 

If you want to contribute, just msg me or talk to me (i know its scary im at the back of the room) 

AGAIN ANY CONTRIBUTION ADVICE OR ANYTHING IS SO MUCH APPRECIATED W COWORKERS
