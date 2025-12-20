@echo off
:: --- Tool Name and Title Configuration ---
title Ytdown Pro - Windows Version
color 0b
setlocal enabledelayedexpansion

:loading
cls
echo.
echo    Initializing System Packages...
echo    [##########----------] 50%
timeout /t 1 >nul

:: --- [FFmpeg Auto-Detection Logic] ---
:: This section automatically detects the FFmpeg path for merging high-quality video/audio.
set "ffmpeg_path="

:: 1. Check if FFmpeg is available in the System PATH.
where ffmpeg >nul 2>nul
if %errorlevel% equ 0 (
    set "ffmpeg_path=ffmpeg"
) else (
    :: 2. Check common installation directories (including Winget default paths).
    :: Uses %LOCALAPPDATA% to ensure it works for any Windows user account.
    set "test_path1=%LOCALAPPDATA%\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.WinGet.Source_8wekyb3d8bbwe\ffmpeg-8.0.1-full_build\bin\ffmpeg.exe"
    set "test_path2=C:\ffmpeg\bin\ffmpeg.exe"
    set "test_path3=C:\Program Files\ffmpeg\bin\ffmpeg.exe"

    if exist "!test_path1!" (
        set "ffmpeg_path=!test_path1!"
    ) else if exist "!test_path2!" (
        set "ffmpeg_path=!test_path2!"
    ) else if exist "!test_path3!" (
        set "ffmpeg_path=!test_path3!"
    )
)

:: If FFmpeg is not found in common paths, default to "ffmpeg" string.
if "!ffmpeg_path!"=="" set "ffmpeg_path=ffmpeg"

cls
echo.
echo    Checking for Dependencies...
echo    [####################] 100%
timeout /t 1 >nul

:init
cls
echo =================================================
echo      Ytdown - PROFESSIONAL WINDOWS VERSION      
echo      Developed by SSK x Gemini
echo =================================================
echo.

:: --- [yt-dlp Dependency Check] ---
:: Checks for the core downloader engine (yt-dlp.exe).
:: If missing, it downloads the latest version automatically via curl.
if not exist "yt-dlp.exe" (
    echo [!] yt-dlp.exe not found. Installing...
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -o yt-dlp.exe
    echo [+] Installation Complete!
    timeout /t 2 >nul
)

:menu
cls
echo =================================================
echo      Ytdown - MAIN MENU
echo =================================================
:: Status Check: Cookies.txt
if exist "cookies.txt" (echo  [STATUS] Cookies: ACTIVE) else (echo  [STATUS] Cookies: MISSING)

:: Status Check: FFmpeg Environment
where "!ffmpeg_path!" >nul 2>nul
if %errorlevel% equ 0 (
    echo  [STATUS] FFmpeg: READY
) else if exist "!ffmpeg_path!" (
    echo  [STATUS] FFmpeg: READY
) else (
    echo  [STATUS] FFmpeg: NOT FOUND (Required for HQ Merging)
)

echo -------------------------------------------------
echo  1. Best MP4 (Single Video)
echo  2. Best MP3 (Single Audio)
echo  3. Playlist MP4 (Video Options)
echo  4. Playlist MP3 (Audio Options)
echo  5. Refresh Tool (Update Engine)
echo  0. Exit
echo =================================================
set /p opt="Select Option: "

if "%opt%"=="1" goto mp4
if "%opt%"=="2" goto mp3
if "%opt%"=="3" goto pl_mp4
if "%opt%"=="4" goto pl_mp3
if "%opt%"=="5" goto refresh
if "%opt%"=="0" exit
goto menu

:: --- [Playlist Sub-Menus] ---
:pl_mp4
cls
echo =================================================
echo      PLAYLIST MP4 OPTIONS
echo =================================================
echo  1. Download Full Playlist
echo  2. Download Range (e.g., 1-10)
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
echo  2. Download Range (e.g., 1-10)
echo  3. Download Specific Index
echo  4. Back to Menu
echo =================================================
set /p sub="Selection: "
if "%sub%"=="1" goto pl_mp3_full
if "%sub%"=="2" goto pl_mp3_range
if "%sub%"=="3" goto pl_mp3_index
goto menu

:: --- [Download Execution Logic] ---

:mp4
:: Downloads the best quality video and merges into MP4 format.
set /p url="🔗 Enter URL: "
if "%url%"=="" goto menu
yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(title)s.%%(ext)s" %url%
pause
goto menu

:mp3
:: Extracts high-quality audio and converts to MP3.
set /p url="🔗 Enter URL: "
if "%url%"=="" goto menu
yt-dlp -x --audio-format mp3 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp4_full
:: Downloads an entire playlist in MP4 format.
set /p url="🔗 Enter Playlist URL: "
yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp4_range
:: Downloads a specified range of videos from a playlist.
set /p url="🔗 Enter Playlist URL: "
set /p s="Start Index: "
set /p e="End Index: "
yt-dlp -f "bestvideo+bestaudio/best" --playlist-start %s% --playlist-end %e% --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp4_index
:: Downloads a single video from a playlist by its index number.
set /p url="🔗 Enter Playlist URL: "
set /p i="Index Number: "
yt-dlp -f "bestvideo+bestaudio/best" --playlist-items %i% --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp3_full
:: Downloads an entire playlist and converts all items to MP3.
set /p url="🔗 Enter Playlist URL: "
yt-dlp -x --audio-format mp3 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp3_range
:: Downloads a range of audio from a playlist.
set /p url="🔗 Enter Playlist URL: "
set /p s="Start Index: "
set /p e="End Index: "
yt-dlp -x --audio-format mp3 --playlist-start %s% --playlist-end %e% --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp3_index
:: Downloads a specific index from a playlist as MP3.
set /p url="🔗 Enter Playlist URL: "
set /p i="Index Number: "
yt-dlp -x --audio-format mp3 --playlist-items %i% --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:refresh
:: Deletes the local yt-dlp.exe and downloads the latest release from GitHub.
echo [!] Updating yt-dlp core engine...
del yt-dlp.exe
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -o yt-dlp.exe
echo [+] Successfully Updated to Latest Version!
pause
goto menu
