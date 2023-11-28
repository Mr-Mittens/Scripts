#!/bin/bash

read -p "Enter command (ytdl-list/ytdl-audio/ytdl/ytdl-show): " selected_command

if [[ "$selected_command" == "ytdl-list" ]]; then
    read -p "Enter the YouTube playlist URL: " playlist_url
    yt-dlp -o "%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$playlist_url" --
elif [[ "$selected_command" == "ytdl-audio" ]]; then
    read -p "Enter the YouTube video URL: " video_url
    yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 "$video_url"
elif [[ "$selected_command" == "ytdl" ]]; then
    read -p "Enter the YouTube video URL: " video_url
    yt-dlp "$video_url"
elif [[ "$selected_command" == "ytdl-show" ]]; then
    read -p "Enter the YouTube video URL: " video_url
    yt-dlp --list-formats "$video_url"
else
    echo "Invalid command. Usage: ytdl-list OR ytdl-audio OR ytdl OR ytdl-show"
fi

