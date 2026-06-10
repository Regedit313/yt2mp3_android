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

download_video() {
    while true; do
        clear

        echo
        echo "Download Video from URL"
        echo
        echo "1) Choose Video + Auto Best Audio"
        echo
        echo "2) Choose Video + Choose Audio"
        echo
        echo "0) Return"
        echo
        echo

        read -p "Choose what to do: " mode

        case "$mode" in

            1)
                clear

                while true; do
                    echo
                    echo "Choose Video + Auto Best Audio"
                    echo
                    read -p "Paste URL or type 0 to return: " url

                    if [ "$url" = "0" ]; then
                        break
                    fi

                    echo
                    echo "Searching available formats, please wait..."
                    echo

                    yt-dlp -F "$url"

                    echo
                    read -p "Enter video format ID: " video_id

                    [ -z "$video_id" ] && continue

                    cd download || exit 1

                    yt-dlp \
                        -f "$video_id+251/bestaudio" \
                        --merge-output-format mp4 \
                        "$url"

                    cd ..

                    echo
                    echo "Video download completed."
                    echo
                    read -p "Press Enter to continue..."
                    clear
                done
                ;;

            2)
                clear

                while true; do
                    echo
                    echo "Choose Video + Choose Audio"
                    echo
                    read -p "Paste URL or type 0 to return: " url

                    if [ "$url" = "0" ]; then
                        break
                    fi

                    echo
                    echo "Searching available formats, please wait..."
                    echo

                    yt-dlp -F "$url"

                    echo
                    read -p "Enter video format ID: " video_id

                    [ -z "$video_id" ] && continue

                    echo
                    read -p "Enter audio format ID: " audio_id

                    [ -z "$audio_id" ] && continue

                    cd download || exit 1

                    yt-dlp \
                        -f "$video_id+$audio_id" \
                        --merge-output-format mp4 \
                        "$url"

                    cd ..

                    echo
                    echo "Video download completed."
                    echo
                    read -p "Press Enter to continue..."
                    clear
                done
                ;;

            0)
                break
                ;;

            *)
                echo
                echo "Invalid choice."
                sleep 1
                ;;
        esac
    done
}

while true; do
    clear

    echo
    echo "yt2mp3_android"
    echo
    echo
    echo "1) Download Audio from URL (best quality)"
    echo
    echo "2) Fix Format + Normalize Volume files (to .mp3)"
    echo
    echo "3) Fix Format files only (to .mp3)"
    echo
    echo "4) Normalize Volume files only (must be .mp3)"
    echo
    echo
    echo "5) Download Video from URL (to .mp4)"
    echo
    echo
    echo "9) Run first-time Setup (required before first use)"
    echo
    echo "0) Exit"
    echo
    echo

    read -p "Choose what to do: " choice

    case "$choice" in

        1)
            clear

            while true; do
                echo
                echo "Download Audio from URL"
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

        5)
            clear
            download_video
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
