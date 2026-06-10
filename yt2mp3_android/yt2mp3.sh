#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")" || exit 1

mkdir -p download

fix_mp3() {
    cd download || exit 1

    find . -type f ! -iname "*_fixed.mp3" ! -iname "*_fixed_normalized.mp3" ! -iname "*_normalized.mp3" -exec sh -c '
    for f do
      out="${f%.*}_fixed.mp3"

      ffmpeg -i "$f" \
        -vn \
        -acodec libmp3lame \
        -b:a 128k \
        -ar 44100 \
        -ac 2 \
        -write_xing 0 \
        -map_metadata -1 \
        "$out"

      if [ -f "$out" ]; then
        rm -f "$f"
      else
        echo "Error: conversion failed for $f"
      fi
    done
    ' sh {} +

    cd ..
}

normalize_mp3() {
    cd download || exit 1

    find . -type f -iname "*.mp3" ! -iname "*_normalized.mp3" -exec mp3gain -r -s i -c {} +

    find . -type f -iname "*.mp3" ! -iname "*_normalized.mp3" -exec sh -c '
    for f do
      mv "$f" "${f%.mp3}_normalized.mp3"
    done
    ' sh {} +

    cd ..
}

while true; do
    clear

    echo
    echo "yt2mp3_android"
    echo
    echo "1) Download Audio from URL (best quality)"
    echo "2) Fix Format + Normalize Audio files (to .mp3)"
    echo "3) Fix Format files only (to .mp3)"
    echo "4) Normalize Volume files only (must be .mp3)"
    echo "9) Run first-time Setup (required before first use)"
    echo "0) Exit"
    echo

    read -p "Choose what to do: " choice

    case "$choice" in

        1)
            clear

            while true; do
                echo
                read -p "Paste URL or type 0 to return to menu: " url

                if [ "$url" = "0" ]; then
                    break
                fi

                cd download || exit 1
                yt-dlp -f 251/bestaudio -x "$url"
                cd ..

                echo
                echo "Download completed."
                echo
            done
            ;;

        2)
            clear

            fix_mp3
            normalize_mp3

            echo
            echo "Fix + normalize completed."
            echo
            read -p "Press Enter to continue..."
            ;;

        3)
            clear

            fix_mp3

            echo
            echo "Fix completed."
            echo
            read -p "Press Enter to continue..."
            ;;

        4)
            clear

            normalize_mp3

            echo
            echo "Normalize completed."
            echo
            read -p "Press Enter to continue..."
            ;;

        9)
            clear
            bash ./yt2mp3_setup.sh
            ;;

        0)
            clear
            exit 0
            ;;

        *)
            echo
            echo "Invalid choice."
            sleep 1
            ;;

    esac
done
