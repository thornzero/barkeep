package app

import (
	"github.com/thornzero/barkeep/internal/services"
	"github.com/thornzero/barkeep/internal/theme"
)

// Dependencies contains all the services and dependencies for the application
type Dependencies struct {
	AudioManager  services.AudioServiceInterface
	ThemeProvider theme.Provider
}

// NewDependencies creates a new dependency container
func NewDependencies() (*Dependencies, error) {
	// Initialize audio service
	audioManager := services.NewAudioManager()

	// Initialize theme provider
	themeProvider := theme.NewProvider()
	themeProvider.SetTheme("InkCrimsonDark")

	return &Dependencies{
		AudioManager:  audioManager,
		ThemeProvider: themeProvider,
	}, nil
}

// Close cleans up all dependencies
func (d *Dependencies) Close() error {
	if d.AudioManager != nil {
		return d.AudioManager.Close()
	}
	return nil
}
