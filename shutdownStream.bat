@echo off
setlocal enabledelayedexpansion

echo [%time%] shutdownStream.bat started with args: %* > shutdown.log
echo shutdown > shutdown.flag

:: Arguments:
:: %1 = id
:: %2 = all_ids

set "id=%~1"
set "all_ids=%~2"

:: Kill CMD windows launched for this session
for %%i in (!all_ids!) do (
    echo Killing Monitor %%i >> shutdown.log
    for /f "tokens=2 delims=," %%p in ('tasklist /v /fo csv ^| findstr /i /c:"\"cmd.exe\"" ^| findstr /r /c:"\"Monitor %%i\"$"') do (
        echo Taskkill for PID: %%p >> shutdown.log
        taskkill /f /pid %%p >nul 2>&1
    )
)

:: Terminate scrcpy if still running
tasklist /fi "imagename eq scrcpy.exe" | find /i "scrcpy.exe" >nul
if not errorlevel 1 (
	echo Terminating scrcpy processes...
	taskkill /f /im scrcpy.exe >nul 2>&1
)

timeout /t 1 >nul

:: Clean up temporary files
echo Cleaning up temp scripts...
for %%i in (%id%) do (
	::launch_2716682_Pixel2XL.lock
	::Monitor 2716682_Pixel2XL
	::if exist "launch_%%i.bat" del /f /q "launch_%%i.bat"
	if exist "scrcpy_%%i.log" del /f /q "scrcpy_%%i.log"
	::if exist "pause_%%i.flag" del /f /q "pause_%%i.flag"
	if exist "shutdown.flag" del /f /q "shutdown.flag"
)

if exist launch_*.lock del /f /q launch_*.lock >nul 2>&1

echo All scrcpy sessions terminated. You may now close this window.
::pause >nul
echo [%time%] Finished shutdown. >> shutdown.log

exit /b