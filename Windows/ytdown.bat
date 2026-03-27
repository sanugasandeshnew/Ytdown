@echo off
setlocal enabledelayedexpansion
title Ytdown Pro - Professional Media Downloader

:: --- Configuration ---
set "target_name=Ytdown Pro.bat"
:: Using a reliable source for FFmpeg essentials zip
set "ffmpeg_url=https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
set "ffmpeg_zip_name=ffmpeg-master-latest-win64-gpl.zip"
set "ffmpeg_extract_dir_pattern=ffmpeg-master-latest-win64-gpl"
set "yt_dlp_exe_name=yt-dlp.exe"
set "js_runtime=--js-runtimes node"
set "cookie_file=cookies.txt"

:: --- Script Initialization ---

:: Rename script if needed (e.g., if it was saved with a different name)
if /i not "%~nx0"=="!target_name!" (rename "%~f0" "!target_name!")

:: Create desktop shortcut if it doesn't exist
set "shortcut=%USERPROFILE%\Desktop\Ytdown Pro.lnk"
if not exist "!shortcut!" (
    powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%shortcut%');$s.TargetPath='%~dp0!target_name!';$s.IconLocation='imageres.dll,162';$s.Save()"
)

:: Default save directory - can be changed in settings.
:: If script is saved to D:\, this will be C:\Users\sanug\Music\Ytdown unless changed.
if not defined SAVE_DIR set "SAVE_DIR=%USERPROFILE%\Music\Ytdown"
if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"

:: --- Dependency Check and Installation ---
:dependency_check
cls
echo.
echo    ------------------------------------------
echo       INITIALIZING YTDOWN PRO COMPONENTS...
echo    ------------------------------------------

:: Check for yt-dlp.exe in the script's directory
if not exist "%~dp0%yt_dlp_exe_name%" (
    echo    # Downloading %yt_dlp_exe_name%...
    :: Ensure the download target path includes the script's directory
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/%yt_dlp_exe_name% -o "%~dp0%yt_dlp_exe_name%"
    if errorlevel 1 (
        echo    ERROR: Failed to download %yt_dlp_exe_name%. Please check your internet connection and try again.
        pause
        goto :eof
    )
    echo    # %yt_dlp_exe_name% installed successfully.
) else (
    echo    # %yt_dlp_exe_name% found. Skipping download.
)

:: Check for FFmpeg.
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo    # FFmpeg not found in system PATH. Checking local installation...
    set "ffmpeg_found_flag=0"

    :: 1. Check for LOCAL EXTRACTED FFmpeg folder
    for /f "delims=" %%d in ('dir /b /ad "%~dp0ffmpeg-*" 2^>nul') do (
        if exist "%~dp0%%d\bin\ffmpeg.exe" (
            set "PATH=%~dp0%%d\bin;%PATH%"
            echo    # Local FFmpeg installation found. Added to PATH for this session.
            set "ffmpeg_found_flag=1"
            goto ffmpeg_ok
        )
    )

    :: 2. If no local extracted FFmpeg, check for the ZIP file
    if "%ffmpeg_found_flag%"=="0" (
        if exist "%~dp0%ffmpeg_zip_name%" (
            echo    # FFmpeg zip file found. Skipping download, proceeding to extraction.
        ) else (
            echo    # FFmpeg not found locally. Attempting to download FFmpeg...
            echo    This may take a few moments.
            curl -L "%ffmpeg_url%" -o "%~dp0%ffmpeg_zip_name%"
            if errorlevel 1 (
                echo    ERROR: Failed to download FFmpeg. Please ensure FFmpeg is installed and in your PATH, or download it manually from https://ffmpeg.org/download.html
                pause
                goto :eof
            )
        )

        :: Now, ensure the zip exists and extract it
        if exist "%~dp0%ffmpeg_zip_name%" (
            echo    # Extracting FFmpeg...
            powershell -Command "Expand-Archive -Path '%~dp0%ffmpeg_zip_name%' -DestinationPath '%~dp0' -Force"
            if errorlevel 1 (
                echo    ERROR: Failed to extract FFmpeg. Please ensure you have a tool like 7-Zip or WinRAR installed, or extract the zip manually.
                del "%~dp0%ffmpeg_zip_name%" >nul 2>nul
                pause
                goto :eof
            )

            :: After extraction, set PATH and confirm
            for /f "delims=" %%d in ('dir /b /ad "%~dp0ffmpeg-*" 2^>nul') do (
                if exist "%~dp0%%d\bin\ffmpeg.exe" (
                    set "PATH=%~dp0%%d\bin;%PATH%"
                    echo    # FFmpeg installed and added to PATH for this session.
                    set "ffmpeg_found_flag=1"
                )
            )
            if "%ffmpeg_found_flag%"=="0" (
                echo    ERROR: Could not find extracted FFmpeg directory after extraction. Please install FFmpeg manually.
                pause
                goto :eof
            )
        ) else (
            echo    ERROR: FFmpeg zip file is missing after download attempt. Cannot proceed.
            pause
            goto :eof
        )
    )
) else (
    echo    # FFmpeg found in system PATH.
)
:ffmpeg_ok

timeout /t 1 >nul

:: --- Main Menu ---
:menu
cls
color 0b
echo =================================================
echo      YTDOWN PRO - PROFESSIONAL WINDOWS
echo      Developed by SSK x Gemini
echo =================================================
echo  Save Path : %SAVE_DIR%
if exist "%~dp0%cookie_file%" (echo  Status    : Cookies ACTIVE) else (echo  Status    : Cookies MISSING)
echo -------------------------------------------------
echo  1. Download MP3 (Song Name or Link)
echo  2. Download MP4 (Single Video Quality)
echo  3. Playlist MP3 (High Quality Audio)
echo  4. Playlist MP4 (Video Quality Options)
echo  5. Settings (Download Path / Cookies)
echo  6. Update Download Engine (%yt_dlp_exe_name%)
echo  7. Update FFmpeg
echo  0. Exit
echo =================================================
set /p opt="Select Option: "

if "%opt%"=="1" goto mp3
if "%opt%"=="2" goto mp4_menu
if "%opt%"=="3" goto pl_mp3
if "%opt%"=="4" goto pl_mp4
if "%opt%"=="5" goto settings
if "%opt%"=="6" goto update_ytdlp
if "%opt%"=="7" goto update_ffmpeg
if "%opt%"=="0" exit /b
goto menu

:: --- Download Functions ---
:mp3
cls
echo [SINGLE MP3 DOWNLOAD]
set /p input="Enter Song Name or Link: "
if "%input%"=="" goto menu

:: Determine target: use URL directly if it looks like one, otherwise use ytsearch1:
echo %input% | findstr /i "http" >nul
if %errorlevel%==0 (set "target=%input%") else (set "target=ytsearch1:%input%")

echo Downloading: %target%
"%~dp0%yt_dlp_exe_name%" %js_runtime% --cookies "%~dp0%cookie_file%" -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --no-playlist --no-overwrites -o "%SAVE_DIR%\%%(title)s.%%(ext)s" "%target%"
if errorlevel 1 (echo ERROR: Download failed. Check URL/Search term and internet connection.) else (echo Download complete!)
pause
goto menu

:mp4_menu
cls
echo [VIDEO QUALITY SELECTION]
echo  1. Best Available (Default)
echo  2. 720p
echo  3. 480p
echo  0. Back
set /p q="Selection: "
if "%q%"=="1" set "f_code=bv+ba/b"
if "%q%"=="2" set "f_code=bv*[height<=720]+ba/b[height<=720]"
if "%q%"=="3" set "f_code=bv*[height<=480]+ba/b[height<=480]"
if "%q%"=="0" goto menu
if not defined f_code (echo Invalid selection. Returning to menu.) & pause & goto menu

set /p url="Enter Video URL: "
if "%url%"=="" goto menu

echo Downloading: %url% with format %f_code%
"%~dp0%yt_dlp_exe_name%" %js_runtime% -f "%f_code%" --merge-output-format mp4 --no-playlist --cookies "%~dp0%cookie_file%" -o "%SAVE_DIR%\%%(title)s.%%(ext)s" "%url%"
if errorlevel 1 (echo ERROR: Download failed. Check URL and internet connection.) else (echo Download complete!)
pause
goto menu

:pl_mp3
cls
set /p url="Enter Playlist URL: "
if "%url%"=="" goto menu

echo Downloading playlist as MP3: %url%
"%~dp0%yt_dlp_exe_name%" %js_runtime% -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --cookies "%~dp0%cookie_file%" --extractor-args "youtubetab:skip=authcheck" -o "%SAVE_DIR%\%%(playlist_title)s\%%(title)s.%%(ext)s" "%url%"
if errorlevel 1 (echo ERROR: Playlist download failed. Check URL and internet connection.) else (echo Playlist download complete!)
pause
goto menu

:pl_mp4
cls
set /p url="Enter Playlist URL: "
if "%url%"=="" goto menu

echo Downloading playlist as MP4: %url%
"%~dp0%yt_dlp_exe_name%" %js_runtime% -f "bv+ba/b" --merge-output-format mp4 --cookies "%~dp0%cookie_file%" --extractor-args "youtubetab:skip=authcheck" -o "%SAVE_DIR%\%%(playlist_title)s\%%(title)s.%%(ext)s" "%url%"
if errorlevel 1 (echo ERROR: Playlist download failed. Check URL and internet connection.) else (echo Playlist download complete!)
pause
goto menu

:: --- Settings and Updates ---
:settings
cls
echo [SETTINGS]
echo  Current Save Path : %SAVE_DIR%
echo  Current Cookie File : %~dp0%cookie_file%
echo -------------------------------------------------
echo  1. Change Download Folder
echo  2. Get Cookie Extension (for Chrome/Edge)
echo  3. How to Use Cookies
echo  4. Import Cookies from Clipboard
echo  5. Delete Cookie File
echo  0. Back
set /p sopt="Selection: "

if "%sopt%"=="1" (
    set /p np="Enter Full Path for Downloads (e.g., D:\MyMusic): "
    if not "!np!"=="" (
        set "SAVE_DIR=!np!"
        if not exist "!np!" (
            mkdir "!np!"
            if errorlevel 1 (echo ERROR: Could not create directory. Please check permissions.) else (echo Directory created.)
        ) else (echo Directory already exists.)
        echo Save directory set to: %SAVE_DIR%
    ) else (echo No path entered. Keeping current.)
    pause
)
if "%sopt%"=="2" (start "" "https://chromewebstore.google.com/detail/cclelndahbckbenkjhflpdbgdldlbecc")
if "%sopt%"=="3" (
    echo.
    echo To use cookies:
    echo 1. Install the "Get cookies.txt LOCALLY" browser extension (link in option 2).
    echo 2. Log in to YouTube in your browser.
    echo 3. Navigate to a YouTube page (e.g., homepage).
    echo 4. Click the extension icon and select "Export".
    echo 5. Copy the entire output.
    echo 6. Select option 4 ("Import Cookies from Clipboard") in this script.
    echo 7. The "cookies.txt" file will be created in the same folder as this script.
    echo 8. yt-dlp will automatically use it when available.
    echo.
    pause
)
if "%sopt%"=="4" (
    echo Reading clipboard for cookies.txt content...
    powershell -Command "Get-Clipboard -Raw | Out-File -FilePath '%~dp0%cookie_file%' -Encoding ascii -Force"
    
    :: Check if the file exists AND has content
    for %%F in ("%~dp0%cookie_file%") do set "file_size=%%~zF"
    if exist "%~dp0%cookie_file%" (
        if "!file_size!" gtr "0" (
            echo Cookies imported successfully!
        ) else (
            echo WARNING: Cookies.txt was created but is empty. Please ensure you copied the cookie content to the clipboard.
            del "%~dp0%cookie_file%" >nul 2>nul
        )
    ) else (
        echo ERROR: Failed to create or write cookies.txt. Please ensure you copied content and have permissions.
    )
    pause
)
if "%sopt%"=="5" (
    if exist "%~dp0%cookie_file%" (
        del "%~dp0%cookie_file%"
        echo Cookie file deleted.
    ) else (echo Cookie file not found.)
    pause
)
if "%sopt%"=="0" goto menu
goto menu

:update_ytdlp
cls
echo Updating %yt_dlp_exe_name%...
:: Use "%~dp0%yt_dlp_exe_name%" to call the yt-dlp in the script's directory
"%~dp0%yt_dlp_exe_name%" -U
if errorlevel 1 (echo ERROR: Update failed. Check internet connection or permissions.) else (echo %yt_dlp_exe_name% updated successfully!)
pause
goto menu

:update_ffmpeg
cls
echo Updating FFmpeg...
echo This will download the latest FFmpeg essentials and replace the existing one.
echo Ensure you have enough disk space.

:: Download FFmpeg zip to the script's directory
curl -L "%ffmpeg_url%" -o "%~dp0%ffmpeg_zip_name%"
if errorlevel 1 (
    echo ERROR: Failed to download FFmpeg. Please check your internet connection.
    pause
    goto :eof
)

:: Remove old FFmpeg extraction if it exists before extracting new one
:: This pattern should match the directory created by Expand-Archive from the zip
for /f "delims=" %%d in ('dir /b /ad "%~dp0ffmpeg-*" 2^>nul') do (
    rmdir /s /q "%~dp0%%d" >nul 2>nul
)

:: Extract FFmpeg using PowerShell
echo # Extracting FFmpeg...
powershell -Command "Expand-Archive -Path '%~dp0%ffmpeg_zip_name%' -DestinationPath '%~dp0' -Force"
if errorlevel 1 (
    echo ERROR: Failed to extract FFmpeg. Please ensure you have a tool like 7-Zip or WinRAR installed, or extract the zip manually.
    del "%~dp0%ffmpeg_zip_name%" >nul 2>nul
    pause
    goto :eof
)
del "%~dp0%ffmpeg_zip_name%" >nul 2>nul

:: Find the extracted FFmpeg folder and add its bin directory to PATH for this session
set "ffmpeg_found=0"
for /f "delims=" %%d in ('dir /b /ad "%~dp0ffmpeg-*" 2^>nul') do (
    set "ffmpeg_bin_dir=%%d\bin"
    set "FULL_FFMPEG_PATH=%~dp0%%ffmpeg_bin_dir%"
    if exist "!FULL_FFMPEG_PATH!" (
        set "PATH=%FULL_FFMPEG_PATH%;%PATH%"
        echo FFmpeg updated and added to PATH for this session.
        set "ffmpeg_found=1"
        goto ffmpeg_updated
    )
)
if "%ffmpeg_found%"=="0" (
    echo ERROR: Could not find extracted FFmpeg directory after extraction. Please install FFmpeg manually.
    pause
    goto :eof
)
:ffmpeg_updated

pause
goto menu

:: --- Exit ---
:eof
endlocal
exit /b
