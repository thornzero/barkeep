package theme

// Provider defines the interface for theme management
type Provider interface {
	SetTheme(name ThemeName)
	GetTheme() *ThemeColors
	GetStyles() *AppStyles
}

// ThemeProvider implements the Provider interface
type ThemeProvider struct {
	currentTheme *ThemeColors
	styles       *AppStyles
}

// NewProvider creates a new theme provider
func NewProvider() Provider {
	provider := &ThemeProvider{
		currentTheme: NewInkCrimsonDarkTheme(),
	}
	provider.styles = NewAppStyles()
	return provider
}

// SetTheme sets the current theme
func (tp *ThemeProvider) SetTheme(name ThemeName) {
	switch name {
	case InkCrimsonLight:
		tp.currentTheme = NewInkCrimsonLightTheme()
	case InkCrimsonDark:
		tp.currentTheme = NewInkCrimsonDarkTheme()
	}

	// Update global theme for backward compatibility during transition
	Theme = tp.currentTheme

	// Recreate styles with new theme
	tp.styles = NewAppStyles()
	Styles = tp.styles
}

// GetTheme returns the current theme
func (tp *ThemeProvider) GetTheme() *ThemeColors {
	return tp.currentTheme
}

// GetStyles returns the current styles
func (tp *ThemeProvider) GetStyles() *AppStyles {
	return tp.styles
}
