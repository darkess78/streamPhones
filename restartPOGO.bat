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
    echo Restarting Pokemon GO on device %%i: !device!

    adb -s !device! shell am force-stop com.nianticlabs.pokemongo >nul 2>&1
    adb -s !device! shell monkey -p com.nianticlabs.pokemongo -c android.intent.category.LAUNCHER 1 >nul 2>&1
)

pause
