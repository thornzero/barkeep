package jukebox

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
)

// loadDirectory loads files from the specified directory
func (m *Model) loadDirectory(path string) {
	var items []list.Item

	// Add parent directory option if not at root
	if path != "/" && path != m.musicDirectory {
		items = append(items, FileItem{
			name:  "..",
			path:  filepath.Dir(path),
			isDir: true,
		})
	}

	// Read directory contents
	entries, err := os.ReadDir(path)
	if err != nil {
		// Add error item
		items = append(items, FileItem{
			name: fmt.Sprintf("Error: %v", err),
			path: "",
		})
	} else {
		for _, entry := range entries {
			item := FileItem{
				name:  entry.Name(),
				path:  filepath.Join(path, entry.Name()),
				isDir: entry.IsDir(),
			}

			// Check if it's an audio file
			if !entry.IsDir() {
				ext := strings.ToLower(filepath.Ext(entry.Name()))
				item.isAudio = ext == ".mp3" || ext == ".wav" || ext == ".flac" || ext == ".ogg"
			}

			items = append(items, item)
		}
	}

	m.directoryList.SetItems(items)
	m.currentDir = path
}

// handleDirectorySelection handles selection in the directory pane
func (m *Model) handleDirectorySelection() tea.Cmd {
	selected := m.directoryList.SelectedItem()
	if selected == nil {
		return nil
	}

	fileItem := selected.(FileItem)

	if fileItem.isDir {
		// Navigate to directory
		m.loadDirectory(fileItem.path)
	} else if fileItem.isAudio {
		// Load and play the audio file
		if m.audioManager != nil {
			err := m.audioManager.LoadTrack(fileItem.path)
			if err == nil {
				m.audioManager.Play()
				m.nowPlayingTrack = fileItem.path
			}
		}
	}

	return nil
}

// handlePlaylistSelection handles selection in the playlist pane
func (m *Model) handlePlaylistSelection() tea.Cmd {
	selected := m.playlist.SelectedItem()
	if selected == nil {
		return nil
	}

	playlistItem := selected.(PlaylistItem)

	// Load and play the selected track
	if m.audioManager != nil {
		err := m.audioManager.LoadTrack(playlistItem.path)
		if err == nil {
			m.audioManager.Play()
			m.nowPlayingTrack = playlistItem.path
		}
	}

	return nil
}

// addToPlaylist adds the current selection to the playlist
func (m *Model) addToPlaylist() tea.Cmd {
	selected := m.directoryList.SelectedItem()
	if selected == nil {
		return nil
	}

	fileItem := selected.(FileItem)
	if !fileItem.isAudio {
		return nil
	}

	// Add to playlist
	items := m.playlist.Items()
	newItem := PlaylistItem{
		name:  fileItem.name,
		path:  fileItem.path,
		index: len(items),
	}

	items = append(items, newItem)
	m.playlist.SetItems(items)

	// Also add to audio manager playlist
	if m.audioManager != nil {
		m.audioManager.AddToPlaylist([]string{fileItem.path})
	}

	return nil
}

// removeFromPlaylist removes the current selection from the playlist
func (m *Model) removeFromPlaylist() tea.Cmd {
	selected := m.playlist.SelectedItem()
	if selected == nil {
		return nil
	}

	// Remove from playlist
	items := m.playlist.Items()
	selectedIndex := m.playlist.Index()

	if selectedIndex >= 0 && selectedIndex < len(items) {
		// Remove the item
		items = append(items[:selectedIndex], items[selectedIndex+1:]...)
		m.playlist.SetItems(items)

		// Update audio manager playlist
		if m.audioManager != nil {
			var tracks []string
			for _, item := range items {
				if playlistItem, ok := item.(PlaylistItem); ok {
					tracks = append(tracks, playlistItem.path)
				}
			}
			m.audioManager.SetPlaylist(tracks)
		}
	}

	return nil
}
