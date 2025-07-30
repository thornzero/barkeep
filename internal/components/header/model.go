package header

import (
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/thornzero/barkeep/internal/theme"
)

// AnimationFrame represents a frame in the logo animation
type AnimationFrame struct {
	Content string
	Style   string
}

// Model represents the header component state
type Model struct {
	// Configuration
	width  int
	height int

	// Content
	currentScreenTitle string
	currentUser        string

	// Logo/Animation
	logoFrames     []AnimationFrame
	currentFrame   int
	animationSpeed time.Duration
	lastUpdate     time.Time
	animating      bool

	// Dependencies
	themeProvider theme.Provider
}

// NewModel creates a new header component
func NewModel(themeProvider theme.Provider) *Model {
	// Define logo animation frames
	logoFrames := []AnimationFrame{
		{Content: "🍺", Style: "primary"},
		{Content: "🍻", Style: "secondary"},
		{Content: "🥂", Style: "tertiary"},
		{Content: "🍷", Style: "primary"},
		{Content: "🍺", Style: "secondary"},
	}

	return &Model{
		width:          80,
		height:         3,
		logoFrames:     logoFrames,
		currentFrame:   0,
		animationSpeed: time.Millisecond * 800,
		lastUpdate:     time.Now(),
		animating:      true,
		themeProvider:  themeProvider,
	}
}

// SetSize sets the header component size
func (m *Model) SetSize(width, height int) {
	m.width = width
	m.height = height
}

// SetScreenTitle updates the current screen title
func (m *Model) SetScreenTitle(title string) {
	m.currentScreenTitle = title
}

// SetUser updates the current user display
func (m *Model) SetUser(user string) {
	m.currentUser = user
}

// SetAnimating controls whether the logo animation is active
func (m *Model) SetAnimating(animating bool) {
	m.animating = animating
}

// Update handles messages and updates the header state
func (m *Model) Update(msg tea.Msg) (*Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.SetSize(msg.Width, 3) // Header is always 3 lines tall

	case animationTickMsg:
		if m.animating {
			m.currentFrame = (m.currentFrame + 1) % len(m.logoFrames)
			return m, m.tick()
		}
	}

	// Auto-advance animation based on time
	if m.animating && time.Since(m.lastUpdate) >= m.animationSpeed {
		m.currentFrame = (m.currentFrame + 1) % len(m.logoFrames)
		m.lastUpdate = time.Now()
		return m, m.tick()
	}

	return m, nil
}

// Animation message
type animationTickMsg struct{}

// tick returns a command for the next animation frame
func (m *Model) tick() tea.Cmd {
	return tea.Tick(m.animationSpeed, func(t time.Time) tea.Msg {
		return animationTickMsg{}
	})
}

// Init initializes the header component
func (m *Model) Init() tea.Cmd {
	if m.animating {
		return m.tick()
	}
	return nil
}
