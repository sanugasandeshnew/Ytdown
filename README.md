# 📥 Ytdown Pro - Universal Media Downloader

Windows සහ Android (Termux) දෙකේම පාවිච්චි කළ හැකි, ඉතා වේගවත් සහ සරල YouTube Downloader එකකි. 

---

## 💻 For Windows Users

Windows සඳහා `.bat` ෆයිල් එක පාවිච්චි කරන්න. මෙය ස්වයංක්‍රීයව Shortcut එකක් සාදා ගන්නා අතර සියලුම දේවල් Auto-Setup කරගනී.

### Features:
- MP3 (High Quality) & MP4 (Selectable Quality) ඩවුන්ලෝඩ් පහසුකම.
- Playlist ඩවුන්ලෝඩ් කිරීමේ හැකියාව.
- Cookies Clipboard එකෙන් කෙලින්ම Import කිරීමේ පහසුකම.

---

## 📱 For Termux Users (Android)

ඔබගේ Termux එකේ පහත පියවරවල් පිළිවෙලින් ක්‍රියාත්මක කරන්න. මෙහිදී සම්පූර්ණ Setup එකම ස්වයංක්‍රීයව සිදුවේ.

### Installation Commands:

# 1. Storage එකට අවසර ලබා දීම (Confirm on your phone)
```bash
termux-setup-storage
````
# 2. අවශ්‍ය Packages install කිරීම
```bash
pkg update && pkg upgrade -y
````
```bash
pkg install git python ffmpeg curl -y
````
```bash
pip install yt-dlp
````
# 3. Repository එක Clone කරගැනීම
```bash
git clone https://github.com/sanugasandeshnew/Ytdown.git
````
# 4. Folder එක වෙත ගොස් Tool එක Run කිරීම
```bash
cd Ytdown/termux
````
```bash
bash tool.sh
