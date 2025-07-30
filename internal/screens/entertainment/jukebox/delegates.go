package jukebox

import (
	"fmt"
	"io"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/thornzero/barkeep/internal/theme"
)

// FileItemDelegate handles rendering of file items in the directory list
type FileItemDelegate struct {
	themeProvider theme.Provider
}

// NewFileItemDelegate creates a new file item delegate with dependency injection
func NewFileItemDelegate(themeProvider theme.Provider) *FileItemDelegate {
	return &FileItemDelegate{
		themeProvider: themeProvider,
	}
}

// Height returns the height of a file item
func (d *FileItemDelegate) Height() int {
	return 1
}

// Spacing returns the spacing between file items
func (d *FileItemDelegate) Spacing() int {
	return 0
}

// Update handles updates for file items
func (d *FileItemDelegate) Update(msg tea.Msg, m *list.Model) tea.Cmd {
	return nil
}

// Render renders the list item
func (d FileItemDelegate) Render(w io.Writer, m list.Model, index int, listItem list.Item) {
	i, ok := listItem.(FileItem)
	if !ok {
		return
	}

	// Determine icon based on item type
	var icon string
	if i.isDir {
		icon = "📁"
	} else if i.isAudio {
		icon = "🎵"
	} else {
		icon = "📄"
	}

	// Get styles from theme provider
	styles := d.themeProvider.GetStyles()
	style := styles.ListItemStyle

	if index == m.Index() {
		style = styles.ListItemSelectedStyle
	}

	str := fmt.Sprintf("%s %s", icon, i.name)
	fmt.Fprint(w, style.Render(str))
}

// PlaylistItemDelegate handles rendering of playlist items
type PlaylistItemDelegate struct {
	themeProvider theme.Provider
}

// NewPlaylistItemDelegate creates a new playlist item delegate with dependency injection
func NewPlaylistItemDelegate(themeProvider theme.Provider) *PlaylistItemDelegate {
	return &PlaylistItemDelegate{
		themeProvider: themeProvider,
	}
}

// Height returns the height of a playlist item
func (d *PlaylistItemDelegate) Height() int {
	return 1
}

// Spacing returns the spacing between playlist items
func (d *PlaylistItemDelegate) Spacing() int {
	return 0
}

// Update handles updates for playlist items
func (d *PlaylistItemDelegate) Update(msg tea.Msg, m *list.Model) tea.Cmd {
	return nil
}

// Render renders a playlist item
func (d *PlaylistItemDelegate) Render(w io.Writer, m list.Model, index int, listItem list.Item) {
	if playlistItem, ok := listItem.(PlaylistItem); ok {
		// Get styles from theme provider
		styles := d.themeProvider.GetStyles()
		style := styles.ListItemStyle

		// Highlight selected item
		if index == m.Index() {
			style = styles.ListItemSelectedStyle
		}

		// Render the item with track number
		text := fmt.Sprintf("%d. 🎵 %s", index+1, playlistItem.name)
		if playlistItem.duration != "" {
			text += fmt.Sprintf(" (%s)", playlistItem.duration)
		}

		fmt.Fprint(w, style.Render(text))
	}
}
