#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")" || exit 1

echo "Creating project folders..."

mkdir -p download

echo ""
echo "Updating Termux..."
pkg update -y
pkg upgrade -y

if [ ! -d ~/storage/shared ]; then
    echo "Setting up storage..."
    termux-setup-storage
else
    echo "Storage is already configured."
fi

echo ""
echo "Installing yt-dlp..."
pkg install yt-dlp -y

echo ""
echo "Installing FFmpeg..."
pkg install ffmpeg -y

echo ""
echo "Installing MP3Gain..."
pkg install mp3gain -y

echo ""
echo "Installation completed."