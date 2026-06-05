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

9 = Run first-time setup (required before first use)

This step installs all required dependencies and prepares the project folders.

The first-time setup must be completed before using any other menu option.


## Menu

When started, yt2mp3.sh provides the following options:

1 = Download audio from URL (best quality)

2 = Fix + normalize files (to .mp3)

3 = Fix files only (to .mp3)

4 = Normalize files only (must be .mp3)

9 = Run first-time setup (required before first use)

0 = Exit


## Download Audio

Select option 1 and paste a supported URL.

The downloaded audio files will be saved in the "download" folder.

You can download multiple URLs without leaving the menu.

Enter:

0

to return to the main menu.


## Fix Files

Option 3 converts audio files to a highly compatible MP3 format.

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

This mode is intended for maximum compatibility with older MP3 players and devices.


## Normalize Files

Option 4 normalizes MP3 volume using MP3Gain.

Normalized files are renamed with:

_normalized.mp3

added to the filename.

This helps maintain a more consistent playback volume between tracks.

Only MP3 files can be normalized.

Any MP3 file can be processed, regardless of bitrate or encoding settings.

Files using other audio formats are not supported by this option.


## Fix + Normalize

Option 2 performs both operations automatically:

1. Convert files to the compatible MP3 profile.
2. Normalize volume with MP3Gain.

This is the recommended option for preparing files for older MP3 players.


## Notes

The "download" folder is created during the first-time setup and is automatically recreated when launching yt2mp3.sh if it does not already exist.

All downloaded, fixed, and normalized files are stored in the "download" folder.

Downloaded files can be processed individually or in batches.

Multiple URLs can be downloaded before running conversion or normalization.

The original files are removed after a successful conversion to the compatible MP3 format.

This project is intended for personal audio conversion and compatibility purposes.


## Credits

Uses:

- yt-dlp
- FFmpeg
- MP3Gain

This repository provides a simple Android/Termux workflow for downloading, converting, and normalizing audio files.
