# 📱 Ytdown Pro for Termux
> **The Most Powerful & Lightweight YouTube Downloader for Android.**

![Android](https://img.shields.io/badge/Platform-Android%20(Termux)-success?style=for-the-badge&logo=android)
![License](https://img.shields.io/badge/Status-Pro%20Version-green?style=for-the-badge)
![Engine](https://img.shields.io/badge/Engine-yt--dlp%20%26%20FFmpeg-orange?style=for-the-badge)

---

## 🚀 ඇයි Termux සඳහා Ytdown Pro? (Why Ytdown Pro for Termux?)

ඔබේ දුරකථනයෙන්ම කිසිදු ඇඩ් (Ads) එකක් නැතිව, ඉතා වේගයෙන් YouTube වීඩියෝ සහ සින්දු ඩවුන්ලෝඩ් කර ගැනීමට ඇති හොඳම ක්‍රමය මෙයයි. මෙය Termux සඳහාම විශේෂයෙන් නිපදවා ඇත.

---

## 🛠️ ස්ථාපනය කරන ආකාරය (How to Install)

පහත පියවරවල් පිළිවෙලින් කොපි කර ඔබගේ Termux එකේ පේස්ට් කරන්න:

```bash
# 1. Storage එකට අවසර ලබා දීම
termux-setup-storage

# 2. අවශ්‍ය සියලුම මෘදුකාංග ස්ථාපනය කිරීම
pkg update && pkg upgrade -y
pkg install git python ffmpeg curl -y
pip install yt-dlp

# 3. Tool එක බාගත කිරීම (Clone)
git clone https://github.com/sanugasandeshnew/Ytdown.git

# 4. Folder එක වෙත ගොස් Tool එක ක්‍රියාත්මක කිරීම
cd Ytdown/termux
bash tool.sh
