package food

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/thornzero/barkeep/internal/services"
	"github.com/thornzero/barkeep/internal/theme"
)

// Model represents the food and drink screen
type Model struct {
	// Configuration
	width  int
	height int

	// Content
	content string

	// Dependencies
	themeProvider theme.Provider
}

// NewModel creates a new food and drink screen model
func NewModel(themeProvider theme.Provider) *Model {
	content := "Food & Drink Management\n\n" +
		"This screen will handle:\n" +
		"• Order management\n" +
		"• Recipe display\n" +
		"• Kitchen integration\n" +
		"• Inventory tracking\n\n" +
		"Coming soon!"

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

// Update handles messages and updates the food and drink screen state
func (m *Model) Update(msg tea.Msg) (*Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.SetSize(msg.Width, msg.Height)
	}

	return m, nil
}

// View renders the food and drink screen
func (m *Model) View() string {
	styles := m.themeProvider.GetStyles()

	// Constrain content to available width
	contentWidth := m.width - 8 // Account for padding and margins
	if contentWidth < 20 {
		contentWidth = 20
	}

	// Wrap the content text to fit
	wrappedContent := services.Txt.WrapText(m.content, contentWidth)

	return styles.HeadingStyle.Render("🍺 Food & Drink") + "\n\n" +
		styles.BodyStyle.Render(wrappedContent)
}
