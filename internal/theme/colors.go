package theme

import (
	"github.com/charmbracelet/lipgloss"
)

// InkCrimson color palette
// Based on: https://lospec.com/palette-list/ink-crimson
// Palette Name: Ink-Crimson
// Description: 10 colors picks with a bit of blues, for the court of the Crimson King!

const (
	// Primary colors
	White             = "#FFFFFF"
	Black             = "#000000"
	Folly             = "#FF0546"
	AmaranthPurple    = "#9C173B"
	TyrianPurpleLight = "#660F31"
	TyrianPurpleDark  = "#450327"
	DarkPurpleLight   = "#270022"
	DarkPurpleDark    = "#17001D"
	Licorice          = "#09010D"
	ElectricBlue      = "#0CE6F2"
	CelestialBlue     = "#0098DB"
	LapisLazuli       = "#1E579C"
)

type ThemeName string

const (
	InkCrimsonDark  ThemeName = "InkCrimsonDark"
	InkCrimsonLight ThemeName = "InkCrimsonLight"
)

type BaseColors struct {
	Primary          lipgloss.Color
	PrimaryVariant   lipgloss.Color
	Secondary        lipgloss.Color
	SecondaryVariant lipgloss.Color
	Tertiary         lipgloss.Color
	TertiaryVariant  lipgloss.Color
}

type SurfaceColors struct {
	Background     lipgloss.Color
	Surface        lipgloss.Color
	SurfaceVariant lipgloss.Color
	Error          lipgloss.Color
}

type TypographyColors struct {
	OnPrimary        lipgloss.Color
	OnSecondary      lipgloss.Color
	OnTertiary       lipgloss.Color
	OnBackground     lipgloss.Color
	OnSurface        lipgloss.Color
	OnSurfaceVariant lipgloss.Color
	OnError          lipgloss.Color
}

type UtilityColors struct {
	Border     lipgloss.Color
	TooltipBG  lipgloss.Color
	InfoTag    lipgloss.Color
	SuccessTag lipgloss.Color
}

type ThemeColors struct {
	Bases      BaseColors
	Surfaces   SurfaceColors
	Typography TypographyColors
	Utility    UtilityColors
}

func NewInkCrimsonLightTheme() *ThemeColors {

	return &ThemeColors{
		Bases: BaseColors{
			Primary:          lipgloss.Color(TyrianPurpleLight),
			PrimaryVariant:   lipgloss.Color(TyrianPurpleDark),
			Secondary:        lipgloss.Color(AmaranthPurple),
			SecondaryVariant: lipgloss.Color(Folly),
			Tertiary:         lipgloss.Color(CelestialBlue),
			TertiaryVariant:  lipgloss.Color(ElectricBlue),
		},
		Surfaces: SurfaceColors{
			Background:     lipgloss.Color(White),
			Surface:        lipgloss.Color(White),
			SurfaceVariant: lipgloss.Color(DarkPurpleLight),
			Error:          lipgloss.Color(Folly),
		},
		Typography: TypographyColors{
			OnPrimary:        lipgloss.Color(Folly),
			OnSecondary:      lipgloss.Color(White),
			OnTertiary:       lipgloss.Color(White),
			OnBackground:     lipgloss.Color(Black),
			OnSurface:        lipgloss.Color(Black),
			OnSurfaceVariant: lipgloss.Color(White),
			OnError:          lipgloss.Color(White),
		},
		Utility: UtilityColors{
			Border:     lipgloss.Color(TyrianPurpleLight),
			TooltipBG:  lipgloss.Color(Licorice),
			InfoTag:    lipgloss.Color(CelestialBlue),
			SuccessTag: lipgloss.Color(ElectricBlue),
		},
	}
}

func NewInkCrimsonDarkTheme() *ThemeColors {
	return &ThemeColors{
		Bases: BaseColors{
			Primary:          lipgloss.Color(TyrianPurpleDark),
			PrimaryVariant:   lipgloss.Color(TyrianPurpleLight),
			Secondary:        lipgloss.Color(AmaranthPurple),
			SecondaryVariant: lipgloss.Color(Folly),
			Tertiary:         lipgloss.Color(CelestialBlue),
			TertiaryVariant:  lipgloss.Color(ElectricBlue),
		},
		Surfaces: SurfaceColors{
			Background:     lipgloss.Color(DarkPurpleDark),
			Surface:        lipgloss.Color(DarkPurpleLight),
			SurfaceVariant: lipgloss.Color(DarkPurpleDark),
			Error:          lipgloss.Color(Folly),
		},
		Typography: TypographyColors{
			OnPrimary:        lipgloss.Color(Folly),
			OnSecondary:      lipgloss.Color(White),
			OnTertiary:       lipgloss.Color(White),
			OnBackground:     lipgloss.Color(White),
			OnSurface:        lipgloss.Color(White),
			OnSurfaceVariant: lipgloss.Color(White),
			OnError:          lipgloss.Color(White),
		},
		Utility: UtilityColors{
			Border:     lipgloss.Color(TyrianPurpleLight),
			TooltipBG:  lipgloss.Color(Licorice),
			InfoTag:    lipgloss.Color(CelestialBlue),
			SuccessTag: lipgloss.Color(ElectricBlue),
		},
	}
}

var Theme *ThemeColors = NewInkCrimsonLightTheme()

func GetTheme() *ThemeColors {
	return Theme
}

func SetTheme(name ThemeName) {
	switch name {
	case InkCrimsonLight:
		Theme = NewInkCrimsonLightTheme()
	case InkCrimsonDark:
		Theme = NewInkCrimsonDarkTheme()
	}
}
