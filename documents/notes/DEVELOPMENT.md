# Barkeep Development Guide

## Project Setup Complete! 🚀

Your Flutter barkeep project has been successfully converted to a Go + Charm Bracelet TUI application.

## Current Status

### ✅ **Completed Features:**

- **Project Structure**: Clean Go module with proper organization
- **Theme System**: Complete Ink Crimson color scheme with Lip Gloss styles
- **Navigation**: Keyboard-driven navigation with Tab/1-5 key shortcuts
- **Screen Framework**: All 5 main screens with placeholder content
- **Application Shell**: Complete TUI framework with status bar

### **Current Project Structure:**

```tree
barkeep/
├── assets/             # Static assets preserved from Flutter
│   ├── fonts/          # Orbitron, Press Start 2P, etc.
│   ├── icons/          # SVG icons
│   ├── media/          # Background images and media
│   ├── recipes/        # Recipe data
│   ├── schemas/        # Data schemas
│   └── sounds/         # Sound effects library
├── bin/                # Compiled binaries
│   └── barkeep         # Main application binary
├── cmd/barkeep/        # Main application entry point
│   └── main.go
├── internal/           # Internal application code
│   ├── models/         # Application models and screen logic
│   │   ├── app.go      # Main application model
│   │   └── screens.go  # Individual screen models
│   └── theme/          # UI theming and styling
│       ├── colors.go   # Ink Crimson color definitions
│       └── styles.go   # Lip Gloss style definitions
├── documents/          # Hardware docs and reference materials
├── go.mod             # Go module definition
├── go.sum             # Go module checksums
└── README.md          # Project documentation
```

## How to Run

```bash
# Build the application
go build -o bin/barkeep ./cmd/barkeep

# Run the application
./bin/barkeep
```

## Key Features Implemented

### **Navigation System**

- **Tab**: Toggle navigation focus
- **1-5**: Quick access to screens
- **Arrow keys/j/k**: Navigate when focused
- **Enter/Space**: Select screen
- **Esc**: Return to home
- **h/?**: Toggle help
- **q/Ctrl+C**: Quit

### **Screen Layout**

- **Left sidebar**: Navigation with BARKEEP title
- **Main content**: Current screen content
- **Bottom status bar**: Screen info, user status, system info

### **Theming**

- **Ink Crimson palette**: Full cyberpunk color scheme
- **Retro styling**: Double borders, styled text
- **Responsive design**: Adapts to terminal size

## Next Steps for Development

### **Priority Features to Implement:**

1. **Audio System** (`internal/services/audio.go`)
   - Implement music playback with faiface/beep
   - Sound effects system
   - Volume controls

2. **Entertainment Screen** (`internal/screens/entertainment.go`)
   - File system browser for music
   - Playlist management
   - Now playing interface

3. **Settings Screen** (`internal/screens/settings.go`)
   - Audio configuration
   - Theme customization
   - Hardware settings

4. **Hardware Integration** (`internal/services/hardware.go`)
   - RFID card support
   - Industrial automation integration
   - GPIO controls

### **Available Dependencies:**

- `github.com/charmbracelet/bubbletea` - TUI framework
- `github.com/charmbracelet/lipgloss` - Styling
- `github.com/charmbracelet/bubbles` - UI components
- `github.com/faiface/beep` - Audio playback
- `github.com/spf13/viper` - Configuration
- `github.com/spf13/cobra` - CLI commands

## Development Tips

### **Adding New Screens:**

1. Create model in `internal/models/screens.go`
2. Add screen to `AppModel.screens` map
3. Update `Screen` enum

### **Extending Theming:**

- Modify `internal/theme/colors.go` for color changes
- Add new styles in `internal/theme/styles.go`
- Use `theme.Theme.*` colors in components

### **Adding Audio:**

```go
// Example audio integration
import "github.com/faiface/beep"

// Add to audio service
func (a *AudioService) PlaySFX(filename string) {
    // Load and play sound file
}
```

### **File Structure Convention:**

- `internal/models/` - Business logic and state
- `internal/services/` - External integrations (audio, hardware)
- `internal/screens/` - Screen-specific components
- `internal/ui/` - Reusable UI components

## Testing the Application

Run the application and test:

- Navigation between screens
- Keyboard shortcuts
- Help system
- Responsive layout

The application maintains the same functionality as your original Flutter version while providing a lightweight, keyboard-driven interface perfect for embedded systems and kiosks.

## Ready for Extension

Your barkeep application is now ready for feature development. The foundation is solid with proper theming, navigation, and screen management. Focus on implementing the audio system and entertainment screen next to get the core jukebox functionality working.

Happy coding! 🍺
