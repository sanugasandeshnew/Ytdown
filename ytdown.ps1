# =======================================================
# Ytdown - Windows Version (PowerShell)
# Developed by: SSK x Gemini
# =======================================================

$OutputDirectory = "$HOME\Downloads\Ytdown_Downloads"
if (-not (Test-Path $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory }

function Show-Header {
    Clear-Host
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "      Ytdown - PROFESSIONAL WINDOWS VERSION      " -ForegroundColor Yellow
    Write-Host "=================================================" -ForegroundColor Cyan
}

function Check-Dependencies {
    Show-Header
    Write-Host "🔍 Checking System Files..." -ForegroundColor Gray
    
    # Check yt-dlp
    if (-not (Get-Command "yt-dlp" -ErrorAction SilentlyContinue)) {
        Write-Host "⬇️ yt-dlp not found. Downloading..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile "$PSScriptRoot\yt-dlp.exe"
    }

    # Check ffmpeg
    if (-not (Get-Command "ffmpeg" -ErrorAction SilentlyContinue)) {
        Write-Host "💡 Note: FFmpeg is recommended for better quality." -ForegroundColor Magenta
    }
    
    Write-Host "✅ System Ready!" -ForegroundColor Green
    Start-Sleep -Seconds 1
}

function Main-Menu {
    while ($true) {
        Show-Header
        Write-Host " 📂 Path: $OutputDirectory" -ForegroundColor Blue
        Write-Host "-------------------------------------------------" -ForegroundColor Cyan
        Write-Host " 1. Single MP4 (Best Quality)"
        Write-Host " 2. Single MP3 (Audio Only)"
        Write-Host " 3. Playlist Download (MP4)"
        Write-Host " 4. Change Save Folder"
        Write-Host " 0. Exit"
        Write-Host "-------------------------------------------------" -ForegroundColor Cyan
        
        $choice = Read-Host "Select Option"
        
        switch ($choice) {
            "1" { Start-Download "bestvideo+bestaudio/best" "mp4" }
            "2" { Start-Download "bestaudio" "mp3" }
            "3" { Start-Download "bestvideo+bestaudio/best" "mp4" $true }
            "4" { 
                $newPath = Read-Host "Enter Full Path (e.g. C:\Downloads)"
                if ($newPath) { $script:OutputDirectory = $newPath }
            }
            "0" { exit }
        }
    }
}

function Start-Download($quality, $ext, $isPlaylist=$false) {
    $url = Read-Host "`n🔗 Enter YouTube URL"
    if (-not $url) { return }

    Write-Host "`n🚀 Downloading... Please wait." -ForegroundColor Green
    
    $outputPath = "$OutputDirectory\%(title)s.%(ext)s"
    if ($isPlaylist) { $outputPath = "$OutputDirectory\%(playlist_title)s\%(title)s.%(ext)s" }

    if ($ext -eq "mp3") {
        & "$PSScriptRoot\yt-dlp.exe" -x --audio-format mp3 -o $outputPath $url
    } else {
        & "$PSScriptRoot\yt-dlp.exe" -f $quality --merge-output-format mp4 -o $outputPath $url
    }

    Read-Host "`n✅ Done! Press Enter to continue..."
}

Check-Dependencies
Main-Menu

