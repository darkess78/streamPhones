@echo off
setlocal enabledelayedexpansion
if exist shutdown.flag exit /b

:: Check for flags
set "DEBUG_MODE=0"
set "is_test=0"
:: Loop through all command-line arguments
for %%a in (%*) do (
    if "%%~a"=="--debug" set "DEBUG_MODE=1"
    if "%%~a"=="--test" set "is_test=1"
)

:: Layout mode: 1=1080 top, 2=1440 main, 3=1080 main, 4=1080 right, 5=1440 right
set /p windowInput=Enter (1 top monitor), (2 main 1440), (3 main 1080), (4 right 1080), (5 right 1440) or just enter for default: 
if "%windowInput%"=="" set "windowInput=1"

if "%windowInput%"=="1" (
    :: top monitor
    set /a windowHeight=1080
    set /a posy=-1050
    set /a posx=0
) else if "%windowInput%"=="2" (
    :: main monitor full size
    set /a windowHeight=1440
    set /a posy=30
    set /a posx=0
) else if "%windowInput%"=="3" (
    :: main monitor 1080
    set /a windowHeight=1080
    set /a posy=30
    set /a posx=0
) else if "%windowInput%"=="4" (
    :: right monitor 1080
    set /a windowHeight=1080
    set /a posy=2560
    set /a posx=30
) else if "%windowInput%"=="5" (
    :: right monitor 1440
    set /a windowHeight=1440
    set /a posy=2560
    set /a posx=30
)
::2560 is 1.3333333 x 1920

set "all_ids="
set "all_monitor_titles="

:: Load device list from external file
call load_devices.bat

:: Generate a session-specific random ID
set /a rid=%random% * 100 + %random%
call :debug "Random ID for this run: %rid%"

:: Launch each device with a unique scrcpy window
for /L %%i in (1,1,%deviceCount%) do (
    call :init_device_vars %%i
)
call :loop %rid% "%all_ids%"

:init_device_vars
:: %1 = device index
if exist shutdown.flag exit /b

set "index=%1"

:: Load device and title
call set "device=%%device%index%%%"
call set "title=%%title%index%%%"

:: Calculate position
set /a offset=(index - 1) * 640
set /a posx_current=%posx% + offset
set /a posy_current=%posy%

:: Store current positions
call set "posx%index%=%posx_current%"
call set "posy%index%=%posy_current%"

::error checking to quit if there is no title or device
if not defined title exit /b
if not defined device exit /b
if exist shutdown.flag exit /b

:: Display info
echo Launching %title% at %device% on %posx_current%, %posy_current%
echo.
:: Launch the monitor/scrcpy session
call :launch_monitor "%title%" "%device%" %posx_current% %posy_current% "%all_ids%" updated_ids updated_titles
set "all_ids=%updated_ids%"
set "all_monitor_titles=%updated_titles%"
exit /b

:launch_monitor
:: %1 = title
:: %2 = device
:: %3 = posx
:: %4 = posy
:: %5 = all_ids
:: %6 = return var name for ids
:: %7 = return var name for titles

setlocal enabledelayedexpansion
if exist shutdown.flag (
    echo Skipping monitor launch due to shutdown.
    endlocal
    exit /b
)

:: Assign arguments
set "title=%~1"
set "device=%~2"
set "posx=%~3"
set "posy=%~4"
set "all_ids=%~5"
set "return_ids=%~6"
set "return_titles=%~7"
set "id=%rid%_%title%"
set "windowHeight=%windowHeight%"

:: Track all launched sessions
echo !all_ids! | findstr /i "\<%id%\>" >nul
if errorlevel 1 (
    set "all_ids=!all_ids! %id%"
) else (
    call :debug "Skipping duplicate id from launch_monitor: %id%"
)
set "monitor_title=Monitor %id%"
set "all_monitor_titles=!all_monitor_titles! !monitor_title!"

:: Launch monitor.bat in a new minimized CMD session
if "!is_test!"=="0" (
    call :debug "Launching monitor.bat for !title!"
    start "Monitor !id!" /min cmd /c call monitor.bat "!device!" "!title!" "!posx!" "!posy!" "!id!" "!windowHeight!" monitor

    :: Small delay between launching each scrcpy monitor
    timeout /t 1 >nul
    if errorlevel 1 (
        echo Failed to start new window for %title%
    )
) else (
    call :debug "[TEST MODE] Skipping script generation and launch for %title%"
)

endlocal & (
    set "%return_ids%=%all_ids%"
    set "%return_titles%=%all_monitor_titles%"
)
exit /b

:loop
set "id=%~1"
set "all_ids=%~2"
echo.
echo Monitoring device connections... (ADB + Scrcpy in one window, Monitor is on another)
echo.

call :debug "[loop] all_ids: %all_ids%"
:: Await user input to quit
set /p userInput=Enter Q to quit (or press Enter to keep monitoring):

if /i "%userInput%"=="Q" (
	echo Shutting Down...
	call :debug "Id = %id%"
	call :debug "all_ids = %all_ids%"
	start "Shutdown %id%" /min cmd /c "call shutdownStream.bat "%id%" "%all_ids%""
	goto :eof
)

:: If blank input, reloop
if "%userInput%"=="" call :loop %id% "%all_ids%"

echo Invalid input: %userInput% - please enter Q or press Enter.
timeout /t 2 >nul
goto loop

:debug
if "%DEBUG_MODE%"=="1" echo [DEBUG] %~1
exit /b
