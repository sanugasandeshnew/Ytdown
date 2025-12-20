@echo off
title Ytdown Pro - Windows Version
color 0b
setlocal enabledelayedexpansion

:loading
cls
echo.
echo    Initializing System Packages...
echo    [##########----------] 50%%
timeout /t 1 >nul

:: --- FFmpeg Auto-Detection Logic ---
set "ffmpeg_path=ffmpeg"
where ffmpeg >nul 2>nul
if %errorlevel% equ 0 (
    set "ffmpeg_path=ffmpeg"
) else (
    if exist "C:\Users\sanug\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.0.1-full_build\bin\ffmpeg.exe" (
        set "ffmpeg_path=C:\Users\sanug\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winet.Source_8wekyb3d8bbwe\ffmpeg-8.0.1-full_build\bin\ffmpeg.exe"
    ) else (
        for /r "C:\Program Files" %%i in (ffmpeg.exe) do if exist "%%i" set "ffmpeg_path=%%i"
    )
)

cls
echo.
echo    Checking for Dependencies...
echo    [####################] 100%%
timeout /t 1 >nul

:init
cls
echo =================================================
echo      Ytdown - PROFESSIONAL WINDOWS VERSION      
echo      Developed by SSK x Gemini
echo =================================================
echo.

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
if exist "cookies.txt" (echo  [STATUS] Cookies: ACTIVE) else (echo  [STATUS] Cookies: MISSING)
echo  [STATUS] FFmpeg: !ffmpeg_path!
echo -------------------------------------------------
echo  1. Best MP4 (Single Video)
echo  2. Best MP3 (Single Audio)
echo  3. Playlist MP4 (Video)
echo  4. Playlist MP3 (Audio)
echo  5. Refresh Tool (Update yt-dlp)
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

:: --- SUB MENUS ---

:pl_mp4
cls
echo =================================================
echo      PLAYLIST MP4 OPTIONS
echo =================================================
echo  1. Download Full Playlist
echo  2. Download Range (e.g. 1-10)
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
echo  2. Download Range (e.g. 1-10)
echo  3. Download Specific Index
echo  4. Back to Menu
echo =================================================
set /p sub="Selection: "
if "%sub%"=="1" goto pl_mp3_full
if "%sub%"=="2" goto pl_mp3_range
if "%sub%"=="3" goto pl_mp3_index
goto menu

:: --- DOWNLOAD LOGIC ---

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

:pl_mp4_full
set /p url="🔗 Enter Playlist URL: "
yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp4_range
set /p url="🔗 Enter Playlist URL: "
set /p s="Start Index: "
set /p e="End Index: "
yt-dlp -f "bestvideo+bestaudio/best" --playlist-start %s% --playlist-end %e% --merge-output-format mp4 --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp4_index
set /p url="🔗 Enter Playlist URL: "
set /p i="Index Number: "
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
set /p s="Start Index: "
set /p e="End Index: "
yt-dlp -x --audio-format mp3 --playlist-start %s% --playlist-end %e% --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:pl_mp3_index
set /p url="🔗 Enter Playlist URL: "
set /p i="Index Number: "
yt-dlp -x --audio-format mp3 --playlist-items %i% --ffmpeg-location "!ffmpeg_path!" --cookies cookies.txt -o "%%(playlist_title)s/%%(title)s.%%(ext)s" %url%
pause
goto menu

:refresh
echo [!] Updating yt-dlp to latest version...
del yt-dlp.exe
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -o yt-dlp.exe
echo [+] Successfully Updated!
pause
goto menu
