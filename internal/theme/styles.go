package theme

import (
	"github.com/charmbracelet/lipgloss"
)

type AppStyles struct {
	AppBarStyle           lipgloss.Style
	NavItemStyle          lipgloss.Style
	NavItemSelectedStyle  lipgloss.Style
	ButtonStyle           lipgloss.Style
	ButtonHoverStyle      lipgloss.Style
	CardStyle             lipgloss.Style
	CardActiveStyle       lipgloss.Style
	HeadingStyle          lipgloss.Style
	SubHeadingStyle       lipgloss.Style
	BodyStyle             lipgloss.Style
	ListItemStyle         lipgloss.Style
	ListItemSelectedStyle lipgloss.Style
	InputStyle            lipgloss.Style
	InputFocusedStyle     lipgloss.Style
	StatusStyle           lipgloss.Style
	DialogStyle           lipgloss.Style
	ErrorStyle            lipgloss.Style
	ProgressBarStyle      lipgloss.Style
	RetroBoxStyle         lipgloss.Style
}

func NewAppStyles() *AppStyles {
	return &AppStyles{
		AppBarStyle: lipgloss.NewStyle().
			Background(Theme.Surfaces.Surface).
			Foreground(Theme.Bases.Secondary),

		NavItemStyle: lipgloss.NewStyle().
			Background(Theme.Surfaces.Surface).
			Foreground(Theme.Typography.OnSurface).
			Padding(0, 1).
			Width(18), // Fixed width for consistent alignment

		NavItemSelectedStyle: lipgloss.NewStyle().
			Background(Theme.Bases.Primary).        // Changed from Tertiary to Primary for better visibility
			Foreground(Theme.Typography.OnPrimary). // White text on primary background
			Bold(true).                             // Added bold for better visibility
			Padding(0, 1).
			Width(18), // Fixed width for consistent alignment

		ButtonStyle: lipgloss.NewStyle().
			Background(Theme.Bases.Primary).
			Foreground(Theme.Typography.OnPrimary).
			Padding(0, 2).
			Border(lipgloss.NormalBorder()).
			BorderForeground(Theme.Utility.Border),

		ButtonHoverStyle: lipgloss.NewStyle().
			Background(Theme.Bases.Primary).
			Foreground(Theme.Typography.OnPrimary).
			Padding(0, 2).
			Border(lipgloss.NormalBorder()).
			BorderForeground(Theme.Utility.Border),

		CardStyle: lipgloss.NewStyle().
			Background(Theme.Surfaces.Surface).
			Foreground(Theme.Bases.Secondary).
			Padding(1, 2).
			Margin(1, 0).
			Border(lipgloss.NormalBorder()).
			BorderForeground(Theme.Utility.Border),

		CardActiveStyle: lipgloss.NewStyle().
			Background(Theme.Bases.Primary).
			Foreground(Theme.Typography.OnPrimary).
			Padding(1, 2).
			Margin(1, 0).
			Border(lipgloss.NormalBorder()).
			BorderForeground(Theme.Utility.Border),

		HeadingStyle: lipgloss.NewStyle().
			Foreground(Theme.Bases.Secondary).
			Bold(true).
			Margin(0, 0, 1, 0),

		SubHeadingStyle: lipgloss.NewStyle().
			Foreground(Theme.Typography.OnSurface).
			Margin(0, 0, 1, 0),

		BodyStyle: lipgloss.NewStyle().
			Foreground(Theme.Typography.OnSurface),

		ListItemStyle: lipgloss.NewStyle().
			Padding(0, 1).
			Margin(0, 0, 0, 0),

		ListItemSelectedStyle: lipgloss.NewStyle().
			Padding(0, 1).
			Margin(0, 0, 0, 0).
			Background(Theme.Bases.Primary).
			Foreground(Theme.Typography.OnSurface),

		InputStyle: lipgloss.NewStyle().
			Background(Theme.Surfaces.Surface).
			Foreground(Theme.Typography.OnSurface).
			Padding(0, 1).
			Border(lipgloss.NormalBorder()).
			BorderForeground(Theme.Utility.Border),

		InputFocusedStyle: lipgloss.NewStyle().
			Background(Theme.Surfaces.Surface).
			Foreground(Theme.Typography.OnSurface).
			Padding(0, 1).
			Border(lipgloss.NormalBorder()).
			BorderForeground(Theme.Utility.Border).
			BorderBottom(true),

		StatusStyle: lipgloss.NewStyle().
			Background(Theme.Surfaces.Surface).
			Foreground(Theme.Typography.OnSurface).
			Padding(0, 1).
			Border(lipgloss.NormalBorder()).
			BorderForeground(Theme.Utility.Border),

		DialogStyle: lipgloss.NewStyle().
			Background(Theme.Surfaces.SurfaceVariant).
			Foreground(Theme.Typography.OnSurfaceVariant).
			Border(lipgloss.RoundedBorder()).
			BorderForeground(Theme.Utility.Border).
			Padding(2, 4).
			Width(50).
			AlignHorizontal(lipgloss.Center).
			AlignVertical(lipgloss.Center),

		ErrorStyle: lipgloss.NewStyle().
			Background(Theme.Surfaces.Error).
			Foreground(Theme.Typography.OnError).
			Padding(0, 1).
			Border(lipgloss.NormalBorder()).
			BorderForeground(Theme.Utility.Border),

		ProgressBarStyle: lipgloss.NewStyle().
			Background(Theme.Bases.Primary).
			Foreground(Theme.Typography.OnPrimary),

		RetroBoxStyle: lipgloss.NewStyle().
			Border(lipgloss.DoubleBorder()).
			BorderForeground(Theme.Utility.Border).
			Padding(1, 2),
	}
}

func GetNavBarStyle(width, height int) lipgloss.Style {
	return lipgloss.NewStyle().
		Background(Theme.Surfaces.Surface).
		Foreground(Theme.Typography.OnSurface).
		Border(lipgloss.NormalBorder()).
		BorderForeground(Theme.Utility.Border).
		Width(width).
		Height(height)
}

// GetScreenStyle returns the main screen container style
func GetScreenStyle(width, height int) lipgloss.Style {
	return lipgloss.NewStyle().
		Background(Theme.Surfaces.Background).
		Foreground(Theme.Typography.OnBackground).
		Width(width).
		Height(height)
}

// GetTitleStyle returns a styled title with the retro theme
func GetTitleStyle() lipgloss.Style {
	return lipgloss.NewStyle().
		Background(Theme.Surfaces.Surface).
		Foreground(Theme.Typography.OnSecondary).
		Bold(true).
		Border(lipgloss.DoubleBorder()).
		BorderForeground(Theme.Utility.Border).
		Padding(1, 2).
		Margin(1, 0)
}

var Styles *AppStyles = NewAppStyles()
