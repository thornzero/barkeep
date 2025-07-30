package jukebox

import (
	"fmt"
	"path/filepath"

	"github.com/charmbracelet/lipgloss"
)

// View renders the jukebox interface
func (m *Model) View() string {
	if m.width == 0 {
		return "Loading jukebox..."
	}

	// Calculate layout
	listWidth := m.width / 3
	controlsWidth := m.width - (listWidth * 2) - 4

	// Create three columns
	directoryPane := m.renderDirectoryPane(listWidth)
	playlistPane := m.renderPlaylistPane(listWidth)
	controlsPane := m.renderControlsPane(controlsWidth)

	// Combine panes horizontally
	content := lipgloss.JoinHorizontal(
		lipgloss.Top,
		directoryPane,
		playlistPane,
		controlsPane,
	)

	// Add help if shown
	if m.showHelp {
		help := m.renderHelp()
		content = lipgloss.JoinVertical(lipgloss.Left, content, help)
	}

	return content
}

// renderDirectoryPane renders the music directory browser
func (m *Model) renderDirectoryPane(width int) string {
	styles := m.themeProvider.GetStyles()
	theme := m.themeProvider.GetTheme()

	style := styles.CardStyle.Width(width)
	if m.activePane == DirectoryPane {
		style = style.BorderForeground(theme.Bases.Primary)
	}

	title := styles.SubHeadingStyle.Render("📁 Music Directory")
	currentPath := styles.BodyStyle.Render("Path: " + m.currentDir)

	content := lipgloss.JoinVertical(
		lipgloss.Left,
		title,
		currentPath,
		m.directoryList.View(),
	)

	return style.Render(content)
}

// renderPlaylistPane renders the playlist/queue
func (m *Model) renderPlaylistPane(width int) string {
	styles := m.themeProvider.GetStyles()
	theme := m.themeProvider.GetTheme()

	style := styles.CardStyle.Width(width)

	if m.activePane == PlaylistPane {
		style = style.BorderForeground(theme.Bases.Primary)
	}

	title := styles.SubHeadingStyle.Render("🎵 Playlist Queue")

	content := lipgloss.JoinVertical(
		lipgloss.Left,
		title,
		m.playlist.View(),
	)

	return style.Render(content)
}

// renderControlsPane renders the playback controls and now playing info
func (m *Model) renderControlsPane(width int) string {
	styles := m.themeProvider.GetStyles()
	theme := m.themeProvider.GetTheme()

	style := styles.CardStyle.Width(width)

	if m.activePane == ControlsPane {
		style = style.BorderForeground(theme.Bases.Primary)
	}

	// Now playing section
	title := styles.SubHeadingStyle.Render("🎧 Now Playing")

	var nowPlaying string
	if m.nowPlayingTrack != "" {
		nowPlaying = styles.BodyStyle.Render(filepath.Base(m.nowPlayingTrack))
	} else {
		nowPlaying = styles.BodyStyle.Render("No track loaded")
	}

	status := styles.BodyStyle.Render(m.playbackStatus)
	volumeDisplay := styles.BodyStyle.Render(fmt.Sprintf("Volume: %.0f%%", m.volume*100))

	// Controls help
	controls := styles.BodyStyle.Render(
		"Controls:\n" +
			"Space: Play/Pause\n" +
			"n: Next  p: Previous\n" +
			"+/-: Volume\n" +
			"a: Add to playlist\n" +
			"d: Remove from playlist\n" +
			"Tab: Switch panes\n" +
			"h: Toggle help",
	)

	content := lipgloss.JoinVertical(
		lipgloss.Left,
		title,
		nowPlaying,
		status,
		volumeDisplay,
		"",
		controls,
	)

	return style.Render(content)
}

// renderHelp renders the help information
func (m *Model) renderHelp() string {
	styles := m.themeProvider.GetStyles()

	help := styles.CardStyle.Render(
		styles.HeadingStyle.Render("Jukebox Help") + "\n\n" +
			styles.BodyStyle.Render(
				"Navigation:\n"+
					"• Tab: Switch between panes (Directory → Playlist → Controls)\n"+
					"• Enter: Select item / Enter directory\n"+
					"• a: Add current file to playlist\n"+
					"• d: Remove selected item from playlist\n\n"+
					"Playback:\n"+
					"• Space: Play/Pause\n"+
					"• n: Next track\n"+
					"• p: Previous track\n"+
					"• +/-: Volume up/down\n\n"+
					"• h/?: Toggle this help\n"+
					"• q: Quit application",
			),
	)

	return help
}
