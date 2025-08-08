@echo off
setlocal enabledelayedexpansion
call load_devices.bat

:: Show devices to confirm they're loaded
echo Loaded %deviceCount% devices.
for /L %%i in (1,1,%deviceCount%) do (
    call echo Device %%i = %%device%%i%%
)

echo.

:: Now restart Pokémon GO on each device
for /L %%i in (1,1,%deviceCount%) do (
    call set "device=%%device%%i%%"

    adb -s !device! reboot
)

pause