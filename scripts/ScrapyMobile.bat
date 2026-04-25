@echo off
title SCRCPY Device Selector
color 1f

:: Main menu loop
:menu
cls
echo ==========================================
echo       SELECT DEVICE (PRESS 1, 2, OR 3)
echo ==========================================
echo.
echo  [1] Samsung 2017 (5200d78bfa479449)
echo  [2] Galaxy J7 2016 (310008a89dd353f9)
echo  [3] Exit
echo.
echo ==========================================

:: Capture user input
choice /C 123 /N /M "Your choice: "

:: Handle choice logic
if errorlevel 3 exit
if errorlevel 2 goto device2
if errorlevel 1 goto device1

:device1
cls
echo Connecting to Samsung 2017...
.\scrcpy.exe -s 5200d78bfa479449
exit

:device2
cls
echo Connecting to Galaxy J7 2016...
.\scrcpy.exe -s 310008a89dd353f9
exit