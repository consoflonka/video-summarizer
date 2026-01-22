# Video Summarizer

A Claude Code skill that downloads videos from YouTube, Bilibili, Twitter/X, TikTok and 1800+ platforms, then generates AI-powered summaries with transcripts.

> **Note**: This is a skill for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI. Not affiliated with Anthropic.

## Features

- **Multi-platform support** - YouTube, Bilibili, Twitter/X, Vimeo, TikTok, Instagram, Twitch, and [1800+ more sites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)
- **Auto subtitle extraction** - Downloads manual or auto-generated subtitles when available
- **Whisper transcription** - Automatically uses OpenAI Whisper for speech-to-text when no subtitles exist
- **AI-powered summaries** - Generates structured summaries with key points, quotes, and timestamps
- **Complete resource package** - Outputs video (MP4), audio (MP3), subtitles (VTT), transcript (TXT), and summary (MD)

## Prerequisites

The following tools will be **automatically installed** if missing:

| Tool | Purpose | Install Command |
|------|---------|-----------------|
| [yt-dlp](https://github.com/yt-dlp/yt-dlp) | Video downloading | `pip install yt-dlp` |
| [ffmpeg](https://ffmpeg.org/) | Audio/video processing | `brew install ffmpeg` |
| [whisper](https://github.com/openai/whisper) | Speech-to-text | `pip install openai-whisper` |

## Installation

```bash
# Clone this repository
git clone https://github.com/liang121/video-summarizer.git

# Copy to Claude Code skills directory
cp -r video-summarizer ~/.claude/skills/
```

## Usage

### Trigger Phrases

The skill activates when you say:

- "Summarize this video: [URL]"
- "Download this video: [URL]"
- "What's in this video? [URL]"
- "Transcribe this video: [URL]"

### Example

```
Summarize this video: https://www.youtube.com/watch?v=dQw4w9WgXcQ
```

### Output

All files are saved to `./downloads/<video-title>/`:

```
downloads/
└── Video_Title/
    ├── video.mp4          # Original video (up to 1080p)
    ├── audio.mp3          # Extracted audio
    ├── subtitle.vtt       # Subtitles with timestamps
    ├── transcript.txt     # Plain text transcript
    └── summary.md         # AI-generated summary
```

## Configuration

### Customize Summary Format

Edit `reference/summary-prompt.md` to customize the output. Available variables:

| Variable | Description |
|----------|-------------|
| `{{TITLE}}` | Video title |
| `{{PLATFORM}}` | Platform name |
| `{{URL}}` | Original URL |
| `{{DURATION}}` | Video duration |
| `{{TRANSCRIPT}}` | Full transcript |

### Whisper Models

| Model | Size | Speed | Quality |
|-------|------|-------|---------|
| tiny | 39M | Fastest | Basic |
| base | 74M | Fast | Good |
| **small** | 244M | Medium | **Recommended** |
| medium | 769M | Slow | Better |
| large | 1.5G | Slowest | Best |

## Platform Notes

### YouTube
- Supports manual and auto-generated subtitles
- Premium content requires browser cookies

### Bilibili
- Prioritizes Chinese subtitles
- Member content requires: `--cookies-from-browser chrome`

### Twitter/X
- Usually requires Whisper (no native subtitles)

### Authenticated Content
```bash
yt-dlp --cookies-from-browser chrome "URL"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No subtitles | Whisper will auto-transcribe |
| Download fails | Try `--cookies-from-browser chrome` |
| Platform not supported | Check: `yt-dlp --list-extractors \| grep -i "name"` |

## License

MIT License - see [LICENSE](./LICENSE)

## Credits

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Video downloading
- [OpenAI Whisper](https://github.com/openai/whisper) - Speech recognition
- [FFmpeg](https://ffmpeg.org/) - Media processing
