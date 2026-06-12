#!/data/data/com.termux/files/usr/bin/bash

cd "$(dirname "$0")" || exit 1

mkdir -p download

is_valid_audio_target() {
    [ -s "$1" ] && ffmpeg -v error -xerror -i "$1" -vn -f null - >/dev/null 2>&1
}

export -f is_valid_audio_target

require_tools() {
    local missing=()

    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing+=("$tool")
        fi
    done

    if [ "${#missing[@]}" -gt 0 ]; then
        echo
        echo "Missing required tool(s):"
        echo

        for tool in "${missing[@]}"; do
            echo "- $tool"
        done

        echo
        echo "Run first-time Setup from option 9, then try again."
        echo
        read -p "Press Enter to continue..."
        return 1
    fi

    return 0
}

fix_mp3() {
    cd download || exit 1

    find . -type f -iname "*.part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part.mp3" -exec rm -f {} +

    find . -type f \
        ! -iname "*.part" \
        ! -iname "*.yt2mp3_part" \
        ! -iname "*.yt2mp3_part.mp3" \
        ! -iname "*_fixed.mp3" \
        ! -iname "*_fixed_normalized.mp3" \
        -exec bash -c '
    for f do
      case "$f" in
        *.[mM][pP]3)
          base="${f%.[mM][pP]3}"
          ;;
        *)
          base="${f%.*}"
          ;;
      esac

      base="${base//_normalized/}"
      out="${base}_fixed.mp3"
      tmp_out="${out%.mp3}.yt2mp3_part.mp3"

      if [ -e "$out" ] && [ "$f" != "$out" ]; then
        if is_valid_audio_target "$out"; then
          echo "Duplicate target already exists and is valid, removing duplicate source: $f"
          rm -f "$f"
          continue
        else
          echo "Invalid target found, removing it and converting again: $out"
          rm -f "$out"
        fi
      fi

      rm -f "$tmp_out"

      if ffmpeg -i "$f" \
        -vn \
        -acodec libmp3lame \
        -b:a 128k \
        -ar 44100 \
        -ac 2 \
        -write_xing 0 \
        -map_metadata -1 \
        -f mp3 \
        "$tmp_out"; then

        if is_valid_audio_target "$tmp_out"; then
          mv -f "$tmp_out" "$out"
          rm -f "$f"
        else
          rm -f "$tmp_out"
          echo "Error: invalid output after conversion for $f"
        fi
      else
        rm -f "$tmp_out"
        echo "Error: conversion failed for $f"
      fi
    done
    ' bash {} +

    find . -type f -iname "*.yt2mp3_part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part.mp3" -exec rm -f {} +

    cd ..
}

normalize_audio() {
    cd download || exit 1

    find . -type f -iname "*.part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part.mp3" -exec rm -f {} +

    tmp_list="../.yt2mp3_normalize_list_$$"

    find . -type f \
        ! -iname "*.part" \
        ! -iname "*.yt2mp3_part" \
        ! -iname "*.yt2mp3_part.mp3" \
        -print0 > "$tmp_list"

    while IFS= read -r -d '' f; do
      case "$f" in
        *.[mM][pP]3)
          base="${f%.[mM][pP]3}"
          base="${base//_normalized/}"
          out="${base}_normalized.mp3"
          tmp_out="${out%.mp3}.yt2mp3_part.mp3"

          if [ -e "$out" ] && [ "$f" != "$out" ]; then
            if is_valid_audio_target "$out"; then
              echo "Duplicate target already exists and is valid, removing duplicate source: $f"
              rm -f "$f"
              continue
            else
              echo "Invalid target found, removing it and normalizing again: $out"
              rm -f "$out"
            fi
          fi

          rm -f "$tmp_out"

          if cp "$f" "$tmp_out"; then
            if mp3gain -r -s i -c "$tmp_out"; then
              if is_valid_audio_target "$tmp_out"; then
                mv -f "$tmp_out" "$out"

                if [ "$f" != "$out" ]; then
                  rm -f "$f"
                fi
              else
                rm -f "$tmp_out"
                echo "Error: invalid output after normalization for $f"
              fi
            else
              rm -f "$tmp_out"
              echo "Error: normalization failed for $f"
            fi
          else
            rm -f "$tmp_out"
            echo "Error: copy failed for $f"
          fi
          ;;

        *)
          base="${f%.*}"
          base="${base//_normalized/}"
          out="${base}_320_normalized.mp3"
          tmp_out="${out%.mp3}.yt2mp3_part.mp3"

          if [ -e "$out" ] && [ "$f" != "$out" ]; then
            if is_valid_audio_target "$out"; then
              echo "Duplicate target already exists and is valid, removing duplicate source: $f"
              rm -f "$f"
              continue
            else
              echo "Invalid target found, removing it and converting again: $out"
              rm -f "$out"
            fi
          fi

          rm -f "$tmp_out"

          if ffmpeg -i "$f" \
            -vn \
            -acodec libmp3lame \
            -b:a 320k \
            -ar 44100 \
            -ac 2 \
            -map_metadata -1 \
            -f mp3 \
            "$tmp_out"; then

            if mp3gain -r -s i -c "$tmp_out"; then
              if is_valid_audio_target "$tmp_out"; then
                mv -f "$tmp_out" "$out"
                rm -f "$f"
              else
                rm -f "$tmp_out"
                echo "Error: invalid output after normalization for $f"
              fi
            else
              rm -f "$tmp_out"
              echo "Error: normalization failed for $out"
            fi
          else
            rm -f "$tmp_out"
            echo "Error: conversion failed for $f"
          fi
          ;;
      esac
    done < "$tmp_list"

    rm -f "$tmp_list"

    find . -type f -iname "*.yt2mp3_part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part.mp3" -exec rm -f {} +

    cd ..
}

convert_audio_320() {
    cd download || exit 1

    find . -type f -iname "*.part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part.mp3" -exec rm -f {} +

    find . -type f \
        ! -iname "*.part" \
        ! -iname "*.yt2mp3_part" \
        ! -iname "*.yt2mp3_part.mp3" \
        ! -iname "*_320.mp3" \
        ! -iname "*_320_normalized.mp3" \
        -exec bash -c '
    for f do
      case "$f" in
        *.[mM][pP]3)
          base="${f%.[mM][pP]3}"
          ;;
        *)
          base="${f%.*}"
          ;;
      esac

      base="${base//_normalized/}"
      base="${base//_320/}"
      out="${base}_320.mp3"
      tmp_out="${out%.mp3}.yt2mp3_part.mp3"

      if [ -e "$out" ] && [ "$f" != "$out" ]; then
        if is_valid_audio_target "$out"; then
          echo "Duplicate target already exists and is valid, removing duplicate source: $f"
          rm -f "$f"
          continue
        else
          echo "Invalid target found, removing it and converting again: $out"
          rm -f "$out"
        fi
      fi

      rm -f "$tmp_out"

      if ffmpeg -i "$f" \
        -vn \
        -acodec libmp3lame \
        -b:a 320k \
        -ar 44100 \
        -ac 2 \
        -map_metadata -1 \
        -f mp3 \
        "$tmp_out"; then

        if is_valid_audio_target "$tmp_out"; then
          mv -f "$tmp_out" "$out"
          rm -f "$f"
        else
          rm -f "$tmp_out"
          echo "Error: invalid output after conversion for $f"
        fi
      else
        rm -f "$tmp_out"
        echo "Error: conversion failed for $f"
      fi
    done
    ' bash {} +

    find . -type f -iname "*.yt2mp3_part" -exec rm -f {} +
    find . -type f -iname "*.yt2mp3_part.mp3" -exec rm -f {} +

    cd ..
}

download_audio() {
    if ! require_tools yt-dlp ffmpeg; then
        return
    fi

    while true; do
        clear

        echo
        echo "Download Audio from URL"
        echo
        echo
        echo "1) Download Audio or Playlist Auto (recommended)"
        echo
        echo "2) Choose Audio Format (expert mode)"
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
                    echo "Download Audio or Playlist Auto (recommended)"
                    echo
                    echo
                    read -p "Paste URL or type 0 to return: " url

                    if [ "$url" = "0" ]; then
                        break
                    fi

                    cd download || exit 1

                    if yt-dlp \
                    -f 251/bestaudio \
                    -x \
                    --retries infinite \
                    --fragment-retries infinite \
                    --extractor-retries 10 \
                    --retry-sleep 2 \
                    -o "%(uploader)s - %(title)s [%(id)s] [%(format_id)s].%(ext)s" \
                    "$url"; then
                        echo
                        echo "Audio download completed."
                    else
                        echo
                        echo "Audio download completed with errors or failed."
                    fi

                    cd ..

                    echo
                    read -p "Press Enter to continue..."
                    clear
                done
                ;;

            2)
                clear

                while true; do
                    echo
                    echo "Choose Audio Format (expert mode)"
                    echo
                    echo
                    read -p "Paste URL or type 0 to return: " url

                    if [ "$url" = "0" ]; then
                        break
                    fi

                    echo
                    echo "Searching available formats, please wait..."
                    echo

                    yt-dlp \
                    --extractor-retries 10 \
                    --retry-sleep 2 \
                    -F "$url"

                    echo
                    read -p "Enter audio format ID (you must choose an 'audio only' format): " audio_id

                    [ -z "$audio_id" ] && continue

                    cd download || exit 1

                    if yt-dlp \
                    -f "$audio_id" \
                    -x \
                    --retries infinite \
                    --fragment-retries infinite \
                    --extractor-retries 10 \
                    --retry-sleep 2 \
                    -o "%(uploader)s - %(title)s [%(id)s] [%(format_id)s].%(ext)s" \
                    "$url"; then
                        echo
                        echo "Audio download completed."
                    else
                        echo
                        echo "Audio download completed with errors or failed."
                    fi

                    cd ..

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

audio_tools() {
    while true; do
        clear

        echo
        echo "Audio Tools / Convert"
        echo
        echo
        echo "1) Convert to MP3 320"
        echo
        echo "2) Normalize Volume (best quality)"
        echo
        echo "3) Fix Format (old MP3 players)"
        echo
        echo "4) Fix Format (old MP3 players) + Normalize Volume"
        echo
        echo
        echo "0) Return"
        echo
        echo

        read -p "Choose what to do: " choice

        case "$choice" in

            1)
                clear

                if require_tools ffmpeg; then
                    convert_audio_320

                    echo
                    echo "Convert to MP3 320 completed."
                    echo
                    read -p "Press Enter to continue..."
                fi
                ;;

            2)
                clear

                if require_tools ffmpeg mp3gain; then
                    normalize_audio

                    echo
                    echo "Normalize Volume completed."
                    echo
                    read -p "Press Enter to continue..."
                fi
                ;;

            3)
                clear

                if require_tools ffmpeg; then
                    fix_mp3

                    echo
                    echo "Fix Format completed."
                    echo
                    read -p "Press Enter to continue..."
                fi
                ;;

            4)
                clear

                if require_tools ffmpeg mp3gain; then
                    fix_mp3
                    normalize_audio

                    echo
                    echo "Fix Format + Normalize Volume completed."
                    echo
                    read -p "Press Enter to continue..."
                fi
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

download_video_auto_quality() {
    orientation="$1"
    quality="$2"

    while true; do
        clear

        echo
        echo "Download Video or Playlist Auto (recommended) (${orientation}, max ${quality}p)"
        echo
        echo
        read -p "Paste URL or type 0 to return: " url

        if [ "$url" = "0" ]; then
            break
        fi

        cd download || exit 1

        if [ "$orientation" = "landscape" ]; then
            if yt-dlp \
            -f "bv*[vcodec*=avc1][height<=${quality}]+(251/bestaudio)/b*[vcodec*=avc1][height<=${quality}]/b[height<=${quality}]/bv*[height<=${quality}]+(251/bestaudio)" \
            --merge-output-format mp4 \
            --retries infinite \
            --fragment-retries infinite \
            --extractor-retries 10 \
            --retry-sleep 2 \
            -o "%(uploader)s - %(title)s [%(id)s] [%(format_id)s].%(ext)s" \
            "$url"; then
                echo
                echo "Video download completed."
            else
                echo
                echo "Video download completed with errors or failed."
            fi
        else
            if yt-dlp \
            -f "bv*[vcodec*=avc1][width<=${quality}]+(251/bestaudio)/b*[vcodec*=avc1][width<=${quality}]/b[width<=${quality}]/bv*[width<=${quality}]+(251/bestaudio)" \
            --merge-output-format mp4 \
            --retries infinite \
            --fragment-retries infinite \
            --extractor-retries 10 \
            --retry-sleep 2 \
            -o "%(uploader)s - %(title)s [%(id)s] [%(format_id)s].%(ext)s" \
            "$url"; then
                echo
                echo "Video download completed."
            else
                echo
                echo "Video download completed with errors or failed."
            fi
        fi

        cd ..

        echo
        read -p "Press Enter to continue..."
        clear
    done
}

download_video_auto_resolution() {
    orientation="$1"

    while true; do
        clear

        echo
        echo "Download Video or Playlist Auto (recommended) (${orientation})"
        echo
        echo
        echo "1) Max 4320p (8K)"
        echo
        echo "2) Max 2160p (4K)"
        echo
        echo "3) Max 1440p"
        echo
        echo "4) Max 1080p"
        echo
        echo "5) Max 720p"
        echo
        echo "6) Max 480p"
        echo
        echo "7) Max 360p"
        echo
        echo "8) Max 240p"
        echo
        echo "9) Max 144p"
        echo
        echo
        echo "0) Return"
        echo
        echo

        read -p "Choose video quality: " quality_choice

        case "$quality_choice" in

            1)
                download_video_auto_quality "$orientation" "4320"
                ;;

            2)
                download_video_auto_quality "$orientation" "2160"
                ;;

            3)
                download_video_auto_quality "$orientation" "1440"
                ;;

            4)
                download_video_auto_quality "$orientation" "1080"
                ;;

            5)
                download_video_auto_quality "$orientation" "720"
                ;;

            6)
                download_video_auto_quality "$orientation" "480"
                ;;

            7)
                download_video_auto_quality "$orientation" "360"
                ;;

            8)
                download_video_auto_quality "$orientation" "240"
                ;;

            9)
                download_video_auto_quality "$orientation" "144"
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

download_video_auto() {
    while true; do
        clear

        echo
        echo "Download Video or Playlist Auto (recommended)"
        echo
        echo
        echo "1) Landscape (classic videos)"
        echo
        echo "2) Portrait (shorts)"
        echo
        echo
        echo "0) Return"
        echo
        echo

        read -p "Choose video orientation: " orientation_choice

        case "$orientation_choice" in

            1)
                download_video_auto_resolution "landscape"
                ;;

            2)
                download_video_auto_resolution "portrait"
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

download_video() {
    if ! require_tools yt-dlp ffmpeg; then
        return
    fi

    while true; do
        clear

        echo
        echo "Download Video from URL (to .mp4)"
        echo
        echo
        echo "1) Download Video or Playlist Auto (recommended)"
        echo
        echo "2) Choose Video + Auto Best Audio (expert mode)"
        echo
        echo "3) Choose Video + Choose Audio (ultra expert mode)"
        echo
        echo
        echo "0) Return"
        echo
        echo

        read -p "Choose what to do: " mode

        case "$mode" in

            1)
                clear
                download_video_auto
                ;;

            2)
                clear

                while true; do
                    echo
                    echo "Choose Video + Auto Best Audio (expert mode)"
                    echo
                    echo
                    read -p "Paste single video URL or type 0 to return: " url

                    if [ "$url" = "0" ]; then
                        break
                    fi

                    echo
                    echo "Searching available formats, please wait..."
                    echo

                    yt-dlp \
                    --extractor-retries 10 \
                    --retry-sleep 2 \
                    -F "$url"

                    echo
                    read -p "Enter video format ID (for better audio quality, choose a 'video only' format): " video_id

                    [ -z "$video_id" ] && continue

                    cd download || exit 1

                    if yt-dlp \
                    -f "$video_id+(251/bestaudio)" \
                    --merge-output-format mp4 \
                    --retries infinite \
                    --fragment-retries infinite \
                    --extractor-retries 10 \
                    --retry-sleep 2 \
                    -o "%(uploader)s - %(title)s [%(id)s] [%(format_id)s].%(ext)s" \
                    "$url"; then
                        echo
                        echo "Video download completed."
                    else
                        echo
                        echo "Video download completed with errors or failed."
                    fi

                    cd ..

                    echo
                    read -p "Press Enter to continue..."
                    clear
                done
                ;;

            3)
                clear

                while true; do
                    echo
                    echo "Choose Video + Choose Audio (ultra expert mode)"
                    echo
                    echo
                    read -p "Paste single video URL or type 0 to return: " url

                    if [ "$url" = "0" ]; then
                        break
                    fi

                    echo
                    echo "Searching available formats, please wait..."
                    echo

                    yt-dlp \
                    --extractor-retries 10 \
                    --retry-sleep 2 \
                    -F "$url"

                    echo
                    read -p "Enter video format ID (for better audio quality, choose a 'video only' format): " video_id

                    [ -z "$video_id" ] && continue

                    echo
                    read -p "Enter audio format ID (you must choose an 'audio only' format): " audio_id

                    [ -z "$audio_id" ] && continue

                    cd download || exit 1

                    if yt-dlp \
                    -f "$video_id+$audio_id" \
                    --merge-output-format mp4 \
                    --retries infinite \
                    --fragment-retries infinite \
                    --extractor-retries 10 \
                    --retry-sleep 2 \
                    -o "%(uploader)s - %(title)s [%(id)s] [%(format_id)s].%(ext)s" \
                    "$url"; then
                        echo
                        echo "Video download completed."
                    else
                        echo
                        echo "Video download completed with errors or failed."
                    fi

                    cd ..

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
    echo "1) Audio Download from URL"
    echo
    echo "2) Audio Tools / Convert"
    echo
    echo
    echo "3) Video Download from URL"
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
            download_audio
            ;;

        2)
            clear
            audio_tools
            ;;

        3)
            clear
            download_video
            ;;

        9)
            clear

            if [ -f "./yt2mp3_setup.sh" ]; then
                bash ./yt2mp3_setup.sh
                hash -r
            else
                echo
                echo "Setup file is missing: yt2mp3_setup.sh"
                echo
                echo "Please reinstall yt2mp3_android because a required file is missing."
                echo
                read -p "Press Enter to continue..."
            fi
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
