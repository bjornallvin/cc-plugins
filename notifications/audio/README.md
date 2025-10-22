# Notification Audio Files

This directory contains audio files for Claude Code notifications.

## Default Audio Files

Place your audio files here with these names:
- `waiting.mp3` - Plays when Claude is waiting for input
- `completed.mp3` - Plays when Claude completes a task

## Supported Formats

- **macOS**: MP3, WAV, AIFF, M4A (via `afplay`)
- **Linux**: Any format supported by your audio player

## Adding Custom Sounds

1. Find or create your notification sounds
2. Convert them to MP3 format (recommended for compatibility)
3. Place them in this directory with the names above

## Example Sounds

You can find free notification sounds at:
- [Notification Sounds](https://notificationsounds.com/)
- [Free Sound](https://freesound.org/)
- [Zapsplat](https://www.zapsplat.com/sound-effect-categories/)

## Recommendations

- Keep sounds short (0.5-2 seconds)
- Use pleasant, non-jarring sounds
- Test volume levels before committing

## No Audio Files?

If no audio files are present, the hooks will still show popup notifications on your system.
