@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
::Toggling 'echo' turns it on/off globally, for chained batches.
@if defined PACKER_DEBUG (@echo on) else (@echo off)
@set _SILENT_=@
%_SILENT_%if defined PACKER_DEBUG set _SILENT_=
%_SILENT_%reg Query "HKLM\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine" /v PowerShellVersion | find "4.0" > NUL 2>&1 && set INSTALLED=1
%_SILENT_%if defined INSTALLED echo ==^> WARNING: PowerShell 4.0 already installed. Skipping install.
%_SILENT_%if defined INSTALLED set CODE=0 && goto :exit

%_SILENT_%ver | find "6.1" > NUL 2>&1 && SET VERSION=6.1
%_SILENT_%ver | find "6.2" > NUL 2>&1 && SET VERSION=6.2
%_SILENT_%reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL 2>&1 && set BITNESS=32 || set BITNESS=64
%_SILENT_%if "%VERSION%" EQU "6.1" if not defined POWERSHELL4_URL if "%BITNESS%" EQU "32" set POWERSHELL4_URL=http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x86-MultiPkg.msu
::%_SILENT_%if "%VERSION%" EQU "6.1" if not defined POWERSHELL4_CHECKSUM if "%BITNESS%" EQU "32" set POWERSHELL4_CHECKSUM=d5dd77c5cd6370984257c81269ce40f83466d20339e44bb6de40c22d96641b98
%_SILENT_%if "%VERSION%" EQU "6.1" if not defined POWERSHELL4_URL if "%BITNESS%" EQU "64" set POWERSHELL4_URL=http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu
::%_SILENT_%if "%VERSION%" EQU "6.1" if not defined POWERSHELL4_CHECKSUM if "%BITNESS%" EQU "64" set POWERSHELL4_CHECKSUM=fbc0889528656a3bc096f27434249f94cba12e413142aa38946fcdd8edf6f4c5
%_SILENT_%if "%VERSION%" EQU "6.2" if not defined POWERSHELL4_URL if "%BITNESS%" EQU "64" set POWERSHELL4_URL=http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows8-RT-KB2799888-x64.msu
::%_SILENT_%if "%VERSION%" EQU "6.2" if not defined POWERSHELL4_CHECKSUM if "%BITNESS%" EQU "64" set POWERSHELL4_CHECKSUM=a68da0b05dbe245510578d9affb60fd624e906d21a57bfa35741a6f677091c66
%_SILENT_%if not defined POWERSHELL4_URL echo ==^> WARNING: POWERSHELL4_URL is unset. Skipping install. Are you installing into Windows 7 or Windows 8 product family?
%_SILENT_%if not defined POWERSHELL4_URL set CODE=0 && goto :exit

%_SILENT_%title Installing PowerShell 4. Please wait...
%_SILENT_%for %%i in (%POWERSHELL4_URL%) do set POWERSHELL4_MSU=%%~nxi
%_SILENT_%set POWERSHELL4_DIR=%TEMP%\powershell4
%_SILENT_%set POWERSHELL4_PATH=%POWERSHELL4_DIR%\%POWERSHELL4_MSU%
%_SILENT_%echo ==^> Creating "%POWERSHELL4_DIR%"
%_SILENT_%mkdir "%POWERSHELL4_DIR%"
%_SILENT_%pushd "%POWERSHELL4_DIR%"
%_SILENT_%if exist "%SystemRoot%\_download.cmd" set DOWNLOAD_COMMAND=call "%SystemRoot%\_download.cmd" "%POWERSHELL4_URL%" "%POWERSHELL4_PATH%"
%_SILENT_%if not defined DOWNLOAD_COMMAND set DOWNLOAD_COMMAND=powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%POWERSHELL4_URL%', '%POWERSHELL4_PATH%')" <NUL
%_SILENT_%echo ==^> Downloading "%POWERSHELL4_URL%" to "%POWERSHELL4_PATH%"
%_SILENT_%%DOWNLOAD_COMMAND%
%_SILENT_%set CODE=%ERRORLEVEL%
%_SILENT_%if "%CODE%x" EQU "0x" if not exist "%POWERSHELL4_PATH%" set CODE=1
%_SILENT_%if "%CODE%x" EQU "0x" goto :install
%_SILENT_%echo ==^> WARNING: Error %CODE% was returned by: %DOWNLOAD_COMMAND%
%_SILENT_%goto exit

:install
%_SILENT_%echo ==^> Installing PowerShell 4.
%_SILENT_%set INSTALL_COMMAND=wusa.exe /quiet /norestart "%POWERSHELL4_PATH%"
%_SILENT_%%INSTALL_COMMAND%
%_SILENT_%set CODE=%ERRORLEVEL%
%_SILENT_%if "%CODE%x" EQU "0x" goto :exit
%_SILENT_%if "%CODE%x" EQU "42x" goto :exit
%_SILENT_%if "%CODE%x" EQU "127x" goto :exit
%_SILENT_%if "%CODE%x" EQU "3010x" goto :exit
%_SILENT_%echo ==^> WARNING: Error %CODE% was returned by: %INSTALL_COMMAND%
%_SILENT_%goto exit

:exit
%_SILENT_%exit /b %CODE%
