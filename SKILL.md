---
name: video-summarizer
description: Download videos from any platform and generate a complete resource package. Supports YouTube, Bilibili, Twitter/X, Vimeo, TikTok, Instagram and 1800+ sites. Outputs video, audio, subtitles (with timestamps), and AI summary. Triggers when user says "summarize this video", "download this video", or "transcribe this video".
---

# Video Summarizer

## Overview

Download videos from any platform and generate a complete resource package including:
- Original video file (mp4)
- Audio file (mp3)
- Subtitle file (with timestamps, vtt/srt format)
- Summary file (summary.md)

Supports all 1800+ websites supported by yt-dlp.

## Trigger Conditions

When the user:
- Provides a video link and asks for a summary
- Says "summarize this video", "what's in this video"
- Asks to "extract video content", "transcribe video"
- Says "download this video"
- Provides a link from YouTube/Bilibili/Twitter/Vimeo/TikTok etc.

## Supported Platforms

- YouTube (youtube.com, youtu.be)
- Bilibili (bilibili.com, b23.tv)
- Twitter/X (x.com, twitter.com)
- Vimeo (vimeo.com)
- TikTok (tiktok.com)
- Instagram (instagram.com)
- Twitch (twitch.tv)
- And 1800+ other platforms (all sites supported by yt-dlp)

## Output Structure

All files are saved to `downloads/<video-title>/` in the **current working directory**:

```
./downloads/
└── <video-title>/
    ├── video.mp4          # Original video
    ├── audio.mp3          # Extracted audio
    ├── subtitle.vtt       # Subtitles with timestamps
    ├── transcript.txt     # Plain text transcript (no timestamps)
    └── summary.md         # Structured summary
```

## Workflow

### Step 1: Check and Auto-install Dependencies

**Important**: Check dependencies before any operation. Auto-install if missing (no user prompt needed).

```bash
# Check and install yt-dlp
if ! which yt-dlp > /dev/null 2>&1; then
  echo "Installing yt-dlp..."
  pip install yt-dlp
fi

# Check and install ffmpeg
if ! which ffmpeg > /dev/null 2>&1; then
  echo "Installing ffmpeg..."
  brew install ffmpeg
fi
```

**Whisper Auto-install Rules**:
- Auto-install Whisper when video has no subtitles and transcription is needed
- Install command: `pip install openai-whisper`
- First run will download model (~244MB for small)

```bash
# Check and install whisper (only when transcription needed)
if ! pip show openai-whisper > /dev/null 2>&1; then
  echo "Installing Whisper (for speech-to-text)..."
  pip install openai-whisper
fi
```

### Step 2: Get Video Info and Create Output Directory

```bash
# Get video title (sanitize special characters for folder name)
TITLE=$(yt-dlp --print "%(title)s" "VIDEO_URL" | sed 's/[/:*?"<>|]/_/g' | cut -c1-80)
DURATION=$(yt-dlp --print "%(duration)s" "VIDEO_URL")

# Create output directory (downloads folder in current working directory)
OUTPUT_DIR=./downloads/"$TITLE"
mkdir -p "$OUTPUT_DIR"

# Check available subtitles
yt-dlp --list-subs "VIDEO_URL"
```

### Step 3: Download Video and Audio

```bash
# Download video (mp4 format, best quality up to 1080p)
yt-dlp -f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best" \
  --merge-output-format mp4 \
  -o "$OUTPUT_DIR/video.%(ext)s" "VIDEO_URL"

# Extract audio (mp3 format)
yt-dlp -x --audio-format mp3 -o "$OUTPUT_DIR/audio.%(ext)s" "VIDEO_URL"
```

### Step 4: Get Subtitles

**Priority order:**

1. **Try downloading manual subtitles (best quality)**
```bash
yt-dlp --write-subs --sub-lang zh,en,zh-Hans,zh-Hant --skip-download \
  -o "$OUTPUT_DIR/subtitle" "VIDEO_URL"
```

2. **Try downloading auto-generated subtitles**
```bash
yt-dlp --write-auto-subs --sub-lang zh,en --skip-download \
  -o "$OUTPUT_DIR/subtitle" "VIDEO_URL"
```

3. **Use Whisper transcription when no subtitles (auto-install)**
```bash
# Ensure Whisper is installed
pip show openai-whisper > /dev/null 2>&1 || pip install openai-whisper

# Use Whisper to transcribe, output vtt format (with timestamps)
whisper "$OUTPUT_DIR/audio.mp3" --model small --language auto \
  --output_format vtt --output_dir "$OUTPUT_DIR"

# Rename to unified filename
mv "$OUTPUT_DIR/audio.vtt" "$OUTPUT_DIR/subtitle.vtt"
```

**Whisper Model Selection Guide**:
| Model | Size | Speed | Use Case |
|-------|------|-------|----------|
| tiny | 39M | Fastest | Quick tests for short videos |
| base | 74M | Fast | General use |
| small | 244M | Medium | **Recommended**, balanced speed and quality |
| medium | 769M | Slow | Higher quality needs |
| large | 1.5G | Slowest | Best accuracy |

### Step 5: Generate Plain Text Transcript

```bash
# Find subtitle file (may be .vtt or .srt)
SUBTITLE_FILE=$(ls "$OUTPUT_DIR"/*.vtt "$OUTPUT_DIR"/*.srt 2>/dev/null | head -1)

# VTT to plain text (remove timestamps)
if [[ "$SUBTITLE_FILE" == *.vtt ]]; then
  sed '/^[0-9]/d; /^$/d; /-->/d; /^WEBVTT/d; /^Kind:/d; /^Language:/d; /^NOTE/d' \
    "$SUBTITLE_FILE" > "$OUTPUT_DIR/transcript.txt"
fi

# SRT to plain text
if [[ "$SUBTITLE_FILE" == *.srt ]]; then
  sed '/^[0-9]/d; /^$/d; /-->/d' "$SUBTITLE_FILE" > "$OUTPUT_DIR/transcript.txt"
fi

# Rename subtitle file to unified name
mv "$SUBTITLE_FILE" "$OUTPUT_DIR/subtitle${SUBTITLE_FILE##*.}" 2>/dev/null || true
```

### Step 6: Generate Summary File

1. **Read prompt template**: Read the summary generation prompt template from `summary-prompt.md`
2. **Replace variables**: Replace placeholders with actual values:
   - `{{TITLE}}` - Video title
   - `{{PLATFORM}}` - Platform name (YouTube/Bilibili/Twitter etc.)
   - `{{URL}}` - Original video link
   - `{{DURATION}}` - Video duration
   - `{{LANGUAGE}}` - Detected language
   - `{{DOWNLOAD_TIME}}` - Download time
   - `{{TRANSCRIPT}}` - Content of transcript.txt
3. **Generate summary**: Generate summary content based on the filled prompt
4. **Save file**: Write the summary to `$OUTPUT_DIR/summary.md`

**Prompt template file**: `reference/summary-prompt.md` (located in this skill directory)

Users can customize this file to adjust the summary format and content.

## Platform-Specific Handling

### Twitter/X
Twitter videos are usually short, summarize directly without chapters.

### Bilibili
- Use `--sub-lang zh-Hans,zh-Hant,zh` to prioritize Chinese subtitles
- Some Bilibili videos may need cookies: `--cookies-from-browser chrome`

### TikTok
- Videos are short, usually no subtitles
- Recommend using Whisper transcription

### Platforms Requiring Login
```bash
# Use browser cookies
yt-dlp --cookies-from-browser chrome "VIDEO_URL"
# or
yt-dlp --cookies-from-browser firefox "VIDEO_URL"
```

## Error Handling

### Cannot Get Subtitles
1. Try auto-generated subtitles
2. **Auto-install and use Whisper transcription** (no user prompt)
3. Inform user that transcription is in progress

### Video Too Long (>1 hour)
1. Ask user if they only need partial content
2. Suggest processing in segments
3. Extract key chapters only (if chapter info available)

### Unsupported Platform
```bash
# Check if supported
yt-dlp --list-extractors | grep -i "platform-name"
```

## Complete Example

**User input**: "Summarize this video https://www.youtube.com/watch?v=xxxxx"

**Execution flow**:
```bash
# 1. Get info and create directory
TITLE=$(yt-dlp --print "%(title)s" "URL" | sed 's/[/:*?"<>|]/_/g' | cut -c1-80)
OUTPUT_DIR=./downloads/"$TITLE"
mkdir -p "$OUTPUT_DIR"

# 2. Download video
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best" --merge-output-format mp4 \
  -o "$OUTPUT_DIR/video.%(ext)s" "URL"

# 3. Extract audio
yt-dlp -x --audio-format mp3 -o "$OUTPUT_DIR/audio.%(ext)s" "URL"

# 4. Download subtitles
yt-dlp --write-auto-subs --sub-lang en --skip-download -o "$OUTPUT_DIR/subtitle" "URL"

# 5. Generate plain text
sed '/^[0-9]/d; /^$/d; /-->/d; /^WEBVTT/d' "$OUTPUT_DIR/subtitle.en.vtt" > "$OUTPUT_DIR/transcript.txt"

# 6. Generate summary (written by Claude)
```

**Final output**:
```
./downloads/Video_Title/
├── video.mp4
├── audio.mp3
├── subtitle.vtt
├── transcript.txt
└── summary.md
```

**Inform user of file location**:
```
Files saved to: ./downloads/Video_Title/
```

## Notes

1. **Storage**: All files saved to `./downloads/` folder in current working directory
2. **Copyright**: For personal learning use only
3. **Network**: Some platforms may require proxy in certain regions
4. **Whisper**: First use requires model download (~244MB for small)
5. **Disk Space**: Video files can be large, check available disk space
