@echo off
:: --- Tool Configuration ---
title Ytdown Pro - Windows Version
color 0b
setlocal enabledelayedexpansion

:: --- [ENTRY POINT / REFRESH] ---
:loading
cls
echo.
echo    Initializing System Packages...
echo    [#####---------------] 25%
timeout /t 1 >nul

:: --- [yt-dlp Engine Check] ---
if not exist "yt-dlp.exe" (
    cls
    echo.
    echo    Downloading Engine Components (yt-dlp)...
    echo    [##########----------] 50%
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -o yt-dlp.exe
)

:: --- [FFmpeg Smart Check & Auto-Install] ---
cls
echo.
echo    Checking for Media Components (FFmpeg)...
echo    [###############-----] 75%

set "ffmpeg_path="
:: 1. Check if FFmpeg is in PATH
where ffmpeg >nul 2>nul
if %errorlevel% equ 0 (
    set "ffmpeg_path=ffmpeg"
) else (
    :: 2. Check Winget default path
    set "w_path=%LOCALAPPDATA%\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.WinGet.Source_8wekyb3d8bbwe\ffmpeg-8.0.1-full_build\bin\ffmpeg.exe"
    if exist "!w_path!" (
        set "ffmpeg_path=!w_path!"
    ) else (
        cls
        echo.
        echo    Components missing! Attempting Auto-Installation...
        echo    Please wait, this may take a moment...
        :: Try silent install via Winget
        winget install Gyan.FFmpeg --silent --accept-source-agreements --accept-package-agreements >nul 2>nul
        
        :: Final Check
        where ffmpeg >nul 2>nul
        if %errorlevel% equ 0 (
            set "ffmpeg_path=ffmpeg"
        ) else if exist "!w_path!" (
            set "ffmpeg_path=!w_path!"
        ) else (
            set "ffmpeg_path=ffmpeg"
        )
    )
)

cls
echo.
echo    Ready to Use!
echo    [####################] 100%
timeout /t 1 >nul

:menu
cls
echo =================================================
echo      Ytdown - PROFESSIONAL WINDOWS VERSION      
echo      Developed by SSK x Gemini
echo =================================================
echo.
if exist "cookies.txt" (echo  [STATUS] Cookies: ACTIVE) else (echo  [STATUS] Cookies: MISSING)

:: Check if FFmpeg is actually usable now
where "!ffmpeg_path!" >nul 2>nul
if %errorlevel% equ 0 (
    echo  [STATUS] System Engine: READY
) else if exist "!ffmpeg_path!" (
    echo  [STATUS] System Engine: READY
) else (
    echo  [STATUS] System Engine: NOT FOUND
)

echo -------------------------------------------------
echo  1. Best MP4 (Single Video)
echo  2. Best MP3 (Single Audio)
echo  3. Playlist MP4 (Video Options)
echo  4. Playlist MP3 (Audio Options)
echo  5. Refresh Tool (Re-scan System)
echo  0. Exit
echo =================================================
set /p opt="Select Option: "

if "%opt%"=="1" goto mp4
if "%opt%"=="2" goto mp3
if "%opt%"=="3" goto pl_mp4
if "%opt%"=="4" goto pl_mp3
if "%opt%"=="5" goto loading
if "%opt%"=="0" exit
goto menu

:: --- [Download Execution Logic] ---

:mp4
set /p url="🔗 Enter URL: "
if "%url%"=="" goto menu
yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(title)s.%%(ext)s" %url%
pause
goto menu

:mp3
set /p url="🔗 Enter URL: "
if "%url%"=="" goto menu
yt-dlp -x --audio-format mp3 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp4
cls
echo =================================================
echo      PLAYLIST MP4 OPTIONS
echo =================================================
echo  1. Download Full Playlist
echo  2. Download Range
echo  3. Download Specific Index
echo  4. Back to Menu
echo =================================================
set /p sub="Selection: "
if "%sub%"=="1" goto pl_mp4_full
if "%sub%"=="2" goto pl_mp4_range
if "%sub%"=="3" goto pl_mp4_index
goto menu

:pl_mp3
cls
echo =================================================
echo      PLAYLIST MP3 OPTIONS
echo =================================================
echo  1. Download Full Playlist
echo  2. Download Range
echo  3. Download Specific Index
echo  4. Back to Menu
echo =================================================
set /p sub="Selection: "
if "%sub%"=="1" goto pl_mp3_full
if "%sub%"=="2" goto pl_mp3_range
if "%sub%"=="3" goto pl_mp3_index
goto menu

:: Playlist Commands
:pl_mp4_full
set /p url="🔗 Enter Playlist URL: "
yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp4_range
set /p url="🔗 Enter Playlist URL: "
set /p s="Start: "
set /p e="End: "
yt-dlp -f "bestvideo+bestaudio/best" --playlist-start %s% --playlist-end %e% --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp4_index
set /p url="🔗 Enter Playlist URL: "
set /p i="Index: "
yt-dlp -f "bestvideo+bestaudio/best" --playlist-items %i% --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp3_full
set /p url="🔗 Enter Playlist URL: "
yt-dlp -x --audio-format mp3 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp3_range
set /p url="🔗 Enter Playlist URL: "
set /p s="Start: "
set /p e="End: "
yt-dlp -x --audio-format mp3 --playlist-start %s% --playlist-end %e% --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp3_index
set /p url="🔗 Enter Playlist URL: "
set /p i="Index: "
yt-dlp -x --audio-format mp3 --playlist-items %i% --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu
