@echo off
setlocal enabledelayedexpansion

:: Device info
set device1=100.106.179.83:15556
set title1=Pixel2XL

set device2=100.119.220.3:15557
set title2=Pixel3XL

set device3=100.95.224.103:15555
set title3=Note20Ultra

:: Launch all devices
call :launch_monitor "!title1!" "!device1!" 0 40
call :launch_monitor "!title2!" "!device2!" 640 40
call :launch_monitor "!title3!" "!device3!" 1280 40

goto :monitor_loop

:launch_monitor
set "title=%~1"
set "device=%~2"
set "posx=%~3"
set "posy=%~4"

:: Write temp batch file to monitor this device
set "script=launch_%title%.bat"

(
    echo @echo off
    echo :retry
    echo echo [%title%] launching scrcpy...
    echo adb connect %device%
    echo start "" /wait scrcpy -s %device% --window-title="%title%" --window-x=%posx% --window-y=%posy% --window-width=640 --window-height=1080 --no-audio
    echo echo [%title%] scrcpy closed or disconnected. Reconnecting...
    echo timeout /t 3 ^>nul
    echo goto retry
) > "%script%"

:: Start it in a new cmd window
start "%title%" cmd /c "%script%"
exit /b

:monitor_loop
echo.
echo Monitoring device connections... (ADB + Scrcpy restart logic)
echo Press Q then [Enter] at any time to quit and close scrcpy sessions.
echo.

:loop
set /p userInput=Enter Q to quit (or press Enter to keep monitoring):

if /i "!userInput!"=="Q" (
    echo Shutting down...
    taskkill /f /im scrcpy.exe >nul 2>&1
    taskkill /f /im cmd.exe /fi "WINDOWTITLE eq Pixel2XL" >nul 2>&1
    taskkill /f /im cmd.exe /fi "WINDOWTITLE eq Pixel3XL" >nul 2>&1
    taskkill /f /im cmd.exe /fi "WINDOWTITLE eq Note20Ultra" >nul 2>&1
    echo Cleaning up temp scripts...
    del /f /q launch_Pixel2XL.bat >nul 2>&1
    del /f /q launch_Pixel3XL.bat >nul 2>&1
    del /f /q launch_Note20Ultra.bat >nul 2>&1
    echo All scrcpy sessions terminated. You may now close this window.
    pause >nul
    exit /b
)

:: Reconnect devices if they disappear
adb devices | findstr /i "%device1%" >nul || (
    echo [%title1%] ADB dropped - reconnecting...
    adb connect %device1%
)

adb devices | findstr /i "%device2%" >nul || (
    echo [%title2%] ADB dropped - reconnecting...
    adb connect %device2%
)

adb devices | findstr /i "%device3%" >nul || (
    echo [%title3%] ADB dropped - reconnecting...
    adb connect %device3%
)

timeout /t 10 >nul
goto loop

