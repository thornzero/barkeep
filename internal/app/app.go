package app

import (
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	zone "github.com/lrstanley/bubblezone"
	"github.com/thornzero/barkeep/internal/components/header"
	"github.com/thornzero/barkeep/internal/components/navigation"
	"github.com/thornzero/barkeep/internal/components/statusbar"
	"github.com/thornzero/barkeep/internal/screens/atmosphere"
	"github.com/thornzero/barkeep/internal/screens/entertainment"
	"github.com/thornzero/barkeep/internal/screens/food"
	"github.com/thornzero/barkeep/internal/screens/home"
	"github.com/thornzero/barkeep/internal/screens/settings"
)

// Model represents the main application state
type Model struct {
	// Dependencies
	deps *Dependencies

	// Core state
	currentScreen navigation.Screen
	screenSize    struct{ Width, Height int }

	// UI state
	showExitConfirm bool
	statusMessage   string

	// Components
	header              *header.Model
	navigation          *navigation.Model
	statusBar           *statusbar.Model
	homeScreen          *home.Model
	entertainmentScreen *entertainment.Model
	foodScreen          *food.Model
	atmosphereScreen    *atmosphere.Model
	settingsScreen      *settings.Model

	// User state
	currentUser string
}

// NewModel creates a new application model with dependency injection
func NewModel() (*Model, error) {
	// Initialize dependencies
	deps, err := NewDependencies()
	if err != nil {
		return nil, err
	}

	// Initial dimensions will be set by bubbletea's WindowSizeMsg on startup
	var initialWidth, initialHeight int = 158, 43

	// Initialize header component
	headerComp := header.NewModel(deps.ThemeProvider)
	headerComp.SetSize(initialWidth, 3)

	navigationComp := navigation.NewModel(deps.ThemeProvider)
	navigationComp.SetSize(22, 30)

	statusBarComp := statusbar.NewModel(deps.ThemeProvider)
	statusBarComp.SetSize(initialWidth, 1)
	statusBarComp.SetCurrentScreen(navigation.HomeScreen)

	homeScreen := home.NewModel(deps.ThemeProvider)
	homeScreen.SetSize(initialWidth-22-6, initialHeight-6) // Account for nav and borders

	entertainmentScreen := entertainment.NewModel(deps.AudioManager, deps.ThemeProvider)
	entertainmentScreen.SetSize(initialWidth-22-6, initialHeight-6) // Account for nav and borders

	foodScreen := food.NewModel(deps.ThemeProvider)
	foodScreen.SetSize(initialWidth-22-6, initialHeight-6) // Account for nav and borders

	atmosphereScreen := atmosphere.NewModel(deps.ThemeProvider)
	atmosphereScreen.SetSize(initialWidth-22-6, initialHeight-6) // Account for nav and borders

	settingsScreen := settings.NewModel(deps.ThemeProvider)
	settingsScreen.SetSize(initialWidth-22-6, initialHeight-6) // Account for nav and borders

	return &Model{
		deps:          deps,
		currentScreen: navigation.HomeScreen,
		screenSize: struct{ Width, Height int }{
			Width:  initialWidth,
			Height: initialHeight,
		},
		header:              headerComp,
		navigation:          navigationComp,
		statusBar:           statusBarComp,
		homeScreen:          homeScreen,
		entertainmentScreen: entertainmentScreen,
		foodScreen:          foodScreen,
		atmosphereScreen:    atmosphereScreen,
		settingsScreen:      settingsScreen,
	}, nil
}

// Init initializes the application model
func (m *Model) Init() tea.Cmd {
	return nil
}

// Update handles messages and updates the application state
func (m *Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.screenSize.Width = msg.Width
		m.screenSize.Height = msg.Height

		// Update component sizes
		m.header.SetSize(m.screenSize.Width, 3)
		m.statusBar.SetSize(m.screenSize.Width, 1)

		contentWidth := m.screenSize.Width - 22 - 6 // nav width + borders
		contentHeight := m.screenSize.Height - 6    // status + borders
		m.homeScreen.SetSize(contentWidth, contentHeight)
		m.entertainmentScreen.SetSize(contentWidth, contentHeight)
		m.foodScreen.SetSize(contentWidth, contentHeight)
		m.atmosphereScreen.SetSize(contentWidth, contentHeight)
		m.settingsScreen.SetSize(contentWidth, contentHeight)

	case tea.KeyMsg:
		// Handle global keys first
		cmd := m.handleGlobalKeys(msg)
		if cmd != nil {
			return m, cmd
		}

		// Handle navigation keys
		if msg.String() == "tab" {
			focused := !m.navigation.IsFocused()
			m.navigation.SetFocused(focused)
		}

		// Update navigation component
		var navCmd tea.Cmd
		m.navigation, navCmd = m.navigation.Update(msg)
		if navCmd != nil {
			cmds = append(cmds, navCmd)
		}

		// Check for screen changes and update header/status bar
		selectedScreen := m.navigation.GetSelectedScreen()
		if selectedScreen != m.currentScreen {
			m.currentScreen = selectedScreen

			// Update header with new screen title
			if screenInfo, exists := m.navigation.GetScreenInfo(selectedScreen); exists {
				m.header.SetScreenTitle(screenInfo.Title)
			}

			// Update status bar with new screen context
			m.statusBar.SetCurrentScreen(selectedScreen)
		}

		// Update header and status bar components
		var headerCmd, statusCmd tea.Cmd
		m.header, headerCmd = m.header.Update(msg)
		if headerCmd != nil {
			cmds = append(cmds, headerCmd)
		}

		m.statusBar, statusCmd = m.statusBar.Update(msg)
		if statusCmd != nil {
			cmds = append(cmds, statusCmd)
		}

		// Update current screen component
		switch m.currentScreen {
		case navigation.HomeScreen:
			var homeCmd tea.Cmd
			m.homeScreen, homeCmd = m.homeScreen.Update(msg)
			if homeCmd != nil {
				cmds = append(cmds, homeCmd)
			}
		case navigation.EntertainmentScreen:
			var entertainmentCmd tea.Cmd
			m.entertainmentScreen, entertainmentCmd = m.entertainmentScreen.Update(msg)
			if entertainmentCmd != nil {
				cmds = append(cmds, entertainmentCmd)
			}
		case navigation.FoodAndDrinkScreen:
			var foodCmd tea.Cmd
			m.foodScreen, foodCmd = m.foodScreen.Update(msg)
			if foodCmd != nil {
				cmds = append(cmds, foodCmd)
			}
		case navigation.AtmosphereScreen:
			var atmosphereCmd tea.Cmd
			m.atmosphereScreen, atmosphereCmd = m.atmosphereScreen.Update(msg)
			if atmosphereCmd != nil {
				cmds = append(cmds, atmosphereCmd)
			}
		case navigation.SettingsScreen:
			var settingsCmd tea.Cmd
			m.settingsScreen, settingsCmd = m.settingsScreen.Update(msg)
			if settingsCmd != nil {
				cmds = append(cmds, settingsCmd)
			}
		}
	}

	if len(cmds) > 0 {
		return m, tea.Batch(cmds...)
	}
	return m, nil
}

// handleGlobalKeys processes global application keys
func (m *Model) handleGlobalKeys(msg tea.KeyMsg) tea.Cmd {
	// Handle exit confirmation dialog
	if m.showExitConfirm {
		switch msg.String() {
		case "y", "Y":
			m.SetStatusMessage("Goodbye!")
			return tea.Quit
		case "n", "N", "esc":
			m.showExitConfirm = false
			m.SetStatusMessage("Cancelled exit")
		}
		return nil
	}

	switch msg.String() {
	case "x": // Changed from "ctrl+c" to single key "x"
		return tea.Quit

	case "q":
		m.showExitConfirm = true
		m.SetStatusMessage("Really quit? (y/n)")

	case "esc":
		if m.currentScreen != navigation.HomeScreen {
			m.currentScreen = navigation.HomeScreen
			m.navigation.NavigateToScreen(0)
		}
	}

	return nil
}

// View renders the application UI
func (m *Model) View() string {
	if m.screenSize.Width == 0 || m.screenSize.Height == 0 {
		return "Initializing full-screen mode..."
	}

	// Show exit confirmation overlay if needed
	if m.showExitConfirm {
		return m.renderExitConfirmation()
	}

	// Create header
	headerContent := m.header.View()

	// Create navigation bar (without the old header)
	navigationContent := m.navigation.View()

	// Create main content area
	mainContent := lipgloss.JoinHorizontal(
		lipgloss.Top,
		navigationContent,
		m.renderContent(),
	)

	// Create status bar
	statusContent := m.statusBar.View()

	// Combine all sections vertically
	screen := lipgloss.JoinVertical(
		lipgloss.Left,
		headerContent,
		mainContent,
		statusContent,
	)

	// Ensure the screen fills the entire terminal
	styles := m.deps.ThemeProvider.GetStyles()
	screenStyle := styles.BodyStyle.Width(m.screenSize.Width).Height(m.screenSize.Height)

	return zone.Scan(screenStyle.Render(screen))
}

// renderContent renders the current screen content
func (m *Model) renderContent() string {
	switch m.currentScreen {
	case navigation.HomeScreen:
		return m.homeScreen.View()
	case navigation.EntertainmentScreen:
		return m.entertainmentScreen.View()
	case navigation.FoodAndDrinkScreen:
		return m.foodScreen.View()
	case navigation.AtmosphereScreen:
		return m.atmosphereScreen.View()
	case navigation.SettingsScreen:
		return m.settingsScreen.View()
	default:
		return "Screen not implemented yet"
	}
}

// renderExitConfirmation renders the exit confirmation overlay
func (m *Model) renderExitConfirmation() string {
	confirmText := lipgloss.JoinVertical(
		lipgloss.Center,
		"⚠️  Exit Confirmation",
		"",
		"Are you sure you want to quit Barkeep?",
		"",
		"Press 'y' to quit, 'n' to cancel",
		"",
		"Press 'x' for immediate exit", // Updated from Ctrl+C
	)

	styles := m.deps.ThemeProvider.GetStyles()
	return styles.DialogStyle.Render(confirmText)
}

// SetUser sets the current authenticated user
func (m *Model) SetUser(user string) {
	m.currentUser = user
	m.header.SetUser(user)
}

// SetStatusMessage sets a temporary status message
func (m *Model) SetStatusMessage(message string) {
	m.statusMessage = message
	m.statusBar.SetSystemMessage(message)
}

// ClearStatusMessage clears the temporary status message
func (m *Model) ClearStatusMessage() {
	m.statusMessage = ""
	m.statusBar.ClearSystemMessage()
}

// Close cleans up the application
func (m *Model) Close() error {
	if m.deps != nil {
		return m.deps.Close()
	}
	return nil
}
