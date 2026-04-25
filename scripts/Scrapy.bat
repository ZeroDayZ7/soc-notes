@echo off
title Wybor urzadzenia scrcpy
color 1f

:menu
cls
echo ==========================================
echo    WYBIERZ URZADZENIE (KLIKNIJ 1 LUB 2)
echo ==========================================
echo.
echo  [1] Telefon 1 (5200d78bfa479449)
echo  [2] Telefon 2 (310008a89dd353f9)
echo  [3] Wyjscie
echo.
echo ==========================================

choice /C 123 /N /M "Twoj wybor: "

if errorlevel 3 exit
if errorlevel 2 goto device2
if errorlevel 1 goto device1

:device1
cls
echo Laczenie z 5200d78bfa479449...
.\scrcpy.exe -s 5200d78bfa479449
exit

:device2
cls
echo Laczenie z 310008a89dd353f9...
.\scrcpy.exe -s 310008a89dd353f9
exit