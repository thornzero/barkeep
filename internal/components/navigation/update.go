package navigation

import (
	tea "github.com/charmbracelet/bubbletea"
)

// Update handles messages and updates the navigation state
func (m *Model) Update(msg tea.Msg) (*Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		// Navigation component size is usually fixed, but we can adjust if needed
		// For now, we'll keep the size as set by the parent

	case tea.KeyMsg:
		// Only handle navigation-specific keys when focused
		if m.focused {
			switch msg.String() {
			case "pgup": // Changed from "up", "k"
				m.NavigateUp()

			case "pgdown": // Changed from "down", "j"
				m.NavigateDown()

			case "1":
				m.NavigateToScreen(0)

			case "2":
				m.NavigateToScreen(1)

			case "3":
				m.NavigateToScreen(2)

			case "4":
				m.NavigateToScreen(3)

			case "5":
				m.NavigateToScreen(4)
			}
		}

		// Help toggle can happen even when not focused
		if msg.String() == "h" || msg.String() == "?" {
			m.showHelp = !m.showHelp
		}
	}

	return m, nil
}
