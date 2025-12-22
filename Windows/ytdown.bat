@echo off
setlocal enabledelayedexpansion
title Ytdown Pro - Professional Edition

:: --- [INITIAL DIRECTORY SETUP] ---
if not defined SAVE_DIR set "SAVE_DIR=%USERPROFILE%\Music\Ytdown"
if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"

:loading
cls
echo.
echo    === YTDOWN PRO - PROFESSIONAL WINDOWS ===
echo.
echo    Searching for required files...
timeout /t 1 >nul

<nul set /p "=    # finding yt-dlp... "
if not exist "yt-dlp.exe" (
    echo installing...
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -o yt-dlp.exe
) else (echo success.)

<nul set /p "=    # finding FFmpeg... "
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (echo missing!) else (echo success.)

timeout /t 1 >nul
echo.
echo    System Ready. Launching Menu...
timeout /t 1 >nul

:menu
cls
echo =================================================
echo      YTDOWN PRO - PROFESSIONAL WINDOWS
echo      Developed by SSK x Gemini
echo =================================================
echo  Save Path : %SAVE_DIR%
if exist "cookies.txt" (echo  Status    : Cookies ACTIVE) else (echo  Status    : Cookies MISSING)
where ffmpeg >nul 2>nul
if %errorlevel% equ 0 (echo  Engine    : FFmpeg INSTALLED) else (echo  Engine    : FFmpeg MISSING)
echo -------------------------------------------------
echo  1. Download MP3 (Song Name or Link)
echo  2. Download MP4 (Single Video)
echo  3. Playlist MP3 (Audio Options)
echo  4. Playlist MP4 (Video Options)
echo  5. Settings
echo  6. Update Tool (yt-dlp)
echo  0. Exit
echo =================================================
set /p opt="Select Option: "

if "%opt%"=="1" goto mp3
if "%opt%"=="2" goto mp4_menu
if "%opt%"=="3" goto pl_mp3_menu
if "%opt%"=="4" goto pl_mp4_menu
if "%opt%"=="5" goto settings
if "%opt%"=="6" goto update
if "%opt%"=="0" exit
goto menu

:: --- [SINGLE MP3] ---
:mp3
cls
set /p input="🎵 Enter Song Name or Link: "
if "%input%"=="" goto menu
yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --no-playlist --no-overwrites --cookies cookies.txt -o "%SAVE_DIR%\%%(title)s.%%(ext)s" "ytsearch1:%input%"
pause
goto menu

:: --- [SINGLE MP4 QUALITY MENU] ---
:mp4_menu
cls
echo =================================================
echo        SELECT VIDEO QUALITY
echo =================================================
echo  1. Best Quality (4K/2K Support)
echo  2. 1080p
echo  3. 720p
echo  4. 480p
echo  5. 360p
echo  0. Back
echo =================================================
set /p q="Selection: "
if "%q%"=="1" set "f_code=bv+ba/b"
if "%q%"=="2" set "f_code=bv*[height<=1080]+ba/b[height<=1080]"
if "%q%"=="3" set "f_code=bv*[height<=720]+ba/b[height<=720]"
if "%q%"=="4" set "f_code=bv*[height<=480]+ba/b[height<=480]"
if "%q%"=="5" set "f_code=bv*[height<=360]+ba/b[height<=360]"
if "%q%"=="0" goto menu
if not defined f_code goto mp4_menu

set /p url="🔗 Enter Video URL: "
if "%url%"=="" goto menu
yt-dlp -f "%f_code%" --merge-output-format mp4 --no-playlist --cookies cookies.txt -o "%SAVE_DIR%\%%(title)s.%%(ext)s" "%url%"
set "f_code="
pause
goto menu

:: --- [PLAYLIST MP3 MENU] ---
:pl_mp3_menu
cls
echo =================================================
echo        PLAYLIST MP3 OPTIONS
echo =================================================
echo  1. All Items
echo  2. Select Range (Start-End)
echo  3. New Items Only (Skip existing)
echo  0. Back
echo =================================================
set /p p_opt="Selection: "
if "%p_opt%"=="0" goto menu
set /p url="🔗 Enter Playlist URL: "
if "%p_opt%"=="1" set "p_cmd="
if "%p_opt%"=="2" (
    set /p s="Start Index: "
    set /p e="End Index: "
    set "p_cmd=--playlist-start !s! --playlist-end !e!"
)
if "%p_opt%"=="3" set "p_cmd=--download-archive %SAVE_DIR%\archive.txt"

:: Adding --extractor-args to bypass authentication check for playlists
yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata !p_cmd! --no-overwrites --cookies cookies.txt --extractor-args "youtubetab:skip=authcheck" -o "%SAVE_DIR%\%%(playlist_title)s\%%(title)s.%%(ext)s" "%url%"
pause
goto menu

:: --- [PLAYLIST MP4 MENU] ---
:pl_mp4_menu
cls
echo =================================================
echo        PLAYLIST MP4 OPTIONS
echo =================================================
echo  1. All Items
echo  2. Select Range (Start-End)
echo  3. New Items Only (Skip existing)
echo  0. Back
echo =================================================
set /p p_opt="Selection: "
if "%p_opt%"=="0" goto menu
set /p url="🔗 Enter Playlist URL: "
if "%p_opt%"=="1" set "p_cmd="
if "%p_opt%"=="2" (
    set /p s="Start Index: "
    set /p e="End Index: "
    set "p_cmd=--playlist-start !s! --playlist-end !e!"
)
if "%p_opt%"=="3" set "p_cmd=--download-archive %SAVE_DIR%\archive.txt"

:: Adding --extractor-args to bypass authentication check for playlists
yt-dlp -f "bv+ba/b" --merge-output-format mp4 !p_cmd! --cookies cookies.txt --extractor-args "youtubetab:skip=authcheck" -o "%SAVE_DIR%\%%(playlist_title)s\%%(title)s.%%(ext)s" "%url%"
pause
goto menu

:: --- [SETTINGS & UPDATE] ---
:settings
cls
echo =================================================
echo                SETTINGS
echo =================================================
echo  1. Create/Edit cookies.txt (Notepad)
echo  2. Watch Tutorial (YouTube Short)
echo  3. Back to Main Menu
echo -------------------------------------------------
echo  4. Browse where want to download
echo =================================================
set /p sopt="Selection: "
if "%sopt%"=="1" (if not exist "cookies.txt" echo # Netscape > cookies.txt & notepad cookies.txt)
if "%sopt%"=="2" (start https://youtube.com/shorts/80DRIzKOknU?feature=share)
if "%sopt%"=="4" (
    set /p new_path="Enter New Folder Path: "
    if not "!new_path!"=="" (set "SAVE_DIR=!new_path!" & if not exist "!new_path!" mkdir "!new_path!")
)
goto menu

:update
cls
yt-dlp -U
pause
goto menu
