@echo off
goto description_end

------------------------------------------------------------------[Description]

Portable Encrypted Disk Launcher (PEDL)
Batch script for easy using portable VeraCrypt containers.

Functions
Mount and unmount container or partition.
Autorun apps after mount.
Closing running apps before unmount.
Change modification time for container after unmount (useful for backup).
Clean temporary files and privacy data after unmount.
Backup default container after unmount.
Eject removable disk after unmount.

Usage
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

Command line usage
pedl.bat [filename | /m | /a | /u | /x | /c | /b | /e | /h]
  filename     Container filename in pedl folder or "devices" (without quotes) for auto mounting.
  /m           Mount default container on default disk.
  /a           Run autorun items.
  /u           Unmount default disk.
  /x           Unmount all mounted disks.
  /c           Clean temporary files and privacy data.
  /b           Backup default container.
  /e           Eject removable disk with pedl.
  /h           Show command line help.

Author
joddude@gmail.com

Disclaimer
This script is free and provided "as is" without any warranty.
The author assumes no responsibility for any moral or material damage caused
by the use of this script, any loss of profit as a result of or during use.


:description_end

rem -------------------------------------------------------------------[Config]

rem Path to VeraCrypt
set VERACRYPT_EXE=VeraCrypt\VeraCrypt.exe

rem Path to BleachBit
set BLEACHBIT_EXE=BleachBit-Portable\bleachbit_console.exe

rem Path to USB Disk Ejector
set USBDISKEJECT_EXE=USBDiskEject\USB_Disk_Eject.exe

rem Container filename in pedl folder or "devices" (without quotes) for auto mounting.
set DEFAULT_CONTAINER=s.hc

rem Default disk for mount.
set DEFAULT_DISK=s:

rem Waiting time for entering password and mount disk, seconds.
set WAIT_MOUNT_TIME=60

rem Waiting time for unmount disk, seconds.
set WAIT_UNMOUNT_TIME=20

rem Executing commands after mount default container (Y for enable).
set AUTORUN_ENABLE=Y

rem List commands for executing after mount default container. Up to 9 items.
set AUTORUN_LIST="s:\apps\shell\Total Commander\TOTALCMD.EXE" s:\apps\launcher\boomerang\boomerang.exe

rem Change modification time of containers after unmount (Y for enable).
set CHANGE_TIMEDATE_ENABLE=Y

rem Clean temporary files and privacy data after unmount (Y for enable).
set CLEAN_ENABLE=Y

rem Backup default container after unmount (Y for enable).
set BACKUP_ENABLE=Y

rem Default answer for backup choice (Y or N).
set BACKUP_DEFAULT_CHOICE=N

rem List target filenames for backup default container. Copied only if folder exist.
set BACKUP_TARGET_LIST=d:\pedl\s-backup.hc k:\backup\s.hc

rem Waiting time for backup choice, seconds.
set BACKUP_WAIT_TIME_CHOICE=5

rem Eject pedl disk after unmount default container (Y for enable).
set EJECT_ENABLE=Y


rem ---------------------------------------------------------------------[Main]
setlocal
set PEDL=%~0
set PEDL_DISK=%~d0
set PEDL_FOLDER=%~dp0
cd /D "%PEDL_FOLDER%"

title Portable Encrypted Disk Launcher
echo Portable Encrypted Disk Launcher
echo Batch script for easy using portable VeraCrypt containers.
echo PEDL disk: %PEDL_DISK%
echo PEDL folder: %PEDL_FOLDER%

set PEDL_ARGUMENT=%~1
set CONTAINER=%DEFAULT_CONTAINER%
set DISK=%DEFAULT_DISK%

if "%PEDL_ARGUMENT%"=="/m" (
  call :mount
  goto exit
)
if "%PEDL_ARGUMENT%"=="/a" (
  call :autorun
  goto exit
)
if "%PEDL_ARGUMENT%"=="/u" (
  call :unmount
  goto exit
)
if "%PEDL_ARGUMENT%"=="/x" (
  call :unmount all
  goto exit
)
if "%PEDL_ARGUMENT%"=="/c" (
  call :clean
  goto exit
)
if "%PEDL_ARGUMENT%"=="/b" (
  set BACKUP_DEFAULT_CHOICE=Y
  call :backup
  goto exit
)
if "%PEDL_ARGUMENT%"=="/e" (
  call :eject
  goto exit
)
if "%PEDL_ARGUMENT:~0,1%"=="/" (
  call :help
  goto exit
)
if not "%PEDL_ARGUMENT%"=="" (
  set CONTAINER=%PEDL_ARGUMENT%
  set DISK=%PEDL_ARGUMENT:~0,1%:
)

if not exist "%DISK%" (
  call :mount
  if errorlevel 1 goto exit
  if /I "%CONTAINER%"=="%DEFAULT_CONTAINER%" (
    if %AUTORUN_ENABLE%==Y call :autorun
  )
) else (
  call :unmount
  if errorlevel 1 goto exit
  if %CLEAN_ENABLE%==Y call :clean
  if %BACKUP_ENABLE%==Y call :backup
  if %EJECT_ENABLE%==Y call :eject
)

:exit
timeout 3
exit /b


rem --------------------------------------------------------------------[Mount]
:mount
if "%CONTAINER%"=="devices" (
  echo Auto mounting devices on disk %DISK%
  %VERACRYPT_EXE% /q /b /l %DISK:~0,1% /a devices
) else (
  echo Mounting %CONTAINER% on disk %DISK%
  %VERACRYPT_EXE% /q /b /l %DISK:~0,1% /v "%CONTAINER%"
)
echo Waiting for disk %DISK%
call :wait_disk_mount "%DISK%" %WAIT_MOUNT_TIME%
if errorlevel 1 exit /b 1
call :wait_process_end "chkdsk.exe"
exit /b 0


rem ------------------------------------------------------------------[Autorun]
:autorun
for %%I in (%AUTORUN_LIST%) do (
  echo Start %%~I
  cd /D "%%~dpI"
  start "" "%%~I"
)
cd /D "%PEDL_FOLDER%"
exit /b 0


rem ------------------------------------------------------------------[Unmount]
:unmount
if "%~1"=="all" (
  if exist "%DEFAULT_DISK%" (
    call :close_apps "%DEFAULT_DISK%"
  )
  echo Unmounting all
  %VERACRYPT_EXE% /q /b /f /d
) else (
  call :close_apps "%DISK%"
  echo Unmounting %DISK%
  %VERACRYPT_EXE% /q /b /f /d %DISK:~0,1%
)
call :wait_disk_unmount "%DISK%" %WAIT_UNMOUNT_TIME%
if errorlevel 1 exit /b 1
if %CHANGE_TIMEDATE_ENABLE%==Y call :change_timedate
exit /b 0


rem ---------------------------------------------------------------[Close apps]
:close_apps
echo Closing apps from %~1
rem wmic depricated soon
wmic Path win32_process Where "executablepath Like '%%%~1\\%%'" Call Terminate >nul 2>&1
exit /b %ERRORLEVEL%


rem ----------------------------------------------------------[Change timedate]
:change_timedate
if "%CONTAINER%"=="devices" exit /b 1
echo Change datetime for %CONTAINER%
copy /b %CONTAINER%+,, > nul
exit /b %ERRORLEVEL%


rem --------------------------------------------------------------------[Clean]
:clean
echo Cleaning
%BLEACHBIT_EXE% --clean --preset
exit /b 0


rem -------------------------------------------------------------------[Backup]
:backup
if "%CONTAINER%"=="devices" exit /b 2
if /I not "%CONTAINER%"=="%DEFAULT_CONTAINER%" exit /b 3
choice /T %BACKUP_WAIT_TIME_CHOICE% /D %BACKUP_DEFAULT_CHOICE% /M "Backup %DEFAULT_CONTAINER%? Default: %BACKUP_DEFAULT_CHOICE%"
if errorlevel 2 exit /b 1

for %%I in (%BACKUP_TARGET_LIST%) do (
  if not exist "%%~dpI" (
    echo Folder %%~dpI not found
  ) else (
    echo Copy %DEFAULT_CONTAINER% to %%~I
    copy /Y /Z "%DEFAULT_CONTAINER%" "%%~I"
  )
)
exit /b 0


rem --------------------------------------------------------------------[Eject]
:eject
if /I not "%CONTAINER%"=="%DEFAULT_CONTAINER%" exit /b 2
rem wmic depricated soon
wmic Path win32_Volume where DriveLetter="%PEDL_DISK%" get DriveType /VALUE | find "DriveType=2" >nul 2>&1
if errorlevel 1 exit /b 1
echo Eject %PEDL_DISK%
%USBDISKEJECT_EXE% /REMOVETHIS
exit /b 0


rem ---------------------------------------------------------------------[Help]
:help
echo.
echo Command line usage
echo pedl.bat [filename ^| /m ^| /a ^| /u ^| /x ^| /c ^| /b ^| /e ^| /h]
echo   filename     Container filename in pedl folder or "devices" (without quotes) for auto mounting.
echo   /m           Mount default container on default disk.
echo   /a           Run autorun items.
echo   /u           Unmount default disk.
echo   /x           Unmount all mounted disks.
echo   /c           Clean temporary files and privacy data.
echo   /b           Backup default container.
echo   /e           Eject removable disk with pedl.
echo   /h           Show command line help.
exit /b 0


rem -------------------------------------------------------[Wait process start]
:wait_process_start
set TIMER=0
:wait_process_start2
if %TIMER%==%~2 exit /b 1
set /A TIMER+=1
timeout 1 > nul
tasklist /fi "imagename eq %~1" | find /i "%~1" > nul
if errorlevel 1 goto wait_process_start2
exit /b 0


rem ---------------------------------------------------------[Wait process end]
:wait_process_end
tasklist /fi "imagename eq %~1" | find ":" > nul
if errorlevel 1 goto wait_process_end
exit /b 0


rem ----------------------------------------------------------[Wait disk mount]
:wait_disk_mount
set TIMER=0
:wait_disk_mount2
if %TIMER%==%~2 exit /b 1
set /A TIMER+=1
timeout 1 > nul
if not exist "%~1" goto wait_disk_mount2
exit /b 0


rem --------------------------------------------------------[Wait disk unmount]
:wait_disk_unmount
set TIMER=0
:wait_disk_unmount2
if %TIMER%==%~2 exit /b 1
set /A TIMER+=1
timeout 1 > nul
if exist "%~1" goto wait_disk_unmount2
exit /b 0

