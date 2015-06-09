@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
::Toggling 'echo' turns it on/off globally, for chained batches.
@if defined PACKER_DEBUG (@echo on) else (@echo off)
@set _SILENT_=@
%_SILENT_%if defined PACKER_DEBUG set _SILENT_=

%_SILENT_%title Installing .NET framework 4.5. Please wait...
%_SILENT_%echo ==^> Installing .NET 4.5.
%_SILENT_%set INSTALL_COMMAND=choco install -y dotnet45
%_SILENT_%%INSTALL_COMMAND%
%_SILENT_%set CODE=%ERRORLEVEL%
%_SILENT_%if "%CODE%x" EQU "0x" goto :exit
%_SILENT_%echo ==^> WARNING: Error %CODE% was returned by: %INSTALL_COMMAND%
%_SILENT_%goto exit

:exit
%_SILENT_%exit /b %CODE%