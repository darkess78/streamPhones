@echo off
setlocal

echo Pixel2XL Pairing Code: 240781
adb pair 100.106.179.83:41451
echo.

echo Pixel3XL Pairing Code: 518427
adb pair 100.119.220.3:37837
echo.

echo Note20Ultra Pairing Code: 030237
adb pair 100.64.137.98:40825
echo.

echo All devices should now be paired.
pause
