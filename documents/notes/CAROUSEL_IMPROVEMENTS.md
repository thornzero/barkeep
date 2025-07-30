# Carousel Implementation Improvements

## Issues Fixed

### 1. **Missing `services.Limit` Function**

**Problem**: The code was calling `services.Limit()` which didn't exist.
**Solution**: Created comprehensive math utilities in `internal/services/math_utils.go`:

```go
// Available functions:
services.Limit(value, min, max int) int  // Constrains value between min and max
services.Min(a, b int) int               // Returns minimum of two values
services.Max(a, b int) int               // Returns maximum of two values
services.Clamp(value, min, max int) int  // Alias for Limit
```

### 2. **Incorrect Table Usage**

**Problem**: You were passing rendered card strings directly to the table as rows, but lipgloss tables expect structured data organized in rows and columns.

**Before** (incorrect):

```go
// This doesn't work - passing rendered strings as table rows
cards := []string{card1, card2, card3}
table.New().Rows(cards)
```

**After** (correct):

```go
// Proper table structure - each card is a column in a single row
tableData := [][]string{cardContents}  // Single row, multiple columns
table.New().Rows(tableData...)
```

### 3. **Layout Calculation Issues**

**Problem**: Space calculations didn't account for all spacing, borders, and padding.

**Improvements**:

- **Responsive design**: Shows single card when space is too narrow
- **Precise calculations**: Accounts for spacing around and between cards
- **Border accounting**: Properly calculates border space for each card
- **Minimum constraints**: Ensures cards are always readable

## Technical Implementation

### Carousel Structure

```go
func (m *HomeModel) renderCarousel() string {
    // 1. Check if we have enough space for 3 cards
    if m.width < minCardWidth*3+cardSpacing*4 {
        return m.renderSingleCard()  // Fallback to single card
    }
    
    // 2. Calculate precise dimensions
    totalSpacing := cardSpacing * 4  // Around and between cards
    totalBorders := cardBorder * 6   // 2 borders per card * 3 cards
    availableWidth := m.width - totalSpacing - totalBorders
    cardWidth := services.Limit(availableWidth/3, minCardWidth, availableWidth)
    
    // 3. Prepare table data (content only, styling handled by table)
    var cardContents []string
    for i := -1; i <= 1; i++ {
        // Get card content without styling
        cardContent := m.renderCardContent(item, i == 0, cardWidth)
        cardContents = append(cardContents, cardContent)
    }
    
    // 4. Create table with proper styling per column
    tableData := [][]string{cardContents}
    table := table.New().
        Border(lipgloss.HiddenBorder()).
        StyleFunc(func(row, col int) lipgloss.Style {
            // Different style for each card position
        }).
        Rows(tableData...)
}
```

### Card Content Separation

**Key Innovation**: Separated content generation from styling:

- **`renderCardContent()`**: Generates text content with proper wrapping/truncation
- **Table StyleFunc**: Handles visual styling (colors, borders, backgrounds)
- **`renderCard()`**: Kept for compatibility, wraps content with individual card styling

### Responsive Behavior

```go
// Graceful degradation based on available space
if m.width < minCardWidth*3+cardSpacing*4 {
    return m.renderSingleCard()  // Shows just current card
}
```

## Benefits of the New Implementation

### ✅ **Proper Table Usage**

- Table component used correctly with structured data
- Each card is a column, not a pre-rendered string
- Table handles layout and spacing automatically

### ✅ **Better Responsive Design**

- **Wide screens**: Shows 3-card carousel
- **Narrow screens**: Falls back to single card view
- **Smooth transitions**: Layout adapts naturally to terminal resize

### ✅ **Improved Styling System**

- **Separation of concerns**: Content vs. styling handled separately
- **Consistent theming**: Table StyleFunc applies theme colors properly
- **Active card highlighting**: Current card clearly distinguished

### ✅ **Performance Optimizations**

- **Efficient calculations**: No redundant style applications
- **Clean rendering**: Table handles complex layout math
- **Memory efficient**: Content generated once, styled by table

## Configuration Constants

```go
const (
    minCardWidth  = 60   // Minimum readable card width
    minCardHeight = 15   // Minimum readable card height
    cardSpacing   = 2    // Space between cards
    cardPadding   = 2    // Internal card padding
    cardBorder    = 1    // Card border width
)
```

## Advanced Features

### 1. **Adaptive Card Sizing**

Cards automatically resize based on available space while maintaining readability.

### 2. **Content Constraint System**

- Text wrapping within card boundaries
- Truncation with ellipsis for long content
- Details expansion only when space permits

### 3. **Fallback Rendering**

Single card mode for narrow terminals ensures functionality at any size.

## Usage Examples

### Testing the Carousel

```bash
# Test the improved carousel
make test-layout

# Or run directly
make run
# Navigate with ← → keys
# Press 'd' to toggle details
# Resize terminal to test responsive behavior
```

### Expected Behavior

1. **Normal view**: 3 cards (prev, current, next) with current highlighted
2. **Narrow terminal**: Single card view with proper styling
3. **Details toggle**: Shows/hides additional info when space permits
4. **Smooth navigation**: Left/right keys cycle through items
5. **Proper text fitting**: No overflow or wrapping issues

## Comparison: Before vs After

### Before (Issues)

```go
// Incorrect table usage
cards := []string{renderedCard1, renderedCard2, renderedCard3}
table.New().Rows(cards)  // ❌ Wrong data structure

// Missing functions
cardWidth := services.Limit(...)  // ❌ Function didn't exist

// Poor responsive behavior
// Fixed card width regardless of terminal size
```

### After (Fixed)

```go
// Correct table usage
tableData := [][]string{cardContents}  // ✅ Proper structure
table.New().StyleFunc(...).Rows(tableData...)

// Complete math utilities
cardWidth := services.Limit(width, minWidth, maxWidth)  // ✅ Function exists

// Responsive design
if m.width < minCardWidth*3+cardSpacing*4 {
    return m.renderSingleCard()  // ✅ Graceful degradation
}
```

## Developer Guidelines

When working with the carousel:

1. **Use the constants**: Don't hard-code spacing or sizing values
2. **Test responsiveness**: Always test at different terminal sizes
3. **Respect content constraints**: Use text utilities for proper fitting
4. **Maintain separation**: Keep content generation separate from styling

The carousel now provides a robust, responsive, and visually appealing interface that properly utilizes the lipgloss table component while maintaining excellent performance and readability across all terminal sizes.
