package jukebox

import (
	"os"
	"time"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/thornzero/barkeep/internal/services"
	"github.com/thornzero/barkeep/internal/theme"
)

// JukeboxPane represents which pane is currently active
type JukeboxPane int

const (
	DirectoryPane JukeboxPane = iota
	PlaylistPane
	ControlsPane
)

// FileItem represents a file or directory in the music browser
type FileItem struct {
	name    string
	path    string
	isDir   bool
	isAudio bool
}

// Implement the list.Item interface
func (f FileItem) FilterValue() string { return f.name }

// PlaylistItem represents a track in the playlist
type PlaylistItem struct {
	name     string
	path     string
	duration string
	index    int
}

// Implement the list.Item interface
func (p PlaylistItem) FilterValue() string { return p.name }

// Model represents the jukebox interface
type Model struct {
	// Layout
	width  int
	height int

	// UI state
	activePane JukeboxPane
	showHelp   bool

	// Music browsing
	musicDirectory string
	directoryList  list.Model
	currentDir     string

	// Playlist
	playlist list.Model

	// Now playing
	nowPlayingTrack string
	playbackStatus  string
	progress        string
	volume          float64

	// Dependencies
	audioManager  services.AudioServiceInterface
	themeProvider theme.Provider

	// Status updates
	lastUpdate time.Time
}

// NewModel creates a new jukebox model with dependency injection
func NewModel(audioManager services.AudioServiceInterface, themeProvider theme.Provider) *Model {
	// Create directory list
	dirList := list.New([]list.Item{}, NewFileItemDelegate(themeProvider), 40, 20)
	dirList.Title = "Music Directory"
	dirList.SetShowStatusBar(false)
	dirList.SetFilteringEnabled(false)

	// Create playlist
	playlistList := list.New([]list.Item{}, NewPlaylistItemDelegate(themeProvider), 40, 20)
	playlistList.Title = "Queue"
	playlistList.SetShowStatusBar(false)
	playlistList.SetFilteringEnabled(false)

	jb := &Model{
		activePane:     DirectoryPane,
		musicDirectory: os.ExpandEnv("$HOME/Music"),
		directoryList:  dirList,
		playlist:       playlistList,
		currentDir:     os.ExpandEnv("$HOME/Music"),
		volume:         1.0,
		audioManager:   audioManager,
		themeProvider:  themeProvider,
		lastUpdate:     time.Now(),
	}

	// Load initial directory
	jb.loadDirectory(jb.currentDir)

	return jb
}

// SetSize sets the jukebox component size
func (m *Model) SetSize(width, height int) {
	m.width = width
	m.height = height

	// Update list sizes
	listWidth := m.width / 3
	listHeight := m.height - 10 // Leave room for controls

	m.directoryList.SetSize(listWidth, listHeight)
	m.playlist.SetSize(listWidth, listHeight)
}

// Init initializes the jukebox model
func (m *Model) Init() tea.Cmd {
	return m.startStatusUpdates()
}

// Update handles messages and updates the jukebox state
func (m *Model) Update(msg tea.Msg) (*Model, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.SetSize(msg.Width-4, msg.Height-6) // Account for padding

	case tea.KeyMsg:
		cmd := m.handleKeyPress(msg)
		if cmd != nil {
			cmds = append(cmds, cmd)
		}

	case statusUpdateMsg:
		m.updateStatus()
		cmds = append(cmds, m.statusUpdateCmd())
	}

	// Update the active pane
	var cmd tea.Cmd
	switch m.activePane {
	case DirectoryPane:
		m.directoryList, cmd = m.directoryList.Update(msg)
		cmds = append(cmds, cmd)
	case PlaylistPane:
		m.playlist, cmd = m.playlist.Update(msg)
		cmds = append(cmds, cmd)
	}

	if len(cmds) > 0 {
		return m, tea.Batch(cmds...)
	}
	return m, nil
}

// handleKeyPress processes keyboard input
func (m *Model) handleKeyPress(msg tea.KeyMsg) tea.Cmd {
	switch msg.String() {
	case "tab":
		// Switch between panes
		switch m.activePane {
		case DirectoryPane:
			m.activePane = PlaylistPane
		case PlaylistPane:
			m.activePane = ControlsPane
		case ControlsPane:
			m.activePane = DirectoryPane
		}

	case "enter":
		switch m.activePane {
		case DirectoryPane:
			return m.handleDirectorySelection()
		case PlaylistPane:
			return m.handlePlaylistSelection()
		}

	case " ":
		// Spacebar toggles play/pause
		if m.audioManager != nil {
			status := m.audioManager.GetStatus()
			if status.IsPlaying {
				m.audioManager.Pause()
			} else {
				m.audioManager.Play()
			}
		}

	case "a":
		// Add current directory selection to playlist
		if m.activePane == DirectoryPane {
			return m.addToPlaylist()
		}

	case "d":
		// Remove from playlist
		if m.activePane == PlaylistPane {
			return m.removeFromPlaylist()
		}

	case "n":
		// Next track
		if m.audioManager != nil {
			m.audioManager.Next()
		}

	case "p":
		// Previous track
		if m.audioManager != nil {
			m.audioManager.Previous()
		}

	case "+", "=":
		// Volume up
		if m.volume < 1.0 {
			m.volume += 0.1
			if m.volume > 1.0 {
				m.volume = 1.0
			}
			if m.audioManager != nil {
				m.audioManager.SetVolume(m.volume)
			}
		}

	case "-":
		// Volume down
		if m.volume > 0.0 {
			m.volume -= 0.1
			if m.volume < 0.0 {
				m.volume = 0.0
			}
			if m.audioManager != nil {
				m.audioManager.SetVolume(m.volume)
			}
		}

	case "h", "?":
		m.showHelp = !m.showHelp
	}

	return nil
}

// Status update functionality
type statusUpdateMsg struct{}

func (m *Model) startStatusUpdates() tea.Cmd {
	return m.statusUpdateCmd()
}

func (m *Model) statusUpdateCmd() tea.Cmd {
	return tea.Tick(time.Second, func(t time.Time) tea.Msg {
		return statusUpdateMsg{}
	})
}

func (m *Model) updateStatus() {
	if m.audioManager != nil {
		status := m.audioManager.GetStatus()
		m.nowPlayingTrack = status.CurrentTrack
		m.volume = status.Volume

		if status.IsPlaying {
			m.playbackStatus = "Playing"
		} else if status.IsPaused {
			m.playbackStatus = "Paused"
		} else {
			m.playbackStatus = "Stopped"
		}
	}
	m.lastUpdate = time.Now()
}
