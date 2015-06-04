@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
::Toggling 'echo' turns it on/off globally, for chained batches.
@if defined PACKER_DEBUG (@echo on) else (@echo off)
@set _SILENT_=@
%_SILENT_%if defined PACKER_DEBUG set _SILENT_=
%_SILENT_%if not defined CHOCO_URL set CHOCO_URL=https://chocolatey.org/install.ps1
%_SILENT_%title Installing Chocolatey. Please wait...
%_SILENT_%echo ==^> Installing Chocolatey.
%_SILENT_%set INSTALL_COMMAND=powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('%CHOCO_URL%'))"
%_SILENT_%%INSTALL_COMMAND%
%_SILENT_%set CODE=%ERRORLEVEL%
%_SILENT_%if "%CODE%x" EQU "0x" goto :exit
%_SILENT_%echo ==^> WARNING: Error %CODE% was returned by: %INSTALL_COMMAND%
:exit
%_SILENT_%exit /b %CODE%