# Barkeep

A terminal-based bar/tavern management system built with Go and Charm Bracelet libraries.

## Overview

Barkeep is a modern TUI (Terminal User Interface) application designed for managing a bar or tavern system. It provides an intuitive keyboard-driven interface for:

- **Music Management**: Jukebox functionality with directory browsing, queue management, and audio playback
- **Food & Drink**: Order management and kitchen integration
- **Atmosphere Control**: Environmental controls and lighting management
- **Entertainment**: Games, media, and interactive features
- **Hardware Integration**: RFID authentication and industrial automation support

## Features

- **Beautiful TUI**: Built with Charm Bracelet (Bubble Tea, Lip Gloss, Bubbles)
- **Retro Aesthetic**: Custom "Ink Crimson" color scheme inspired by cyberpunk themes
- **Audio System**: Full music playback with sound effects and queue management
- **Hardware Support**: RFID card authentication and industrial automation integration
- **Keyboard Navigation**: Optimized for kiosk and embedded systems

## Tech Stack

- **Go**: Core application language
- **Bubble Tea**: TUI framework for event handling and state management
- **Lip Gloss**: Styling and theming system
- **Bubbles**: Pre-built UI components

## Project Structure

```tree
barkeep/
├── assets/          # Static assets and media files
│   ├── fonts/       # Font files (Orbitron, Press Start 2P, etc.)
│   ├── icons/       # SVG icons
│   ├── media/       # Background images and media
│   ├── recipes/     # Recipe data and schemas
│   ├── schemas/     # Data schemas
│   └── sounds/      # Sound effects and audio files
├── documents/       # Hardware documentation and reference materials
└── README.md
```

## Hardware Integration

The system supports integration with industrial automation hardware:

- RFID card readers for user authentication
- Industrial Automation Cards (megaind) for hardware control
- Audio hardware for music and sound effects
- Touchscreen and keyboard input support

## Development Status

This project is currently being converted from a Flutter application to a Go + Charm Bracelet TUI application. The conversion preserves all original functionality while providing a more lightweight and keyboard-driven interface.

## Original Features (Being Converted)

- Multi-screen navigation (Home, Food & Drink, Atmosphere, Entertainment, Settings)
- Audio management with jukebox functionality
- RFID authentication system
- Custom theming with retro cyberpunk aesthetic
- Hardware integration capabilities
- Kiosk mode for embedded systems

## Getting Started

### Building and Running

```bash
# Build the application
make build

# Run in full-screen mode
make run
# or
make fullscreen

# Run in development mode
make dev

# Quick development cycle
make quick
```

### Full-Screen Mode

Barkeep runs in full-screen mode using the terminal's alternate screen buffer. This provides:

- **Clean interface**: No terminal history interference
- **Proper restoration**: Terminal state is restored on exit
- **Responsive layout**: Adapts to any terminal size
- **Immersive experience**: Full-screen tavern management

### Exit Options

The application provides multiple ways to exit gracefully:

#### Graceful Exit (Recommended)

- Press **`q`** - Shows confirmation dialog
- Press **`y`** to confirm exit or **`n`** to cancel
- Includes proper cleanup of audio and resources

#### Immediate Exit

- Press **`Ctrl+C`** - Immediate exit without confirmation
- Signal handling ensures proper cleanup

#### Emergency Exit

- Terminal close or kill signal - Automatic cleanup

### Navigation

- **`←` `→`** or **`h` `l`** - Navigate carousel on home screen
- **`1-5`** - Quick access to screens
- **`Tab`** - Focus navigation sidebar
- **`Enter`** - Select current item
- **`Esc`** - Return to home screen
- **`h`** or **`?`** - Toggle help
- **`q`** - Quit (with confirmation)

## License

> License information to be updated
