package home

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/thornzero/barkeep/internal/components/navigation"
	"github.com/thornzero/barkeep/internal/theme"
)

// CarouselItem represents a single item in the home carousel
type CarouselItem struct {
	Title       string
	Icon        string
	Description string
	Details     string
	Screen      navigation.Screen
}

// Model represents the home screen with carousel functionality
type Model struct {
	// Carousel state
	items        []CarouselItem
	currentIndex int
	showDetails  bool

	// Configuration
	width  int
	height int

	// Dependencies
	themeProvider theme.Provider
}

// NewModel creates a new home screen model
func NewModel(themeProvider theme.Provider) *Model {
	items := []CarouselItem{
		{
			Title:       "Food & Drink",
			Icon:        "🍺",
			Description: "Manage orders and recipes",
			Details:     "• Order management system\n• Recipe database\n• Kitchen integration\n• Inventory tracking\n• Customer preferences",
			Screen:      navigation.FoodAndDrinkScreen,
		},
		{
			Title:       "Atmosphere",
			Icon:        "🌲",
			Description: "Control lighting and climate",
			Details:     "• Lighting control\n• Temperature management\n• Music ambiance\n• Environmental sensors\n• Automated scenarios",
			Screen:      navigation.AtmosphereScreen,
		},
		{
			Title:       "Entertainment",
			Icon:        "🎵",
			Description: "Music, games, and media",
			Details:     "• Jukebox system\n• Game library\n• Media playback\n• Interactive features\n• Queue management",
			Screen:      navigation.EntertainmentScreen,
		},
		{
			Title:       "Settings",
			Icon:        "⚙️",
			Description: "System configuration",
			Details:     "• Audio settings\n• Hardware configuration\n• User management\n• Theme customization\n• System preferences",
			Screen:      navigation.SettingsScreen,
		},
	}

	return &Model{
		items:         items,
		currentIndex:  0,
		showDetails:   false,
		width:         80,
		height:        24,
		themeProvider: themeProvider,
	}
}

// SetSize sets the screen size
func (m *Model) SetSize(width, height int) {
	m.width = width
	m.height = height
}

// Update handles messages and updates the home screen state
func (m *Model) Update(msg tea.Msg) (*Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.SetSize(msg.Width, msg.Height)

	case tea.KeyMsg:
		switch msg.String() {
		case "left", "h":
			if m.currentIndex > 0 {
				m.currentIndex--
			} else {
				m.currentIndex = len(m.items) - 1 // Wrap around
			}

		case "right", "l":
			if m.currentIndex < len(m.items)-1 {
				m.currentIndex++
			} else {
				m.currentIndex = 0 // Wrap around
			}

		case "d":
			m.showDetails = !m.showDetails
		}
	}

	return m, nil
}

// GetCurrentScreen returns the screen associated with the current carousel item
func (m *Model) GetCurrentScreen() navigation.Screen {
	if m.currentIndex >= 0 && m.currentIndex < len(m.items) {
		return m.items[m.currentIndex].Screen
	}
	return navigation.HomeScreen
}
