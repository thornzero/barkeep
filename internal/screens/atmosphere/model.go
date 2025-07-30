package atmosphere

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/thornzero/barkeep/internal/services"
	"github.com/thornzero/barkeep/internal/theme"
)

// Model represents the atmosphere control screen
type Model struct {
	// Configuration
	width  int
	height int

	// Content
	content string

	// Dependencies
	themeProvider theme.Provider
}

// NewModel creates a new atmosphere screen model
func NewModel(themeProvider theme.Provider) *Model {
	content := lipgloss.JoinVertical(lipgloss.Center,
		"Atmosphere Control",
		"",
		"This screen will handle:",
		"• Lighting control",
		"• Climate management",
		"• Ambient settings",
		"• Environmental monitoring",
		"",
		"Coming soon!",
	)

	return &Model{
		width:         80,
		height:        24,
		content:       content,
		themeProvider: themeProvider,
	}
}

// SetSize sets the screen size
func (m *Model) SetSize(width, height int) {
	m.width = width
	m.height = height
}

// Update handles messages and updates the atmosphere screen state
func (m *Model) Update(msg tea.Msg) (*Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.SetSize(msg.Width, msg.Height)
	}

	return m, nil
}

// View renders the atmosphere screen
func (m *Model) View() string {
	styles := m.themeProvider.GetStyles()

	// Constrain content to available width
	contentWidth := m.width - 8 // Account for padding and margins
	if contentWidth < 20 {
		contentWidth = 20
	}

	// Wrap the content text to fit
	wrappedContent := services.Txt.WrapText(m.content, contentWidth)

	return styles.BodyStyle.Render(wrappedContent)
}
