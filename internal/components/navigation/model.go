package navigation

import (
	"github.com/thornzero/barkeep/internal/theme"
)

type Screen int

const (
	HomeScreen Screen = iota
	FoodAndDrinkScreen
	AtmosphereScreen
	EntertainmentScreen
	SettingsScreen
)

type ScreenInfo struct {
	Title       string
	Icon        string
	Description string
}

type Model struct {
	focused       bool
	selectedNav   int
	showHelp      bool
	width         int
	height        int
	screens       map[Screen]ScreenInfo
	themeProvider theme.Provider
}

func NewModel(themeProvider theme.Provider) *Model {
	screens := map[Screen]ScreenInfo{
		HomeScreen: {
			Title:       "Home",
			Icon:        "🏠",
			Description: "Main dashboard and overview",
		},
		FoodAndDrinkScreen: {
			Title:       "Food & Drink",
			Icon:        "🍺",
			Description: "Food and beverage orders",
		},
		AtmosphereScreen: {
			Title:       "Atmosphere",
			Icon:        "🌲",
			Description: "Lighting and climate control",
		},
		EntertainmentScreen: {
			Title:       "Entertainment",
			Icon:        "🎵",
			Description: "Music, games, and media",
		},
		SettingsScreen: {
			Title:       "Settings",
			Icon:        "⚙️",
			Description: "System configuration",
		},
	}

	return &Model{
		focused:       false,
		selectedNav:   0,
		width:         22,
		height:        30,
		screens:       screens,
		themeProvider: themeProvider,
	}
}

func (m *Model) SetSize(width, height int) {
	m.width = width
	m.height = height
}

func (m *Model) SetFocused(focused bool) {
	m.focused = focused
}

func (m *Model) IsFocused() bool {
	return m.focused
}

func (m *Model) SetShowHelp(show bool) {
	m.showHelp = show
}

func (m *Model) GetSelectedScreen() Screen {
	screenOrder := []Screen{
		HomeScreen,
		FoodAndDrinkScreen,
		AtmosphereScreen,
		EntertainmentScreen,
		SettingsScreen,
	}

	if m.selectedNav >= 0 && m.selectedNav < len(screenOrder) {
		return screenOrder[m.selectedNav]
	}
	return HomeScreen
}

func (m *Model) GetScreenInfo(screen Screen) (ScreenInfo, bool) {
	info, exists := m.screens[screen]
	return info, exists
}

func (m *Model) NavigateUp() {
	if m.selectedNav > 0 {
		m.selectedNav--
	}
}

func (m *Model) NavigateDown() {
	if m.selectedNav < 4 { // We have 5 screens (0-4)
		m.selectedNav++
	}
}

func (m *Model) NavigateToScreen(index int) {
	if index >= 0 && index < 5 {
		m.selectedNav = index
	}
}
