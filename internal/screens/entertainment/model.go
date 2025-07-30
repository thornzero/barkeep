package entertainment

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/thornzero/barkeep/internal/screens/entertainment/jukebox"
	"github.com/thornzero/barkeep/internal/services"
	"github.com/thornzero/barkeep/internal/theme"
)

// Model represents the entertainment screen with jukebox functionality
type Model struct {
	// Configuration
	width  int
	height int

	// Components
	jukebox *jukebox.Model

	// Dependencies
	audioManager  services.AudioServiceInterface
	themeProvider theme.Provider
}

// NewModel creates a new entertainment screen model
func NewModel(audioManager services.AudioServiceInterface, themeProvider theme.Provider) *Model {
	// Create jukebox component
	jukeboxModel := jukebox.NewModel(audioManager, themeProvider)

	return &Model{
		width:         80,
		height:        24,
		jukebox:       jukeboxModel,
		audioManager:  audioManager,
		themeProvider: themeProvider,
	}
}

// SetSize sets the screen size
func (m *Model) SetSize(width, height int) {
	m.width = width
	m.height = height

	// Update jukebox size
	jukeboxWidth := width - 8   // Account for padding and margins
	jukeboxHeight := height - 6 // Account for header and margins
	m.jukebox.SetSize(jukeboxWidth, jukeboxHeight)
}

// Init initializes the entertainment screen
func (m *Model) Init() tea.Cmd {
	return m.jukebox.Init()
}

// Update handles messages and updates the entertainment screen state
func (m *Model) Update(msg tea.Msg) (*Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.SetSize(msg.Width, msg.Height)
	}

	// Update jukebox component
	var cmd tea.Cmd
	m.jukebox, cmd = m.jukebox.Update(msg)

	return m, cmd
}

// View renders the entertainment screen
func (m *Model) View() string {
	styles := m.themeProvider.GetStyles()

	// Create header
	header := styles.HeadingStyle.Render("🎵 Entertainment Center")

	// Get jukebox content
	jukeboxContent := m.jukebox.View()

	// Combine header and content
	content := header + "\n\n" + jukeboxContent

	return content
}
