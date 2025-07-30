package navigation

import (
	"github.com/charmbracelet/lipgloss"
)

// View renders the navigation component
func (m *Model) View() string {
	styles := m.themeProvider.GetStyles()

	var navItems []string

	// Create navigation items in deterministic order
	screenOrder := []Screen{
		HomeScreen,
		FoodAndDrinkScreen,
		AtmosphereScreen,
		EntertainmentScreen,
		SettingsScreen,
	}

	for index, screenKey := range screenOrder {
		if screen, exists := m.screens[screenKey]; exists {
			icon := screen.Icon
			title := screen.Title

			// Create the nav item text with proper spacing
			itemText := icon + " " + title

			// Apply styling based on selection
			if index == m.selectedNav {
				navItems = append(navItems, styles.NavItemSelectedStyle.Render(itemText))
			} else {
				navItems = append(navItems, styles.NavItemStyle.Render(itemText))
			}
		}
	}

	if m.showHelp {
		// Add help section with consistent styling
		navItems = append(navItems, styles.NavItemStyle.Render("")) // Empty line
		navItems = append(navItems, styles.NavItemStyle.Bold(true).Render("Keybindings:"))
		navItems = append(navItems, styles.NavItemStyle.Render("1-5: Quick nav"))
		navItems = append(navItems, styles.NavItemStyle.Render("Tab: Focus nav"))
		navItems = append(navItems, styles.NavItemStyle.Render("PgUp/PgDn: Navigate"))
		navItems = append(navItems, styles.NavItemStyle.Render("h/?: Help"))
		navItems = append(navItems, styles.NavItemStyle.Render("q: Quit"))
		navItems = append(navItems, styles.NavItemStyle.Render("x: Exit"))
		navItems = append(navItems, styles.NavItemStyle.Render("Esc: Home"))
	}

	// Ensure we have at least some content
	if len(navItems) == 0 {
		navItems = append(navItems, styles.NavItemStyle.Render("? Loading..."))
	}

	// Join all navigation items vertically
	navigation := lipgloss.JoinVertical(lipgloss.Left, navItems...)

	// Create the navigation container with proper sizing
	navStyle := lipgloss.NewStyle().
		Border(lipgloss.NormalBorder()).
		BorderForeground(m.themeProvider.GetTheme().Utility.Border).
		Padding(1).
		Width(m.width - 2).  // Account for border
		Height(m.height - 2) // Account for border

	return navStyle.Render(navigation)
}
