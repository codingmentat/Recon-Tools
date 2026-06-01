@echo off
setlocal

REM ==========================================================================
REM Service Inventory - dump all services and binary paths to a file
REM ==========================================================================

set outfile=service-paths.txt

echo Service Inventory > %outfile%
echo Generated: %date% %time% >> %outfile%
echo Host: %COMPUTERNAME% >> %outfile%
echo ========================================================= >> %outfile%
echo. >> %outfile%

REM Use sc.exe to enumerate every service, then query config for each
for /f "tokens=2 delims=:" %%a in ('sc query state^= all ^| findstr /b "SERVICE_NAME:"') do (
    set "svc=%%a"
    call :GetServiceInfo %%a
)

echo. >> %outfile%
echo Done. Results: %outfile%
echo Results saved to %outfile%
goto :eof

REM --------------------------------------------------------------------------
REM GetServiceInfo - dump config for a single service
REM   %1 = service name (trimmed of leading space by call)
REM --------------------------------------------------------------------------
:GetServiceInfo
echo Name: %~1 >> %outfile%
for /f "tokens=1,* delims=:" %%i in ('sc qc %~1 2^>nul') do (
    set "key=%%i"
    set "val=%%j"
    REM Trim whitespace and pick out the fields we care about
    echo %%i | findstr /b /c:"        BINARY_PATH_NAME" >nul && echo Path:%%j>> %outfile%
    echo %%i | findstr /b /c:"        DISPLAY_NAME"     >nul && echo Display:%%j>> %outfile%
    echo %%i | findstr /b /c:"        SERVICE_START_NAME" >nul && echo RunsAs:%%j>> %outfile%
    echo %%i | findstr /b /c:"        START_TYPE"       >nul && echo StartType:%%j>> %outfile%
)
echo. >> %outfile%
goto :eof