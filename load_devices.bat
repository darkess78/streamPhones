@echo off
setlocal enabledelayedexpansion

:: Clear existing values
for /L %%i in (1,1,20) do (
    set "device%%i="
    set "title%%i="
)

set count=1

:: Read title and IP from each line
for /f "usebackq tokens=1,2 delims=," %%A in ("devices.txt") do (
    call set "title%%count%%=%%A"
    call set "device%%count%%=%%B"
    set /a count+=1
)

set /a deviceCount=count-1

:: Export everything to parent
(
    echo @echo off
    echo set deviceCount=%deviceCount%
    for /L %%i in (1,1,%deviceCount%) do (
        call echo set device%%i=%%device%%i%%
        call echo set title%%i=%%title%%i%%
    )
) > _load_devices_env.bat

endlocal
call _load_devices_env.bat
del _load_devices_env.bat >nul 2>&1