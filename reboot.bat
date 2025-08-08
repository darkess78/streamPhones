@echo off
setlocal enabledelayedexpansion
call load_devices.bat

:: Show devices to confirm they're loaded
echo Loaded %deviceCount% devices.
for /L %%i in (1,1,%deviceCount%) do (
    call echo Device %%i = %%device%%i%%
)

echo.

:: Now restart each device
for /L %%i in (1,1,%deviceCount%) do (
    call set "device=%%device%%i%%"

    scrcpy3.2\adb -s !device! reboot
)

pause
