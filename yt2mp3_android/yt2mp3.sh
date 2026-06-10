#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")" || exit 1

mkdir -p download

fix_mp3() {
    cd download || exit 1

    find . -type f \
        ! -iname "*_fixed.mp3" \
        ! -iname "*_normalized.mp3" \
        ! -iname "*_320_normalized.mp3" \
        ! -iname "*_fixed_normalized.mp3" \
        -exec sh -c '
    for f do
      out="${f%.*}_fixed.mp3"

      if ffmpeg -i "$f" \
        -vn \
        -acodec libmp3lame \
        -b:a 128k \
        -ar 44100 \
        -ac 2 \
        -write_xing 0 \
        -map_metadata -1 \
        "$out"; then

        rm -f "$f"
      else
        rm -f "$out"
        echo "Error: conversion failed for $f"
      fi
    done
    ' sh {} +

    cd ..
}

normalize_audio() {
    cd download || exit 1

    find . -type f \
        ! -iname "*_normalized.mp3" \
        ! -iname "*_320_normalized.mp3" \
        ! -iname "*_fixed_normalized.mp3" \
        -exec sh -c '
    for f do
      case "$f" in
        *.[mM][pP]3)
          base="${f%.[mM][pP]3}"
          out="${base}_normalized.mp3"

          cp "$f" "$out"

          if mp3gain -r -s i -c "$out"; then
            rm -f "$f"
          else
            rm -f "$out"
            echo "Error: normalization failed for $f"
          fi
          ;;

        *)
          base="${f%.*}"
          out="${base}_320_normalized.mp3"

          if ffmpeg -i "$f" \
            -vn \
            -acodec libmp3lame \
            -b:a 320k \
            -ar 44100 \
            -ac 2 \
            -map_metadata -1 \
            "$out"; then

            if mp3gain -r -s i -c "$out"; then
              rm -f "$f"
            else
              rm -f "$out"
              echo "Error: normalization failed for $out"
            fi
          else
            rm -f "$out"
            echo "Error: conversion failed for $f"
          fi
          ;;
      esac
    done
    ' sh {} +

    cd ..
}

download_video() {
    while true; do
        clear

        echo
        echo "Download Video from URL (to .mp4)"
        echo
        echo
        echo "1) Choose Video (+ auto best audio)"
        echo
        echo "2) Choose Video + Choose Audio (expert mode)"
        echo
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
                    echo "Choose Video (+ auto best audio)"
                    echo
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
                    read -p "Enter video format ID (for better audio quality, choose a 'video only' format): " video_id

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
                    echo "Choose Video + Choose Audio (expert mode)"
                    echo
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
                    read -p "Enter video format ID (for better audio quality, choose a 'video only' format): " video_id

                    [ -z "$video_id" ] && continue

                    echo
                    read -p "Enter audio format ID (you must choose an 'audio only' format): " audio_id

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
    echo "2) Normalize Volume (best quality)"
    echo
    echo "3) Fix Format (old MP3 players)"
    echo
    echo "4) Fix Format (old MP3 players) + Normalize Volume"
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
                echo "Download Audio from URL (best quality)"
                echo
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
                read -p "Press Enter to continue..."
                clear
            done
            ;;

        2)
            clear

            normalize_audio

            echo
            echo "Normalize Volume completed."
            echo
            read -p "Press Enter to continue..."
            ;;

        3)
            clear

            fix_mp3

            echo
            echo "Fix Format completed."
            echo
            read -p "Press Enter to continue..."
            ;;

        4)
            clear

            fix_mp3
            normalize_audio

            echo
            echo "Fix Format + Normalize Volume completed."
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
