@echo off
setlocal enabledelayedexpansion
title Ytdown Pro - Professional Media Downloader

set "target_name=Ytdown Pro.bat"
if /i not "%~nx0"=="!target_name!" (rename "%~f0" "!target_name!")

set "shortcut=%USERPROFILE%\Desktop\Ytdown Pro.lnk"
if not exist "!shortcut!" (
    powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%shortcut%');$s.TargetPath='%~dp0!target_name!';$s.IconLocation='imageres.dll,162';$s.Save()"
)

if not defined SAVE_DIR set "SAVE_DIR=%USERPROFILE%\Music\Ytdown"
if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"

:loading
cls
echo.
echo    ------------------------------------------
echo       INITIALIZING YTDOWN PRO COMPONENTS...
echo    ------------------------------------------
if not exist "yt-dlp.exe" (
    echo    # Installing Download Engine...
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -o yt-dlp.exe
)
where ffmpeg >nul 2>nul
timeout /t 1 >nul

:menu
cls
color 0b
echo =================================================
echo      YTDOWN PRO - PROFESSIONAL WINDOWS
echo      Developed by SSK x Gemini
echo =================================================
echo  Save Path : %SAVE_DIR%
if exist "cookies.txt" (echo  Status    : Cookies ACTIVE) else (echo  Status    : Cookies MISSING)
echo -------------------------------------------------
echo  1. Download MP3 (Song Name or Link)
echo  2. Download MP4 (Single Video Quality)
echo  3. Playlist MP3 (High Quality Audio)
echo  4. Playlist MP4 (Video Quality Options)
echo  5. Settings (Download Path / Cookies)
echo  6. Update Download Engine (yt-dlp)
echo  0. Exit
echo =================================================
set /p opt="Select Option: "

if "%opt%"=="1" goto mp3
if "%opt%"=="2" goto mp4_menu
if "%opt%"=="3" goto pl_mp3
if "%opt%"=="4" goto pl_mp4
if "%opt%"=="5" goto settings
if "%opt%"=="6" goto update
if "%opt%"=="0" exit
goto menu

:mp3
cls
echo [SINGLE MP3 DOWNLOAD]
set /p input="Enter Song Name or Link: "
if "%input%"=="" goto menu
echo %input% | findstr /i "http" >nul
if %errorlevel%==0 (set "target=%input%") else (set "target=ytsearch1:%input%")
yt-dlp --cookies cookies.txt -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --no-playlist --no-overwrites -o "%SAVE_DIR%\%%(title)s.%%(ext)s" "!target!"
pause
goto menu

:mp4_menu
cls
echo [VIDEO QUALITY SELECTION]
echo  1. Best Available | 2. 720p | 3. 480p | 0. Back
set /p q="Selection: "
if "%q%"=="1" set "f_code=bv+ba/b"
if "%q%"=="2" set "f_code=bv*[height<=720]+ba/b[height<=720]"
if "%q%"=="3" set "f_code=bv*[height<=480]+ba/b[height<=480]"
if "%q%"=="0" goto menu
set /p url="Enter Video URL: "
yt-dlp -f "%f_code%" --merge-output-format mp4 --no-playlist --cookies cookies.txt -o "%SAVE_DIR%\%%(title)s.%%(ext)s" "%url%"
pause
goto menu

:pl_mp3
cls
set /p url="Enter Playlist URL: "
yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --cookies cookies.txt --extractor-args "youtubetab:skip=authcheck" -o "%SAVE_DIR%\%%(playlist_title)s\%%(title)s.%%(ext)s" "%url%"
pause
goto menu

:pl_mp4
cls
set /p url="Enter Playlist URL: "
yt-dlp -f "bv+ba/b" --merge-output-format mp4 --cookies cookies.txt --extractor-args "youtubetab:skip=authcheck" -o "%SAVE_DIR%\%%(playlist_title)s\%%(title)s.%%(ext)s" "%url%"
pause
goto menu

:settings
cls
echo [SETTINGS]
echo  1. Change Download Folder
echo  2. Get Cookie Extension
echo  3. How to use Cookies
echo  4. Import Cookies from Clipboard
echo  0. Back
set /p sopt="Selection: "
if "%sopt%"=="1" (
    set /p np="Enter Full Path: "
    if not "!np!"=="" (set "SAVE_DIR=!np!" & if not exist "!np!" mkdir "!np!")
)
if "%sopt%"=="2" (start https://chromewebstore.google.com/detail/cclelndahbckbenkjhflpdbgdldlbecc)
if "%sopt%"=="3" (
    echo 1. Install Extension. 2. Login to YT. 3. Export. 4. Use Option 4 here.
    pause
)
if "%sopt%"=="4" (
    powershell -Command "Get-Clipboard | Out-File -FilePath 'cookies.txt' -Encoding ascii"
    if exist "cookies.txt" (echo Cookies imported!)
    pause
)
goto menu

:update
cls
yt-dlp -U
pause
goto menu
