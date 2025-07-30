package services

// MathUtils provides mathematical utility functions
type MathUtils struct{}

// Limit constrains a value between min and max
func (mu *MathUtils) Limit(value, min, max int) int {
	if value < min {
		return min
	}
	if value > max {
		return max
	}
	return value
}

// Max returns the maximum of two integers
func (mu *MathUtils) Max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

// Min returns the minimum of two integers
func (mu *MathUtils) Min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

// Clamp is an alias for Limit for consistency with other libraries
func (mu *MathUtils) Clamp(value, min, max int) int {
	return mu.Limit(value, min, max)
}

// AbsInt returns the absolute value of an integer
func (mu *MathUtils) AbsInt(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

// Global math utils instance
var GlobalMathUtils = &MathUtils{}

// Convenience functions for direct usage
func Limit(value, min, max int) int {
	return GlobalMathUtils.Limit(value, min, max)
}

func Max(a, b int) int {
	return GlobalMathUtils.Max(a, b)
}

func Min(a, b int) int {
	return GlobalMathUtils.Min(a, b)
}

func Clamp(value, min, max int) int {
	return GlobalMathUtils.Clamp(value, min, max)
}
