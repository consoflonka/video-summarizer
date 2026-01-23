# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-23

### Added
- Initial release of video-summarizer skill
- Support for 1800+ video platforms via yt-dlp
- Automatic dependency installation (yt-dlp, ffmpeg, faster-whisper)
- Multi-format output: video (MP4), audio (MP3), subtitles (VTT), transcript (TXT), summary (MD)
- Intelligent subtitle extraction with 3-tier fallback strategy:
  - Manual subtitles (priority 1)
  - Auto-generated subtitles (priority 2)
  - faster-whisper transcription (priority 3)
- Parallel audio transcription for improved performance
- AI-powered video summarization with structured output
- macOS support with automatic dependency installation

### Platforms Tested
- YouTube (youtube.com, youtu.be)
- Bilibili (bilibili.com, b23.tv)
- Twitter/X (twitter.com, x.com)
- Vimeo (vimeo.com)
- TikTok (tiktok.com)
- Instagram (instagram.com)
- Twitch (twitch.tv)

### Technical Details
- Uses yt-dlp for video downloading
- FFmpeg for audio/video processing
- faster-whisper for speech-to-text conversion
- Claude AI for intelligent summarization
- Structured output organization in `downloads/<video-title>/`

### Known Limitations
- Dependency installation script tested on macOS only
- Windows/Linux support theoretical but untested
- Some platforms may require authentication (cookies)
- First run requires Whisper model download (~244MB for small model)

[1.0.0]: https://github.com/liang121/video-summarizer/releases/tag/v1.0.0
