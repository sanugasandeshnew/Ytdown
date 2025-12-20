@echo off
title Ytdown - Professional Windows Downloader
color 0b
setlocal enabledelayedexpansion

:: --- Initialization & Dependency Check ---
:init
cls
echo =================================================
echo      Ytdown - PROFESSIONAL WINDOWS VERSION      
echo      Developed by SSK x Gemini
echo =================================================
echo.

if not exist "yt-dlp.exe" (
    echo [!] yt-dlp.exe not found. Downloading...
    powershell -Command "Invoke-WebRequest https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -OutFile yt-dlp.exe"
    echo [+] Download Complete!
    timeout /t 2 >nul
)

:: --- Main Menu ---
:menu
cls
echo =================================================
echo      Ytdown - MAIN MENU
echo =================================================
echo  1. Best MP4 (Video)
echo  2. Best MP3 (Audio)
echo  3. Playlist (Full)
echo  4. Playlist (Range)
echo  5. Cookie Settings
echo  0. Exit
echo =================================================
set /p opt="Select Option: "

if "%opt%"=="1" goto mp4
if "%opt%"=="2" goto mp3
if "%opt%"=="3" goto playlist
if "%opt%"=="4" goto range
if "%opt%"=="5" goto cookies
if "%opt%"=="0" exit
goto menu

:: --- Download Logic ---
:mp4
set /p url="🔗 Enter URL: "
if "%url%"=="" goto menu
echo.
echo 🚀 Downloading Best MP4...
if exist "cookies.txt" (
    yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 --cookies cookies.txt -o "%%(title)s.%%(ext)s" %url%
) else (
    yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "%%(title)s.%%(ext)s" %url%
)
pause
goto menu

:mp3
set /p url="🔗 Enter URL: "
if "%url%"=="" goto menu
echo.
echo 🚀 Downloading MP3...
if exist "cookies.txt" (
    yt-dlp -x --audio-format mp3 --cookies cookies.txt -o "%%(title)s.%%(ext)s" %url%
) else (
    yt-dlp -x --audio-format mp3 -o "%%(title)s.%%(ext)s" %url%
)
pause
goto menu

:playlist
set /p url="🔗 Enter Playlist URL: "
if "%url%"=="" goto menu
echo.
echo 🚀 Downloading Full Playlist...
yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:range
set /p url="🔗 Enter Playlist URL: "
set /p start="🔢 Start Index: "
set /p end="🔢 End Index: "
echo.
echo 🚀 Downloading Range %start% to %end%...
yt-dlp -f "bestvideo+bestaudio/best" --playlist-start %start% --playlist-end %end% --merge-output-format mp4 -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:cookies
cls
echo =================================================
echo      COOKIE MANAGER
echo =================================================
if exist "cookies.txt" (
    echo [STATUS] Cookies.txt FOUND and ACTIVE.
) else (
    echo [STATUS] Cookies.txt NOT FOUND.
    echo Tip: Place your 'cookies.txt' in this folder for private videos.
)
echo.
echo 1. Back to Menu
set /p copt="Selection: "
goto menu
