#!/bin/bash

# Prompt for the YouTube URL
read -p "Enter the YouTube URL: " URL

# Download the best video and audio
echo "Downloading video and audio..."
yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "video.%(ext)s" "$URL"

# Download English auto-generated subtitles in VTT format
echo "Downloading subtitles..."
yt-dlp --write-auto-sub --sub-lang en --sub-format vtt --skip-download -o "sub.%(ext)s" "$URL"

# Check for subtitle file (yt-dlp may save with different naming patterns)
SUB_FILE=$(ls *.vtt 2>/dev/null | head -n 1)

if [ -f "$SUB_FILE" ]; then
    echo "Embedding VTT subtitles into the video (open captions)..."
    ffmpeg -i video.mp4 -i "$SUB_FILE" -c:v libx264 -c:a aac -filter_complex "[0:v]subtitles=$SUB_FILE" -y video_with_sub.mp4
else
    echo "Subtitles not found. Checking available subtitles..."
    yt-dlp --list-subs "$URL"
    echo "⚠️  Subtitles not found or unavailable in the requested format. Exiting."
    exit 1
fi

# Clean up temporary files
rm -f video.mp4 "$SUB_FILE"

echo "✅ Done! The final video with subtitles is saved as video_with_sub.mp4"
