@echo off
setlocal enabledelayedexpansion

call load_devices.bat

:: Show devices to confirm they're loaded
echo Loaded %deviceCount% devices.
for /L %%i in (1,1,%deviceCount%) do (
    call echo Device %%i = %%device%%i%%
)

echo.

:: Connect to all devices
for /L %%i in (1,1,%deviceCount%) do (
    call set "device=%%device%%i%%"
    echo Connecting to !device!...
    adb connect !device!
)

echo.
echo All devices should now be connected.
pause
