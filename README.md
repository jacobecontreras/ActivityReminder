# Activity Reminder for macOS

Minimal zero-dependency macOS menu bar app for timed activity reminders

## Features
- Live Countdown
- Native Alerts
- SF Symbol Integration
- Zero Dependencies
- Custom Intervals: 
    - 15m, 30m, 45m, 1h, 1.5h, 2h, and 4h.

## Quick Start

### Run as a Script
```bash
swift activityReminder.swift
```

### Build as a Native App (.app)
1. Make the build script executable: `chmod +x build.sh`
2. Run it: `./build.sh`
3. Drag **ActivityReminder.app** to your Applications folder.

## Technical Details
- **Language**: Swift
- **Frameworks**: AppKit, Foundation
- **OS Support**: Should work on macOS 11.0 Big Sur and later (Tested only on macOS Sequoia 15.1)

## License
MIT License
