@echo off
:: Script to manage and open Windows Start Menu Programs folders
title Start Menu Folder Selector
color 1f

:menu
cls
echo ==========================================
echo      SELECT FOLDER (PRESS 1, 2, OR 3)
echo ==========================================
echo.
echo  [1] Open Local Programs Folder
echo  [2] Open Global Programs Folder
echo  [3] Exit
echo.
echo ==========================================

:: Capture user input without requiring Enter
choice /C 123 /N /M "Your choice: "

:: Handle choice logic
if errorlevel 3 exit
if errorlevel 2 goto global
if errorlevel 1 goto local

:local
cls
echo Opening Local Programs folder...
explorer "%APPDATA%\Microsoft\Windows\Start Menu\Programs"
exit

:global
cls
echo Opening Global Programs folder...
explorer "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
exit