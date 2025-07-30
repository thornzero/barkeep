package header

import (
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/thornzero/barkeep/internal/services"
)

// View renders the header component
func (m *Model) View() string {
	if m.width == 0 {
		return ""
	}

	styles := m.themeProvider.GetStyles()
	theme := m.themeProvider.GetTheme()

	// Get current logo frame
	currentLogo := m.logoFrames[m.currentFrame]

	// Create logo with animation
	var logoStyle lipgloss.Style
	switch currentLogo.Style {
	case "primary":
		logoStyle = lipgloss.NewStyle().Foreground(theme.Bases.Primary)
	case "secondary":
		logoStyle = lipgloss.NewStyle().Foreground(theme.Bases.Secondary)
	case "tertiary":
		logoStyle = lipgloss.NewStyle().Foreground(theme.Bases.Tertiary)
	default:
		logoStyle = lipgloss.NewStyle().Foreground(theme.Bases.Primary)
	}

	logo := logoStyle.Render(currentLogo.Content + " BARKEEP")

	// Create screen title (center)
	screenTitle := ""
	if m.currentScreenTitle != "" {
		screenTitle = styles.HeadingStyle.Render(m.currentScreenTitle)
	}

	// Create user display (right)
	userDisplay := ""
	if m.currentUser != "" {
		userDisplay = styles.BodyStyle.Render("👤 " + m.currentUser)
	}

	// Calculate available space for each section
	logoWidth := lipgloss.Width(logo)
	userWidth := lipgloss.Width(userDisplay)
	titleWidth := lipgloss.Width(screenTitle)

	// Calculate spacing
	remainingWidth := max(m.width-logoWidth-userWidth, 0)

	// Center the title in the remaining space
	var titleSection string
	if titleWidth > 0 && remainingWidth > titleWidth {
		leftPadding := (remainingWidth - titleWidth) / 2
		if leftPadding > 0 {
			titleSection = strings.Repeat(" ", leftPadding) + screenTitle
		} else {
			titleSection = screenTitle
		}
	} else if titleWidth > 0 {
		// Truncate title if too long
		maxTitleWidth := remainingWidth - 4 // Leave some space
		if maxTitleWidth > 0 {
			truncatedTitle := services.Txt.TruncateText(m.currentScreenTitle, maxTitleWidth)
			titleSection = styles.HeadingStyle.Render(truncatedTitle)
		}
	}

	// Create the main header line
	headerLine := logo

	// Add title section with proper spacing
	if titleSection != "" {
		headerLine += titleSection
	}

	// Add user display at the end (right-aligned)
	if userDisplay != "" {
		currentWidth := lipgloss.Width(headerLine)
		spacesNeeded := m.width - currentWidth - userWidth
		if spacesNeeded > 0 {
			headerLine += strings.Repeat(" ", spacesNeeded) + userDisplay
		} else {
			// If no space, truncate and add user
			headerLine = services.Txt.TruncateText(headerLine, m.width-userWidth-1) + " " + userDisplay
		}
	}

	// Ensure header line doesn't exceed width
	if lipgloss.Width(headerLine) > m.width {
		headerLine = services.Txt.TruncateText(headerLine, m.width)
	}

	// Create decorative border
	borderStyle := lipgloss.NewStyle().
		Foreground(theme.Utility.Border)

	topBorder := borderStyle.Render(strings.Repeat("═", m.width))
	bottomBorder := borderStyle.Render(strings.Repeat("─", m.width))

	// Combine into final header
	header := lipgloss.JoinVertical(
		lipgloss.Left,
		topBorder,
		headerLine,
		bottomBorder,
	)

	return header
}
