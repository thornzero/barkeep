# Display Resolution Query Implementation

## Overview

This implementation provides the ability to query the OS for current display resolution and terminal dimensions **before** the AppModel is rendered. This is useful for:

1. **Terminal Dimensions**: Getting actual terminal size in characters
2. **Display Resolution**: Getting the pixel resolution of the display
3. **Pre-initialization**: Setting up the AppModel with correct dimensions from the start

## Implementation Details

### 1. Display Service (`internal/services/display.go`)

The `DisplayService` provides comprehensive display information through multiple methods:

#### Features

- **Terminal Size Query**: Uses `TIOCGWINSZ` syscall to get terminal dimensions
- **Display Resolution**: Queries through `xrandr`, `xdpyinfo`, Wayland, or `/sys/class/drm`
- **Fallback Support**: Environment variables and reasonable defaults
- **Cross-platform**: Works on Linux with X11, Wayland, and framebuffer

#### Key Methods

```go
// Get all display information
func (ds *DisplayService) GetDisplayInfo() (*DisplayInfo, error)

// Get just terminal size
func (ds *DisplayService) GetTerminalSize() (width, height int, err error)

// Get just display resolution
func (ds *DisplayService) GetDisplayResolution() (width, height int, err error)
```

### 2. Integration with AppModel

The display service is initialized **before** the AppModel is created:

```go
// In cmd/barkeep/main.go
func main() {
    // Initialize display service FIRST
    if err := services.InitDisplay(); err != nil {
        log.Printf("Warning: Failed to initialize display service: %v", err)
    }
    
    // Initialize audio system
    if err := services.InitAudio(); err != nil {
        log.Printf("Warning: Failed to initialize audio system: %v", err)
    }
    
    // Create AppModel with display information
    app := models.NewAppModel()
    
    // ... rest of application
}
```

### 3. AppModel Enhancement

The `AppModel` now uses display information during initialization:

```go
// In internal/models/app.go
func NewAppModel() *AppModel {
    // Get display information before creating the model
    var displayInfo *services.DisplayInfo
    var initialWidth, initialHeight int
    
    if services.GlobalDisplayService != nil {
        if info, err := services.GlobalDisplayService.GetDisplayInfo(); err == nil {
            displayInfo = info
            initialWidth = info.TerminalWidth
            initialHeight = info.TerminalHeight
        }
    }
    
    // Fallback to reasonable defaults if display service failed
    if initialWidth == 0 || initialHeight == 0 {
        initialWidth = 80
        initialHeight = 24
    }

    app := &AppModel{
        width:       initialWidth,
        height:      initialHeight,
        displayInfo: displayInfo,
        // ... other fields
    }
    
    return app
}
```

## Testing and Usage

### Display Information Tool

A standalone tool (`cmd/display-info/main.go`) provides detailed display information:

```bash
# Build and run display info tool
make display-info

# Or build manually
go build -o display-info ./cmd/display-info
./display-info
```

### Expected Output

```text
🖥️  Display Information Query Tool
==================================

Display Information:
  Terminal: 120x30 characters
  Display:  1920x1080 pixels
  Terminal: 960x480 pixels (estimated)

Quick Queries:
==============
✅ Terminal size: 120x30 characters
✅ Display resolution: 1920x1080 pixels

Detailed Information:
====================
Terminal Characters: 120x30
Terminal Pixels (est): 960x480
Display Pixels: 1920x1080
Terminal covers: 50.0% x 44.4% of display
Character size: 8.0 x 16.0 pixels

Environment Variables:
======================
TERM           : xterm-256color
COLORTERM      : truecolor
COLUMNS        : 120
LINES          : 30
DISPLAY        : :0
XDG_SESSION_TYPE: x11
```

### Available Make Commands

```bash
# Test display information
make test-display

# Build display info tool
make build-display-info

# Build all binaries
make build-all

# Run main application (now with display info)
make run
```

## Query Methods Supported

### Terminal Size

1. **TIOCGWINSZ syscall** - Most reliable, works on all Unix-like systems
2. **Environment variables** - COLUMNS and LINES
3. **Fallback defaults** - 80x24 characters

### Display Resolution

1. **xrandr** - X11 display server query
2. **xdpyinfo** - X11 display information
3. **wlr-randr** - Wayland compositor query
4. **/sys/class/drm** - Direct DRM subsystem query
5. **Fallback** - 1920x1080 default

## Benefits

1. **Accurate Sizing**: AppModel starts with correct dimensions
2. **No Flicker**: No resize needed on first render
3. **Display Aware**: Applications can adapt to different screen sizes
4. **Debug Information**: Comprehensive display debugging
5. **Cross-platform**: Works across different Linux environments

## Example Usage in Application

```go
// Access display information in your models
func (m *AppModel) GetDisplayInfo() *services.DisplayInfo {
    return m.displayInfo
}

// Use in rendering logic
func (m *AppModel) View() string {
    if m.displayInfo != nil {
        // Adapt layout based on display information
        if m.displayInfo.TerminalWidth > 120 {
            // Use wide layout
        }
        
        if m.displayInfo.DisplayWidth > 1920 {
            // Adapt for high resolution displays
        }
    }
    
    // ... rest of rendering
}
```

## Error Handling

The system is designed to gracefully handle failures:

- Display service initialization failure doesn't stop the application
- Multiple fallback methods for resolution detection
- Reasonable defaults when all methods fail
- Comprehensive error logging

This implementation ensures that Barkeep can query and use display information before any UI rendering occurs, providing a smooth and properly sized interface from the first frame.
