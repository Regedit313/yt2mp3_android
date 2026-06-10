# yt2mp3_android

## Installation

1. Install Termux.

2. Copy the "yt2mp3_android" folder to the root of internal storage.

3. Open Termux and run:

termux-setup-storage

(When prompted, allow Termux to access all files on your device storage.)

4. Start yt2mp3:

bash ~/storage/shared/yt2mp3_android/yt2mp3.sh

(The scripts can be launched from any location in Termux.)

5. IMPORTANT:

For the first use, before using any other menu option, select:

9 = Run first-time Setup (required before first use)

This step installs all required dependencies and prepares the project folders.

The first-time Setup must be completed before the first use.

---

## Menu

When started, yt2mp3.sh provides the following options:

1 = Download Audio from URL (best quality)

2 = Fix Format + Normalize volume files (to .mp3)

3 = Fix Format files only (to .mp3)

4 = Normalize Volume files only (must be .mp3)

9 = Run first-time Setup (required before first use)

0 = Exit

---

## Download Audio

Select:

1 = Download Audio from URL (best quality)

Paste a supported URL.

The downloaded audio files are saved in:

download/

You can download multiple URLs without leaving the menu.

Enter:

0

to return to the main menu.

Downloaded files are saved using the best audio quality available from the source.

---

## Fix Format files

Select:

3 = Fix Format files only (to .mp3)

This option converts audio files to a highly compatible MP3 format.

The generated files use the following profile:

- MP3 (libmp3lame)
- 128 kbps
- 44.1 kHz
- Stereo
- No metadata
- No Xing header

Fixed files are saved with:

_fixed.mp3

added to the filename.

Example:

song.m4a

becomes:

song_fixed.mp3

This mode is intended for maximum compatibility with older MP3 players and devices.

The original source file is automatically removed after a successful conversion.

---

## Normalize Volume Files

Select:

4 = Normalize Volume files only (must be .mp3)

This option normalizes MP3 volume using MP3Gain.

Normalized files are saved with:

_normalized.mp3

added to the filename.

Example:

song.mp3

becomes:

song_normalized.mp3

This helps maintain a more consistent playback volume between tracks.

Only MP3 files can be normalized.

Files using other audio formats are not supported by this option.

---

## Fix Format + Normalize Volume files

Select:

2 = Fix Format + Normalize Volume files (to .mp3)

This option performs both operations automatically:

1. Convert files to the compatible MP3 profile.
2. Normalize volume with MP3Gain.

Generated files are saved with:

_fixed_normalized.mp3

added to the filename.

This is the recommended option for preparing files for older MP3 players.

The original source file is automatically removed after a successful conversion.

---

## Folder Structure

### Folder Structure After First Launch

yt2mp3_android/

---- README.md

---- yt2mp3.sh

---- yt2mp3_setup.sh

---- download/

All downloaded and processed files are stored inside:

download/

---

## Notes

The required folders are automatically created if they do not already exist.

The download/ folder is automatically recreated if it is missing.

All downloaded, fixed, and normalized files are stored in the download/ folder.

Downloaded files can be processed individually or in batches.

Multiple URLs can be downloaded before running conversion or normalization.

The original files are automatically removed after a successful conversion to the compatible MP3 profile.

Normalization only processes MP3 files.

This project is intended for personal audio conversion and compatibility purposes.

---

## Credits

Uses:

- yt-dlp
- FFmpeg
- MP3Gain

This repository provides a simple Android/Termux workflow for downloading, converting, and normalizing audio files.
