@echo off
setlocal enabledelayedexpansion

REM ==========================================================================
REM SMB Share Enumeration - filters out default admin shares
REM ==========================================================================
set subnet=10.200.36
set outfile=shares.txt

REM Shares to ignore (default admin shares + drive letter admin shares C$-Z$)
REM Anything matching these patterns won't be written to output
set IGNORE_SHARES=ADMIN$ IPC$ PRINT$ FAX$ NETLOGON SYSVOL

echo SMB Share Enumeration > %outfile%
echo ===================== >> %outfile%
echo Subnet: %subnet%.0/24 >> %outfile%
echo Started: %date% %time% >> %outfile%
echo. >> %outfile%

for /l %%i in (1,1,254) do (
    ping -n 1 -w 500 %subnet%.%%i >nul 2>&1
    if not errorlevel 1 (
        echo Scanning %subnet%.%%i ...
        
        REM Temp file for this host's raw net view output
        set tempfile=netview_%%i.tmp
        net view \\%subnet%.%%i /all > !tempfile! 2>nul
        
        REM Check if we got anything useful (non-empty, no error)
        set hostHasShares=0
        for /f "skip=3 tokens=1,2*" %%a in (!tempfile!) do (
            REM Skip footer lines starting with "The command"
            echo %%a | findstr /b /c:"The command" >nul
            if errorlevel 1 (
                REM Only process lines where col 2 is "Disk" or "Print" (actual shares)
                if /i "%%b"=="Disk" call :CheckShare "%%a" "%%b" "%%c" %%i
                if /i "%%b"=="Print" call :CheckShare "%%a" "%%b" "%%c" %%i
            )
        )
        
        del !tempfile! 2>nul
    )
)

echo. >> %outfile%
echo Finished: %date% %time% >> %outfile%
echo Done. Results in %outfile%
goto :eof

REM ==========================================================================
REM CheckShare - decides whether to log a share based on ignore patterns
REM   %1 = share name (quoted)
REM   %2 = share type (quoted)
REM   %3 = remarks (quoted)
REM   %4 = host IP last octet
REM ==========================================================================
:CheckShare
set shareName=%~1
set shareType=%~2
set shareRemarks=%~3
set hostOctet=%4

REM Skip drive-letter admin shares: anything matching ?$ where ? is a single letter
echo %shareName% | findstr /r /b "[A-Za-z]\$$" >nul
if not errorlevel 1 goto :eof

REM Skip explicitly ignored shares
for %%s in (%IGNORE_SHARES%) do (
    if /i "%shareName%"=="%%s" goto :eof
)

REM This share is interesting - log it
REM Print header for this host the first time we log a share for it
if not defined HOST_LOGGED_%hostOctet% (
    echo. >> %outfile%
    echo [%subnet%.%hostOctet%] >> %outfile%
    set HOST_LOGGED_%hostOctet%=1
)
echo   %shareName%  ^(%shareType%^)  %shareRemarks% >> %outfile%
goto :eof