package home

import (
	"github.com/charmbracelet/lipgloss"
	"github.com/thornzero/barkeep/internal/services"
)

// View renders the home screen
func (m *Model) View() string {
	if len(m.items) == 0 {
		return "No items to display"
	}

	styles := m.themeProvider.GetStyles()

	// Create the main carousel display
	carousel := m.renderCarousel()

	// Add navigation indicators
	indicators := m.renderIndicators()

	// Add instructions (constrain to available width)
	instructions := m.renderInstructions()

	// Combine all elements
	content := lipgloss.JoinVertical(
		lipgloss.Center,
		styles.HeadingStyle.Render("🏠 Barkeep Dashboard"),
		"",
		carousel,
		"",
		indicators,
		"",
		instructions,
	)

	return content
}

// renderCarousel creates the main carousel display
func (m *Model) renderCarousel() string {
	const (
		minCardWidth = 60
		cardSpacing  = 2
		cardBorder   = 1
	)

	// Ensure minimum dimensions
	if m.width < minCardWidth*3+cardSpacing*4 {
		// If too narrow, show single card
		return m.renderSingleCard()
	}

	// Calculate available space for cards
	totalSpacing := cardSpacing * 4 // Space around and between 3 cards
	totalBorders := cardBorder * 6  // 2 borders per card * 3 cards
	availableWidth := m.width - totalSpacing - totalBorders
	cardWidth := services.Limit(availableWidth/3, minCardWidth, availableWidth)

	// Show current card and neighbors
	prevIndex := (m.currentIndex - 1 + len(m.items)) % len(m.items)
	nextIndex := (m.currentIndex + 1) % len(m.items)

	prevCard := m.renderCard(m.items[prevIndex], cardWidth, false)
	currentCard := m.renderCard(m.items[m.currentIndex], cardWidth, true)
	nextCard := m.renderCard(m.items[nextIndex], cardWidth, false)

	return lipgloss.JoinHorizontal(
		lipgloss.Top,
		prevCard,
		currentCard,
		nextCard,
	)
}

// renderSingleCard renders a single card when space is limited
func (m *Model) renderSingleCard() string {
	cardWidth := services.Limit(m.width-8, 40, m.width-8)
	return m.renderCard(m.items[m.currentIndex], cardWidth, true)
}

// renderCard renders an individual card
func (m *Model) renderCard(item CarouselItem, width int, isActive bool) string {
	styles := m.themeProvider.GetStyles()

	var style lipgloss.Style
	if isActive {
		style = styles.CardActiveStyle
	} else {
		style = styles.CardStyle
	}

	content := item.Icon + " " + item.Title + "\n\n" + item.Description

	if isActive && m.showDetails {
		content += "\n\n" + item.Details
	}

	// Constrain content to card width
	wrappedContent := services.Txt.WrapText(content, width-4) // Account for padding

	return style.Width(width).Render(wrappedContent)
}

// renderIndicators creates the navigation indicators
func (m *Model) renderIndicators() string {
	indicators := ""
	for i := range m.items {
		if i == m.currentIndex {
			indicators += "●"
		} else {
			indicators += "○"
		}
		if i < len(m.items)-1 {
			indicators += " "
		}
	}

	styles := m.themeProvider.GetStyles()
	return styles.SubHeadingStyle.Render(indicators)
}

// renderInstructions creates the help text
func (m *Model) renderInstructions() string {
	instructions := "← → : Navigate   Enter: Select   d: Toggle details   Tab: Focus navigation"

	// Constrain instructions to available width
	maxWidth := m.width - 4 // Account for padding
	if len(instructions) > maxWidth {
		instructions = services.Txt.TruncateText(instructions, maxWidth)
	}

	styles := m.themeProvider.GetStyles()
	return styles.BodyStyle.Render(instructions)
}
