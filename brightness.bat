@echo off
setlocal enabledelayedexpansion
call load_devices.bat

:: Show devices to confirm they're loaded
echo Loaded %deviceCount% devices.
for /L %%i in (1,1,%deviceCount%) do (
    call echo Device %%i = %%device%%i%%
)

echo.

:: Set device screen brightness to 0
for /L %%i in (1,1,%deviceCount%) do (
    call set "device=%%device%%i%%"
	REM adb -s !device! shell settings get system screen_brightness
    adb -s !device! shell settings put system screen_brightness 0
)

pause
