@echo off
setlocal enabledelayedexpansion

::error checking to quit if there is the shutdown flag
if exist shutdown.flag exit /b

echo [%time%] monitor.bat started with args: %*

:: Arguments:
:: %1 = device
:: %2 = title
:: %3 = posx
:: %4 = posy
:: %5 = id
:: %6 = window-height

set "device=%~1"
set "title=%~2"
set "posx=%~3"
set "posy=%~4"
set "id=%~5"
set "window-height=%~6"
::set "was_paused=0"

:: Exit early if essential args are missing
if "%~1"=="" goto :eof
if "%~5"=="" goto :eof

:: Launch monitor mode if seventh argument is "monitor"
if "%~7"=="monitor" goto monitor

:: Launch a new minimized CMD window running this script in 'monitor' mode
start "Monitor %id%" /min cmd /k call "%~f0" %device% %title% %posx% %posy% %id% %window-height% monitor

:: End original session
goto :eof

:monitor
:: Immediately exit if shutdown flag is present
if exist shutdown.flag exit /b
:: Prevent relaunch if lock exists
set "lockfile=launch_%id%.lock"
if exist "%lockfile%" (
    echo [%time%] Lock file "%lockfile%" already exists — skipping monitor loop.
    exit /b
)

:: Create lock
echo running > "%lockfile%"

:main_monitor_loop
:: Check scrcpy status and restart if needed
adb -s %device% shell pidof com.android.shell:scrcpy >nul
if errorlevel 1 (
    echo %title% scrcpy not running. Launching...
	scrcpy3.2\scrcpy -s %device% --window-title="%title%" --window-x=%posx% --window-y=%posy% --window-width=640 --window-height=%window-height% --no-audio 2>> nul 2>&1
    timeout /t 1 >nul
) else (
    echo %title% scrcpy already running. Skipping launch.
)

:: ADB reconnection logic if needed
adb devices | findstr /i "%device%" >nul
if errorlevel 1 (
    echo Device %device% not found in ADB. Attempting reconnect...
    adb connect %device%
    timeout /t 2 >nul
    adb devices | findstr /i "%device%" >nul
    if errorlevel 1 (
        echo Reconnect failed. Testing network reachability...
        powershell -Command "if ((Test-NetConnection -ComputerName %device::= % -Port %device:*:=% ).TcpTestSucceeded) { exit 0 } else { exit 1 }"
        if errorlevel 1 (
            echo Device %device% unreachable. Waiting and retrying...
            timeout /t 3 >nul
        ) else (
            echo Network reachable, retrying ADB connection...
        )
    ) else (
        echo Successfully reconnected to %device%.
    )
) else (
    echo %title% already connected via ADB.
    timeout /t 2 >nul
)

:: Loop
timeout /t 3 >nul
goto main_monitor_loop
