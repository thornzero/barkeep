package statusbar

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/thornzero/barkeep/internal/services"
)

// View renders the status bar component
func (m *Model) View() string {
	if m.width == 0 {
		return ""
	}

	styles := m.themeProvider.GetStyles()
	theme := m.themeProvider.GetTheme()

	var sections []string

	// Priority 1: System message (if present)
	if m.systemMessage != "" {
		messageStyle := lipgloss.NewStyle().
			Foreground(theme.Bases.Secondary).
			Bold(true)
		sections = append(sections, messageStyle.Render("ⓘ "+m.systemMessage))
	}

	// Priority 2: Physical button help (if enabled and space allows)
	if m.showButtons && m.systemMessage == "" {
		buttonHelp := m.renderButtonHelp()
		if buttonHelp != "" {
			sections = append(sections, buttonHelp)
		}
	}

	// Priority 3: Time and date (if enabled)
	if m.showTime {
		timeDisplay := m.renderTimeDisplay()
		sections = append(sections, timeDisplay)
	}

	// Combine sections with proper spacing
	statusContent := ""
	if len(sections) > 0 {
		// Calculate total content length
		totalLength := 0
		for _, section := range sections {
			totalLength += lipgloss.Width(section)
		}

		// Add separators between sections
		separatorLength := (len(sections) - 1) * 3 // " | " separators
		totalLength += separatorLength

		// If content fits, show all sections
		if totalLength <= m.width {
			statusContent = strings.Join(sections, " | ")
		} else {
			// Show priority sections only
			if m.systemMessage != "" {
				// System message has highest priority
				statusContent = sections[0]
			} else if m.showTime && len(sections) > 0 {
				// Show time if space allows
				timeSection := sections[len(sections)-1]
				if lipgloss.Width(timeSection) <= m.width {
					statusContent = timeSection
				}
			}
		}
	}

	// Ensure content doesn't exceed width
	if lipgloss.Width(statusContent) > m.width {
		statusContent = services.Txt.TruncateText(statusContent, m.width)
	}

	// Pad to full width with background
	remainingWidth := m.width - lipgloss.Width(statusContent)
	if remainingWidth > 0 {
		statusContent += strings.Repeat(" ", remainingWidth)
	}

	// Apply status bar styling
	statusBar := styles.StatusStyle.
		Width(m.width).
		Render(statusContent)

	return statusBar
}

// renderButtonHelp creates the physical button help text
func (m *Model) renderButtonHelp() string {
	if !m.showButtons {
		return ""
	}

	var buttonTexts []string
	maxButtons := 4 // Limit to prevent overcrowding
	buttonCount := 0

	for _, button := range m.physicalButtons {
		if button.Available && buttonCount < maxButtons {
			buttonText := fmt.Sprintf("%s:%s", button.Label, button.Description)
			buttonTexts = append(buttonTexts, buttonText)
			buttonCount++
		}
	}

	if len(buttonTexts) == 0 {
		return ""
	}

	return strings.Join(buttonTexts, " ")
}

// renderTimeDisplay creates the time and date display
func (m *Model) renderTimeDisplay() string {
	if !m.showTime {
		return ""
	}

	styles := m.themeProvider.GetStyles()

	// Format: "Mon 15:04:05 Jan 02"
	timeStr := m.currentTime.Format("Mon 15:04:05 Jan 02")

	return styles.BodyStyle.Render("🕒 " + timeStr)
}
