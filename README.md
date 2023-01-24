# Portable Encrypted Disk Launcher (PEDL)
Batch script for easy using portable VeraCrypt containers.

## Functions
- Mount and unmount container or partition.
- Autorun apps after mount.
- Closing running apps before unmount.
- Change modification time for container after unmount (useful for backup).
- Clean temporary files and privacy data after unmount.
- Backup default container after unmount.
- Eject removable disk after unmount.

## Usage
When script run - mount default container on default disk and execute autorun entries.  
If default disk already exist - unmount it and execute clean, backup and eject.  
Script can run with one command line parameter (/m /a /u /x /c /b /e /h) and execute only one action for default container or default disk.  
Any other command line parameter consider as container filename in pedl folder and script trying mount it (or unmount, if disk already exist).  
It this case first letter of filename use as disk name.

VeraCrypt  
https://veracrypt.fr/

BleachBit  
https://www.bleachbit.org/  
Run program and select cleaned items for saving preset.

USB Disk Ejector  
https://quickandeasysoftware.net/software/usb-disk-ejector  
Run program and set "Force close programs" in options.

## Command line usage
pedl.bat [filename | /m | /a | /u | /x | /c | /b | /e | /h]  
&nbsp;&nbsp; filename - Container filename in pedl folder or "devices" (without quotes) for auto mounting.  
&nbsp;&nbsp; /m - Mount default container on default disk.  
&nbsp;&nbsp; /a - Run autorun items.  
&nbsp;&nbsp; /u - Unmount default disk.  
&nbsp;&nbsp; /x - Unmount all mounted disks.  
&nbsp;&nbsp; /c - Clean temporary files and privacy data.  
&nbsp;&nbsp; /b - Backup default container.  
&nbsp;&nbsp; /e - Eject removable disk with pedl.  
&nbsp;&nbsp; /h - Show command line help.  
