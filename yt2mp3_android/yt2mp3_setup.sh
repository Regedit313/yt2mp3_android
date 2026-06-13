#!/data/data/com.termux/files/usr/bin/bash

clear

cd "$(dirname "$0")" || exit 1

echo
echo "yt2mp3_android Setup / Update"
echo

echo "Creating project folders..."
mkdir -p download

echo
echo "Updating Termux..."

if ! pkg update -y; then
    echo
    echo "Error: Termux update failed."
    echo "Please check your internet connection and try again."
    echo
    read -p "Press Enter to continue..."
    exit 1
fi

if ! pkg upgrade -y; then
    echo
    echo "Error: Termux upgrade failed."
    echo "Please check your internet connection and try again."
    echo
    read -p "Press Enter to continue..."
    exit 1
fi

if [ ! -d ~/storage/shared ]; then
    echo
    echo "Setting up storage..."
    echo "If Android asks for permission, please allow it."
    echo

    if command -v termux-setup-storage >/dev/null 2>&1; then
        termux-setup-storage
    else
        echo
        echo "Warning: termux-setup-storage command was not found."
        echo "Storage access may not be configured correctly."
    fi
else
    echo
    echo "Storage is already configured."
fi

echo
echo "Installing system tools..."
echo

if ! pkg install -y python ffmpeg mp3gain; then
    echo
    echo "Error: failed to install required system tools."
    echo "Required tools: python, ffmpeg, mp3gain"
    echo
    read -p "Press Enter to continue..."
    exit 1
fi

echo
echo "Checking pip..."
echo

if ! python -m pip --version >/dev/null 2>&1; then
    echo
    echo "Error: pip was not found after installing Python."
    echo "Please reinstall Python in Termux, then run setup again."
    echo
    read -p "Press Enter to continue..."
    exit 1
fi

echo
echo "Installing / updating yt-dlp with pip..."
echo

if ! python -m pip install -U yt-dlp; then
    echo
    echo "Error: failed to install or update yt-dlp with pip."
    echo "Please check your internet connection and try again."
    echo
    read -p "Press Enter to continue..."
    exit 1
fi

hash -r

echo
echo "Checking installed tools..."
echo

missing=0

if ! command -v python >/dev/null 2>&1; then
    echo "- Missing: python"
    missing=1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "- Missing: ffmpeg"
    missing=1
fi

if ! command -v mp3gain >/dev/null 2>&1; then
    echo "- Missing: mp3gain"
    missing=1
fi

if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "- Missing: yt-dlp"
    missing=1
fi

if [ "$missing" -ne 0 ]; then
    echo
    echo "Error: one or more required tools are still missing."
    echo "Please run setup again or reinstall yt2mp3_android."
    echo
    read -p "Press Enter to continue..."
    exit 1
fi

echo "python: $(python --version 2>&1)"
echo "ffmpeg: installed"
echo "mp3gain: installed"
echo "yt-dlp: $(yt-dlp --version)"
echo

echo "Installation completed."
echo
read -p "Press Enter to continue..."
