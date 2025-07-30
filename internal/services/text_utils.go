package services

import (
	"strings"
	"unicode/utf8"
)

// TextUtils provides utilities for text formatting and sizing
type TextUtils struct{}

// WrapText wraps text to fit within the specified width
func (tu *TextUtils) WrapText(text string, width int) string {
	if width <= 0 {
		return text
	}

	words := strings.Fields(text)
	if len(words) == 0 {
		return text
	}

	var lines []string
	var currentLine []string
	currentLength := 0

	for _, word := range words {
		wordLength := utf8.RuneCountInString(word)

		// If adding this word would exceed the width, start a new line
		if currentLength > 0 && currentLength+1+wordLength > width {
			lines = append(lines, strings.Join(currentLine, " "))
			currentLine = []string{word}
			currentLength = wordLength
		} else {
			currentLine = append(currentLine, word)
			if currentLength > 0 {
				currentLength += 1 // Space between words
			}
			currentLength += wordLength
		}
	}

	// Add the last line
	if len(currentLine) > 0 {
		lines = append(lines, strings.Join(currentLine, " "))
	}

	return strings.Join(lines, "\n")
}

// TruncateText truncates text to fit within the specified width
func (tu *TextUtils) TruncateText(text string, width int) string {
	if width <= 0 {
		return ""
	}

	runes := []rune(text)
	if len(runes) <= width {
		return text
	}

	if width <= 3 {
		return strings.Repeat(".", width)
	}

	return string(runes[:width-3]) + "..."
}

// TruncateLines truncates each line of multi-line text
func (tu *TextUtils) TruncateLines(text string, width int) string {
	lines := strings.Split(text, "\n")
	var truncatedLines []string

	for _, line := range lines {
		truncatedLines = append(truncatedLines, tu.TruncateText(line, width))
	}

	return strings.Join(truncatedLines, "\n")
}

// FitTextToBox ensures text fits within a box of specified width and height
func (tu *TextUtils) FitTextToBox(text string, width, height int) string {
	if width <= 0 || height <= 0 {
		return ""
	}

	// First wrap the text to fit the width
	wrappedText := tu.WrapText(text, width)
	lines := strings.Split(wrappedText, "\n")

	// If we have too many lines, truncate
	if len(lines) > height {
		lines = lines[:height]

		// If we had to truncate, add ellipsis to the last line
		if height > 0 {
			lastLine := lines[height-1]
			if len(lastLine) > width-3 {
				lines[height-1] = tu.TruncateText(lastLine, width)
			} else if len(lastLine) <= width-3 {
				lines[height-1] = lastLine + "..."
			}
		}
	}

	return strings.Join(lines, "\n")
}

// PadText pads text to a specific width (useful for alignment)
func (tu *TextUtils) PadText(text string, width int, padChar rune) string {
	textWidth := utf8.RuneCountInString(text)
	if textWidth >= width {
		return text
	}

	padding := width - textWidth
	return text + strings.Repeat(string(padChar), padding)
}

// CenterText centers text within a specified width
func (tu *TextUtils) CenterText(text string, width int) string {
	textWidth := utf8.RuneCountInString(text)
	if textWidth >= width {
		return text
	}

	leftPadding := (width - textWidth) / 2
	rightPadding := width - textWidth - leftPadding

	return strings.Repeat(" ", leftPadding) + text + strings.Repeat(" ", rightPadding)
}

// GetTextDimensions returns the width and height of text
func (tu *TextUtils) GetTextDimensions(text string) (width, height int) {
	lines := strings.Split(text, "\n")
	height = len(lines)

	maxWidth := 0
	for _, line := range lines {
		lineWidth := utf8.RuneCountInString(line)
		if lineWidth > maxWidth {
			maxWidth = lineWidth
		}
	}

	return maxWidth, height
}

// SplitTextToFit splits text into multiple parts that fit within constraints
func (tu *TextUtils) SplitTextToFit(text string, maxWidth, maxHeight int) []string {
	if maxWidth <= 0 || maxHeight <= 0 {
		return []string{text}
	}

	var parts []string
	words := strings.Fields(text)

	var currentPart []string
	currentLines := 0
	currentLineLength := 0

	for _, word := range words {
		wordLength := utf8.RuneCountInString(word)

		// Check if adding this word would exceed line width
		needNewLine := currentLineLength > 0 && currentLineLength+1+wordLength > maxWidth

		// Check if we need a new part
		if needNewLine {
			currentLines++
			currentLineLength = 0
		}

		// If we exceed max height, start a new part
		if currentLines >= maxHeight {
			if len(currentPart) > 0 {
				parts = append(parts, strings.Join(currentPart, " "))
				currentPart = []string{}
				currentLines = 0
				currentLineLength = 0
			}
		}

		currentPart = append(currentPart, word)
		if currentLineLength > 0 {
			currentLineLength += 1 // Space
		}
		currentLineLength += wordLength
	}

	// Add the last part
	if len(currentPart) > 0 {
		parts = append(parts, strings.Join(currentPart, " "))
	}

	return parts
}

func (tu *TextUtils) SpanTextFill(text string, width int) string {
	return tu.PadText(text, width, '+')
}

// Global text utils instance
var Txt = &TextUtils{}
