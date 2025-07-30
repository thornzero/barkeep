package statusbar

import (
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/thornzero/barkeep/internal/components/navigation"
	"github.com/thornzero/barkeep/internal/theme"
)

// PhysicalButton represents a physical button and its help text
type PhysicalButton struct {
	Label       string
	Description string
	Available   bool
}

// Model represents the status bar component state
type Model struct {
	// Configuration
	width  int
	height int

	// Content
	currentScreen   navigation.Screen
	physicalButtons []PhysicalButton
	systemMessage   string
	showTime        bool
	showButtons     bool

	// Time tracking
	currentTime time.Time

	// Dependencies
	themeProvider theme.Provider
}

// NewModel creates a new status bar component
func NewModel(themeProvider theme.Provider) *Model {
	// Define physical buttons based on hardware setup
	physicalButtons := []PhysicalButton{
		{Label: "F1", Description: "Home", Available: true},
		{Label: "F2", Description: "Menu", Available: true},
		{Label: "F3", Description: "Back", Available: true},
		{Label: "F4", Description: "Select", Available: true},
		{Label: "PgUp", Description: "Up", Available: true},   // Added navigation keys
		{Label: "PgDn", Description: "Down", Available: true}, // Added navigation keys
		{Label: "⏯", Description: "Play/Pause", Available: true},
		{Label: "⏭", Description: "Next", Available: true},
		{Label: "⏮", Description: "Previous", Available: true},
		{Label: "🔊", Description: "Volume", Available: true},
	}

	return &Model{
		width:           80,
		height:          1,
		physicalButtons: physicalButtons,
		showTime:        true,
		showButtons:     true,
		currentTime:     time.Now(),
		themeProvider:   themeProvider,
	}
}

// SetSize sets the status bar component size
func (m *Model) SetSize(width, height int) {
	m.width = width
	m.height = height
}

// SetCurrentScreen updates the current screen for context-sensitive help
func (m *Model) SetCurrentScreen(screen navigation.Screen) {
	m.currentScreen = screen
	m.updateButtonAvailability()
}

// SetSystemMessage sets a temporary system message
func (m *Model) SetSystemMessage(message string) {
	m.systemMessage = message
}

// ClearSystemMessage clears the system message
func (m *Model) ClearSystemMessage() {
	m.systemMessage = ""
}

// SetShowTime controls time display
func (m *Model) SetShowTime(show bool) {
	m.showTime = show
}

// SetShowButtons controls button help display
func (m *Model) SetShowButtons(show bool) {
	m.showButtons = show
}

// updateButtonAvailability updates which buttons are available based on current screen
func (m *Model) updateButtonAvailability() {
	// Reset all to available first
	for i := range m.physicalButtons {
		m.physicalButtons[i].Available = true
	}

	// Context-sensitive availability based on screen
	switch m.currentScreen {
	case navigation.EntertainmentScreen:
		// All media buttons available in entertainment
		for i, button := range m.physicalButtons {
			if button.Label == "⏯" || button.Label == "⏭" || button.Label == "⏮" || button.Label == "🔊" {
				m.physicalButtons[i].Available = true
			}
		}
	case navigation.HomeScreen, navigation.FoodAndDrinkScreen, navigation.AtmosphereScreen, navigation.SettingsScreen:
		// Media buttons not as relevant in these screens
		for i, button := range m.physicalButtons {
			if button.Label == "⏯" || button.Label == "⏭" || button.Label == "⏮" {
				m.physicalButtons[i].Available = false
			}
		}
	}
}

// Update handles messages and updates the status bar state
func (m *Model) Update(msg tea.Msg) (*Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.SetSize(msg.Width, 1) // Status bar is always 1 line tall

	case timeUpdateMsg:
		m.currentTime = time.Now()
		return m, m.tickTime()
	}

	return m, nil
}

// Time update message
type timeUpdateMsg struct{}

// tickTime returns a command for the next time update
func (m *Model) tickTime() tea.Cmd {
	return tea.Tick(time.Second, func(t time.Time) tea.Msg {
		return timeUpdateMsg{}
	})
}

// Init initializes the status bar component
func (m *Model) Init() tea.Cmd {
	return m.tickTime()
}
