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
    echo ""
    echo "yt2mp3_android"
    echo ""
    echo "1) Download audio from URL"
    echo "2) Fix + normalize files"
    echo "3) Fix files only"
    echo "4) Normalize files only"
    echo "9) Run first-time setup (required before first use)"
    echo "0) Exit"
    echo ""

    read -p "Choose what to do: " choice

    case "$choice" in

        1)
            while true; do
                echo ""
                read -p "Paste URL or type 0 to return to menu: " url

                if [ "$url" = "0" ]; then
                    break
                fi

                cd download || exit 1
                yt-dlp -f 251 -x "$url"
                cd ..

                echo ""
                echo "Download completed."
            done
            ;;

        2)
            fix_mp3
            normalize_mp3
            echo ""
            echo "Fix + normalize completed."
            ;;

        3)
            fix_mp3
            echo ""
            echo "Fix completed."
            ;;

        4)
            normalize_mp3
            echo ""
            echo "Normalize completed."
            ;;

        9)
            bash ./yt2mp3_setup.sh
            ;;

        0)
            echo "Exit."
            exit 0
            ;;

        *)
            echo "Invalid choice."
            ;;

    esac
done