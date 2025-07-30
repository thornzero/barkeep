# Text Layout and Wrapping Fixes

## Problem Summary

The application was experiencing text wrapping issues where UI components had lines that were too long, causing text to wrap unexpectedly and throwing off the layout of other components. Even with accurate display resolution detection, individual UI components weren't properly constraining their text content to fit within allocated space.

## Root Causes Identified

1. **Hard-coded layout calculations**: Fixed widths that didn't account for actual component sizes
2. **No text constraints**: Components allowed text to flow freely without width limits
3. **Imprecise dimension calculations**: Layout math didn't account for borders, padding, and spacing
4. **Missing text utilities**: No wrapping or truncation capabilities
5. **Lack of responsive sizing**: Components didn't adapt to different terminal sizes

## Solutions Implemented

### 1. Text Processing Utilities (`internal/services/text_utils.go`)

Created comprehensive text utilities for proper text handling:

#### Key Functions

- **`WrapText(text, width)`**: Wraps text to fit within specified width
- **`TruncateText(text, width)`**: Truncates text with ellipsis when too long
- **`FitTextToBox(text, width, height)`**: Fits text within width/height constraints
- **`GetTextDimensions(text)`**: Returns actual text dimensions
- **`CenterText(text, width)`**: Centers text within specified width

#### Example Usage

```go
// Wrap text to fit card width
wrappedText := services.GlobalTextUtils.WrapText(description, cardWidth)

// Truncate if too long
truncatedTitle := services.GlobalTextUtils.TruncateText(title, maxWidth)

// Fit text in specific box dimensions
constrainedText := services.GlobalTextUtils.FitTextToBox(details, width, height)
```

### 2. Layout Calculation Improvements (`internal/models/app.go`)

#### Precise Content Area Calculation

```go
// Before: Hard-coded values
contentWidth := m.width - 22  // Imprecise
contentHeight := m.height - 4

// After: Precise calculations
navBarWidth := 22           // Fixed navbar width
statusBarHeight := 1        // Status bar is single line  
bordersPadding := 4         // Account for borders and padding

contentWidth := m.width - navBarWidth - bordersPadding
contentHeight := m.height - statusBarHeight - bordersPadding
```

#### Status Bar Text Management

- Truncates status messages that exceed available width
- Calculates space for each status item
- Only adds exit hint if sufficient space available
- Uses proper spacing between status items

#### Navigation Bar Constraints

- Truncates navigation item text to fit sidebar width
- Constrains help text lines individually
- Accounts for borders and padding in text width calculations

### 3. Home Screen Carousel Fixes (`internal/models/screens.go`)

#### Card Content Constraints

```go
// Calculate content area within card borders
contentWidth := width - 4   // Account for border (2) and padding (2)
contentHeight := 8          // Fixed content height within card

// Constrain header text
headerText := item.Icon + " " + item.Title
if len(headerText) > contentWidth {
    headerText = services.GlobalTextUtils.TruncateText(headerText, contentWidth)
}

// Wrap description text
wrappedDescription := services.GlobalTextUtils.WrapText(item.Description, contentWidth)
```

#### Card Width Calculation

```go
// Before: Simple division without spacing
cardWidth := m.width / 3

// After: Account for spacing and padding
totalSpacing := 4  // 2 spaces between 3 cards
availableWidth := m.width - totalSpacing - 4  // -4 for overall padding
cardWidth := availableWidth / 3
```

#### Details Text Fitting

- Calculates remaining space for details text
- Uses `FitTextToBox()` to constrain details within available lines
- Only shows details if sufficient space exists

### 4. Screen Content Wrapping

All screen models now include:

- Width and height tracking
- Window size message handling
- Content text wrapping to fit available space
- Proper margin and padding calculations

#### Example (FoodAndDrinkModel)

```go
func (m *FoodAndDrinkModel) View() string {
    // Constrain content to available width
    contentWidth := m.width - 8 // Account for padding and margins
    if contentWidth < 20 {
        contentWidth = 20
    }
    
    // Wrap the content text to fit
    wrappedContent := services.GlobalTextUtils.WrapText(m.content, contentWidth)
    
    return theme.HeadingStyle.Render("🍺 Food & Drink") + "\n\n" +
        theme.BodyStyle.Render(wrappedContent)
}
```

## Testing Framework

### Layout Test Script (`test_layout.sh`)

Comprehensive testing script that verifies:

1. Home screen carousel text constraints
2. Navigation bar text fitting
3. Status bar proper sizing
4. Screen content wrapping
5. Terminal resize behavior

### Available Test Commands

```bash
# Test text layout improvements
make test-layout

# Test display information
make test-display

# Test full-screen functionality
make test-fullscreen
```

## Benefits Achieved

### 1. **No Text Overflow**

- All text content now fits within allocated component boundaries
- Long text is properly wrapped or truncated with ellipsis
- Components maintain their intended layout structure

### 2. **Responsive Design**

- Layout adapts to different terminal sizes
- Components scale appropriately with available space
- Minimum size constraints prevent unusable layouts

### 3. **Improved Readability**

- Text is properly formatted within visual boundaries
- Cards and components maintain clean appearance
- Status and navigation information always visible

### 4. **Performance**

- Text processing is efficient with caching where appropriate
- Layout calculations are precise and avoid re-calculation
- Responsive updates only when dimensions change

### 5. **Maintainability**

- Centralized text utilities for consistent behavior
- Clear separation of layout logic and content
- Easy to add new components with proper text constraints

## Before vs After Comparison

### Before

- Text would overflow card boundaries
- Status bar items would wrap to new lines
- Navigation text could exceed sidebar width
- Layout would break at smaller terminal sizes
- Components would interfere with each other

### After

- All text is constrained within component boundaries
- Proper wrapping and truncation prevent overflow
- Layout remains stable at all terminal sizes
- Components maintain visual separation
- Professional, clean appearance across all screens

## Usage Guidelines for Developers

When adding new UI components:

1. **Always use text utilities** for content that might vary in length
2. **Calculate precise dimensions** accounting for borders, padding, and spacing
3. **Implement responsive behavior** by handling `tea.WindowSizeMsg`
4. **Test at different terminal sizes** to ensure proper constraints
5. **Use minimum size constraints** to prevent unusable layouts

### Example New Component

```go
func (m *MyModel) View() string {
    // Calculate available space
    contentWidth := m.width - 4  // Account for borders/padding
    
    // Constrain text content
    title := services.GlobalTextUtils.TruncateText(m.title, contentWidth)
    body := services.GlobalTextUtils.WrapText(m.body, contentWidth)
    
    // Render with proper constraints
    return theme.CardStyle.Width(m.width).Render(
        lipgloss.JoinVertical(lipgloss.Left, title, "", body)
    )
}
```

These improvements ensure that the Barkeep application provides a consistent, professional appearance across all terminal sizes and prevents the text wrapping issues that were breaking the layout.
