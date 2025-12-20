#!/bin/bash

# =======================================================
# SSK with Gemini - YT-Downloader (Professional)
# Version: 2026.12.21 (Cookie Manager UI Update)
# =======================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; 
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m' 

CONFIG_FILE="./ytdl-settings.conf"
DEFAULT_FFMPEG="/data/data/com.termux/files/usr/bin/ffmpeg"
DEFAULT_DIR="/sdcard/Download/ytdl_downloads"
COOKIE_FILE="./cookies.txt"
ARCHIVE_FILE="./ytdl_archive.txt"

# --- ADAPTIVE UI FUNCTIONS ---
function draw_line() {
    local cols=$(tput cols 2>/dev/null || echo 50)
    local char=${1:-"="}
    printf "${CYAN}%${cols}s${NC}\n" | tr " " "$char"
}

function print_center() {
    local cols=$(tput cols 2>/dev/null || echo 50)
    local text="$1"
    local padding=$(( (cols - ${#text}) / 2 ))
    [ $padding -lt 0 ] && padding=0
    printf "%${padding}s${YELLOW}%s${NC}\n" "" "$text"
}

# --- SYSTEM CHECK & AUTO INSTALL/UPDATE ---
function initial_setup() {
    clear
    draw_line "="
    print_center "SYSTEM CHECK & AUTO-UPDATE..."
    draw_line "="
    [ ! -d "/sdcard" ] && echo -e "${YELLOW}Requesting Storage...${NC}" && termux-setup-storage && sleep 2
    pkg update -y && pkg upgrade -y
    pkg install ffmpeg ncurses-utils -y
    if command -v yt-dlp &> /dev/null; then pip install -U yt-dlp; else pip install yt-dlp; fi
    echo -e "${GREEN}✅ All System Files are Ready.${NC}"
    sleep 1
    check_cookies
}

# --- COOKIE FUNCTIONS ---
function cookie_manager() {
    while true; do
        clear
        draw_line "="
        print_center "COOKIE MANAGER"
        draw_line "="
        echo -e "${CYAN}Watch Tutorial Here:${NC}"
        echo -e "${YELLOW}https://youtube.com/shorts/80DRIzKOknU?si=C3wGVqh0AizRLpSH${NC}"
        draw_line "-"
        echo -e "1. ${GREEN}Paste Cookie Here${NC}"
        echo -e "2. Back to Settings"
        read -r -p "Choice [1-2]: " c_opt
        
        if [ "$c_opt" == "1" ]; then
            echo -e "\nPaste content now (Press CTRL+D when finished):"
            cat > "$COOKIE_FILE"
            if [ -s "$COOKIE_FILE" ]; then 
                echo -e "${GREEN}✅ Cookies saved!${NC}"; AUTO_COOKIE="$COOKIE_FILE"
            else 
                echo -e "${RED}❌ Empty!${NC}"; 
            fi
            sleep 2
        elif [ "$c_opt" == "2" ]; then
            break
        fi
    done
}

function check_cookies() {
    local paths=("/sdcard/Download/cookies.txt" "/sdcard/cookies.txt" "$HOME/cookies.txt" "./cookies.txt")
    AUTO_COOKIE=""
    for p in "${paths[@]}"; do if [ -f "$p" ]; then AUTO_COOKIE="$p"; break; fi; done
    if [ -z "$AUTO_COOKIE" ] && [ ! -f "$COOKIE_FILE" ]; then
        draw_line "-"
        echo -e "${RED}❌ Cookies: Not Found!${NC}"
        echo -ne "${YELLOW}Open Cookie Manager? (y/n): ${NC}"; read -r ans
        [[ "$ans" =~ ^([yY][eE][sS]|[yY])$ ]] && cookie_manager
    else
        [ -z "$AUTO_COOKIE" ] && AUTO_COOKIE="$COOKIE_FILE"
        echo -e "${GREEN}✅ Cookies: Detected.${NC}"; sleep 1
    fi
}

# --- CONFIGURATION ---
function load_config() {
    if [ -f "$CONFIG_FILE" ]; then source "$CONFIG_FILE"; else
        FFMPEG_PATH="$DEFAULT_FFMPEG"; OUTPUT_DIR="$DEFAULT_DIR"; save_config; fi
}
function save_config() {
    echo "FFMPEG_PATH=\"$FFMPEG_PATH\"" > "$CONFIG_FILE"
    echo "OUTPUT_DIR=\"$OUTPUT_DIR\"" >> "$CONFIG_FILE"
}

# =======================================================
# DOWNLOAD LOGIC
# =======================================================

function run_ytdl() {
    local type=$1; local quality=$2; local is_playlist=$3; local range_cmd=""; local archive_cmd=""; local msg=""
    while true; do
        clear
        draw_line "="; print_center "ENTER YOUTUBE URL"; draw_line "-"
        [ -n "$msg" ] && echo -e "$msg"
        echo -e "Type ${GREEN}'b'${NC} to go back."
        read -r -p " URL: " url
        if [[ "$url" == "b" || "$url" == "B" ]]; then return; fi
        if [[ -z "$url" ]]; then msg="${RED}❌ Input cannot be empty!${NC}"
        elif [[ "$url" == *"youtube.com"* ]] || [[ "$url" == *"youtu.be"* ]]; then break
        else msg="${RED}❌ Invalid URL!${NC}"; fi
    done
    if [ "$is_playlist" == "yes" ]; then
        msg=""
        while true; do
            clear; draw_line "="; print_center "SELECT DOWNLOAD MODE"; draw_line "-"
            [ -n "$msg" ] && echo -e "$msg"
            echo -e " 1. Download All\n 2. Download New Only\n 3. Range\n 0. Back"
            read -r -p " Select [1-3 or 0]: " sub_opt
            if [ "$sub_opt" == "0" ]; then return;
            elif [ "$sub_opt" == "1" ]; then break;
            elif [ "$sub_opt" == "2" ]; then archive_cmd="--download-archive $ARCHIVE_FILE"; break;
            elif [ "$sub_opt" == "3" ]; then
                while true; do
                    read -r -p "  Start Index: " start_idx; [ "$start_idx" == "b" ] && return
                    read -r -p "  End Index: " end_idx
                    if [[ "$start_idx" =~ ^[0-9]+$ ]] && [[ "$end_idx" =~ ^[0-9]+$ ]]; then
                        range_cmd="--playlist-items $start_idx-$end_idx"; break 2
                    else echo -e "${RED}❌ Numbers only!${NC}"; fi
                done
            else msg="${RED}❌ Invalid selection!${NC}"; fi
        done
    fi
    echo -e "\n${YELLOW}🔍 Checking Information...${NC}"
    local error_log=$(yt-dlp --get-title --no-warnings --flat-playlist "$url" 2>&1 | head -n 1)
    if [[ "$error_log" == *"Private video"* ]] || [[ "$error_log" == *"confirm you're not a bot"* ]]; then
        echo -e "${RED}❌ Error: Cookie Update Required!${NC}"; read -p "Press Enter..." ; return
    else echo -e "${GREEN}🎥 Title/Playlist:${NC} $error_log"; fi
    local c_flag=""; [ -f "$AUTO_COOKIE" ] && c_flag="--cookies $AUTO_COOKIE"
    local final_save_path="$OUTPUT_DIR"
    [ "$is_playlist" == "yes" ] && final_save_path="${OUTPUT_DIR}/%(playlist_title)s"
    mkdir -p "$OUTPUT_DIR"
    local common_args="$c_flag $range_cmd $archive_cmd --restrict-filenames --no-warnings --ffmpeg-location $FFMPEG_PATH"
    if [ "$type" == "mp3" ]; then
        yt-dlp $common_args -x --audio-format mp3 -o "$final_save_path/%(title)s.mp3" "$url"
    else
        yt-dlp $common_args -f "$quality" --merge-output-format mp4 -o "$final_save_path/%(title)s.mp4" "$url"
    fi
    read -p "Task Finished. Press Enter..."
}

function main_menu() {
    while true; do
        clear; draw_line "="; print_center "SSK x GEMINI - YT DOWNLOADER"; draw_line "="
        echo -e " 📂 Path   : ${BLUE}$OUTPUT_DIR${NC}"
        echo -e " 🍪 Cookies: $([ -f "$AUTO_COOKIE" ] && echo -e "${GREEN}ACTIVE ✅${NC}" || echo -e "${RED}INACTIVE ❌${NC}")"
        echo -e " ⚙️  FFmpeg : $([ -f "$FFMPEG_PATH" ] && echo -e "${GREEN}Ready${NC}" || echo -e "${RED}Missing${NC}")"
        draw_line "-"
        echo -e " 1. Single MP4 (Best)    4. Playlist MP4"
        echo -e " 2. Single MP4 (720p)    5. Playlist MP3"
        echo -e " 3. Single MP3 (Audio)   6. ${YELLOW}Settings${NC}"
        echo -e " 7. ${CYAN}Refresh Tool${NC}        0. Exit"
        draw_line "="
        read -r -p " Select Option: " opt
        case $opt in
            1) run_ytdl "mp4" "bestvideo+bestaudio/best" "no" ;;
            2) run_ytdl "mp4" "bestvideo[height<=720]+bestaudio/best" "no" ;;
            3) run_ytdl "mp3" "" "no" ;;
            4) run_ytdl "mp4" "bestvideo+bestaudio/best" "yes" ;;
            5) run_ytdl "mp3" "" "yes" ;;
            6) clear; draw_line "="; print_center "SETTINGS"; draw_line "-";
                echo -e "1. Change Folder\n2. Update YT-DLP\n3. ${GREEN}Cookie Manager${NC}\n4. Back"
                read -r -p "Choice: " sopt
                if [ "$sopt" == "1" ]; then
                    echo -e "\n${CYAN}Example:${NC} /sdcard/Download/MyFolder"
                    read -p "Enter New Path: " np; [ -n "$np" ] && OUTPUT_DIR=$np && save_config
                elif [ "$sopt" == "2" ]; then pip install -U yt-dlp
                elif [ "$sopt" == "3" ]; then cookie_manager
                fi ;;
            7) sleep 0.5; continue ;;
            0) exit 0 ;;
        esac
    done
}

initial_setup; load_config; main_menu

