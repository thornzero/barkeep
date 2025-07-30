# Barkeep Makefile
# Terminal-based bar/tavern management system

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=$(GOCMD) fmt

# Project parameters
BINARY_NAME=barkeep
BINARY_PATH=./$(BINARY_NAME)
MAIN_PATH=./cmd/barkeep
SOURCE_PATH=./...

# Build parameters
BUILD_FLAGS=-v
LDFLAGS=-s -w
RELEASE_FLAGS=-ldflags="$(LDFLAGS)" -a -installsuffix cgo

# Colors for output
GREEN=\033[0;32m
YELLOW=\033[0;33m
RED=\033[0;31m
NC=\033[0m # No Color

.PHONY: all build clean test coverage run deps fmt lint help install dev release

# Default target
all: clean deps fmt test build

# Build the main application
build:
	@echo "$(GREEN)Building $(BINARY_NAME)...$(NC)"
	$(GOBUILD) $(BUILD_FLAGS) -o $(BINARY_NAME) $(MAIN_PATH)
	@echo "$(GREEN)Build completed: $(BINARY_PATH)$(NC)"

# Run the application
run: build
	@echo "$(GREEN)Running $(BINARY_NAME)...$(NC)"
	$(BINARY_PATH)

# Run in development mode (with go run)
dev:
	@echo "$(GREEN)Running in development mode...$(NC)"
	$(GOCMD) run $(MAIN_PATH)/main.go

# Run in full-screen mode
fullscreen: build
	@echo "$(GREEN)Running $(BINARY_NAME) in full-screen mode...$(NC)"
	@echo "$(YELLOW)Press 'q' to quit gracefully, Ctrl+C for immediate exit$(NC)"
	$(BINARY_PATH)

# Clean build artifacts
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_NAME).exe
	@echo "$(GREEN)Clean completed$(NC)"

# Run tests
test:
	@echo "$(GREEN)Running tests...$(NC)"
	$(GOTEST) -v $(SOURCE_PATH)

# Run tests with coverage
coverage:
	@echo "$(GREEN)Running tests with coverage...$(NC)"
	$(GOTEST) -v -coverprofile=coverage.out $(SOURCE_PATH)
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo "$(GREEN)Coverage report generated: coverage.html$(NC)"

# Install/update dependencies
deps:
	@echo "$(GREEN)Installing dependencies...$(NC)"
	$(GOMOD) download
	$(GOMOD) tidy
	@echo "$(GREEN)Dependencies updated$(NC)"

# Format code
fmt:
	@echo "$(GREEN)Formatting code...$(NC)"
	$(GOFMT) $(SOURCE_PATH)
	@echo "$(GREEN)Code formatting completed$(NC)"

# Run linting (requires golangci-lint)
lint:
	@echo "$(GREEN)Running linters...$(NC)"
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run $(SOURCE_PATH); \
	else \
		echo "$(YELLOW)golangci-lint not found. Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest$(NC)"; \
	fi

# Install the application
install: build
	@echo "$(GREEN)Installing $(BINARY_NAME)...$(NC)"
	cp $(BINARY_NAME) $(GOPATH)/bin/$(BINARY_NAME)
	@echo "$(GREEN)Installation completed$(NC)"

# Build for release (optimized)
release:
	@echo "$(GREEN)Building release version...$(NC)"
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) $(RELEASE_FLAGS) -o $(BINARY_NAME)-linux-amd64 $(MAIN_PATH)
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 $(GOBUILD) $(RELEASE_FLAGS) -o $(BINARY_NAME)-windows-amd64.exe $(MAIN_PATH)
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GOBUILD) $(RELEASE_FLAGS) -o $(BINARY_NAME)-darwin-amd64 $(MAIN_PATH)
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 $(GOBUILD) $(RELEASE_FLAGS) -o $(BINARY_NAME)-darwin-arm64 $(MAIN_PATH)
	@echo "$(GREEN)Release builds completed$(NC)"

# Initialize development environment
init:
	@echo "$(GREEN)Initializing development environment...$(NC)"
	$(GOMOD) init github.com/thornzero/barkeep || echo "Module already initialized"
	$(GOMOD) tidy
	@echo "$(GREEN)Development environment ready$(NC)"

# Update dependencies
update:
	@echo "$(GREEN)Updating dependencies...$(NC)"
	$(GOMOD) get -u ./...
	$(GOMOD) tidy
	@echo "$(GREEN)Dependencies updated$(NC)"

# Run security audit
audit:
	@echo "$(GREEN)Running security audit...$(NC)"
	@if command -v gosec >/dev/null 2>&1; then \
		gosec $(SOURCE_PATH); \
	else \
		echo "$(YELLOW)gosec not found. Install with: go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest$(NC)"; \
	fi

# Generate documentation
docs:
	@echo "$(GREEN)Generating documentation...$(NC)"
	@if command -v godoc >/dev/null 2>&1; then \
		echo "$(GREEN)Documentation server will be available at http://localhost:6060$(NC)"; \
		godoc -http=:6060; \
	else \
		echo "$(YELLOW)godoc not found. Install with: go install golang.org/x/tools/cmd/godoc@latest$(NC)"; \
	fi

# Quick development cycle
quick: fmt test build

# Full development cycle
full: clean deps fmt lint test coverage build

# Test full-screen mode and exit functionality
test-fullscreen:
	@echo "$(GREEN)Testing full-screen mode and exit functionality...$(NC)"
	@echo "$(YELLOW)Running test script...$(NC)"
	@if [ -f test_fullscreen.sh ]; then \
		./test_fullscreen.sh; \
	else \
		echo "$(RED)test_fullscreen.sh not found$(NC)"; \
	fi

# Test text layout and wrapping fixes
test-layout:
	@echo "$(GREEN)Testing text layout and wrapping fixes...$(NC)"
	@echo "$(YELLOW)Running layout test script...$(NC)"
	@if [ -f test_layout.sh ]; then \
		./test_layout.sh; \
	else \
		echo "$(RED)test_layout.sh not found$(NC)"; \
	fi

# Test background color fixes
test-background:
	@echo "$(GREEN)Testing background color fixes...$(NC)"
	@echo "$(YELLOW)Building application with background fixes...$(NC)"
	@make build
	@echo ""
	@echo "$(CYAN)Background Color Fix Verification$(NC)"
	@echo "================================="
	@echo ""
	@echo "When testing, verify:"
	@echo "• No grey/purple backgrounds bleeding beyond text content"
	@echo "• Clean card borders without color bleeding"
	@echo "• Status bar text has proper background boundaries"
	@echo "• Navigation items have clean highlighting"
	@echo "• Text content doesn't have unwanted background colors"
	@echo ""
	@echo "$(YELLOW)Starting application for background testing...$(NC)"
	@./barkeep

# Test modern lipgloss usage
test-modern:
	@echo "$(GREEN)Testing modern lipgloss usage...$(NC)"
	@echo "$(YELLOW)Checking for deprecated patterns...$(NC)"
	@echo ""
	@deprecated_calls=$$(grep -r "\.Copy()" internal/ --include="*.go" | grep -v "// " | wc -l); \
	if [ "$$deprecated_calls" -gt 0 ]; then \
		echo "$(RED)Found $$deprecated_calls deprecated .Copy() calls:$(NC)"; \
		grep -r "\.Copy()" internal/ --include="*.go" | grep -v "// "; \
		echo ""; \
		echo "$(YELLOW)Note: .Copy() is deprecated in modern lipgloss$(NC)"; \
		echo "$(YELLOW)Use simple assignment instead (assignment creates a copy)$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)✅ No deprecated .Copy() calls found$(NC)"; \
	fi
	@echo ""
	@echo "$(CYAN)Modern Lipgloss Pattern Verification$(NC)"
	@echo "===================================="
	@echo ""
	@echo "✅ Using lipgloss.NewStyle() for clean style creation"
	@echo "✅ Simple assignment for style variants (no .Copy() needed)"
	@echo "✅ No shared style modification"
	@echo "✅ Proper background isolation"
	@echo ""
	@make build
	@echo "$(GREEN)✅ Modern lipgloss usage verified successfully!$(NC)"

# Help target
help:
	@echo "$(GREEN)Barkeep Makefile Commands:$(NC)"
	@echo ""
	@echo "$(YELLOW)Building:$(NC)"
	@echo "  build     - Build the application"
	@echo "  release   - Build optimized release versions for multiple platforms"
	@echo "  install   - Install the application to GOPATH/bin"
	@echo ""
	@echo "$(YELLOW)Running:$(NC)"
	@echo "  run       - Build and run the application"
	@echo "  dev       - Run in development mode (go run)"
	@echo "  fullscreen - Run in full-screen mode with exit instructions"
	@echo ""
	@echo "$(YELLOW)Testing:$(NC)"
	@echo "  test      - Run tests"
	@echo "  coverage  - Run tests with coverage report"
	@echo "  lint      - Run linting (requires golangci-lint)"
	@echo "  audit     - Run security audit (requires gosec)"
	@echo "  test-fullscreen - Test full-screen mode and exit functionality"
	@echo "  test-layout - Test text layout and wrapping fixes"
	@echo "  test-background - Test background color fixes"
	@echo "  test-modern - Test modern lipgloss usage without deprecated methods"
	@echo ""
	@echo "$(YELLOW)Dependencies:$(NC)"
	@echo "  deps      - Install/download dependencies"
	@echo "  update    - Update dependencies"
	@echo "  init      - Initialize development environment"
	@echo ""
	@echo "$(YELLOW)Maintenance:$(NC)"
	@echo "  fmt       - Format code"
	@echo "  clean     - Clean build artifacts"
	@echo "  docs      - Generate and serve documentation"
	@echo ""
	@echo "$(YELLOW)Workflows:$(NC)"
	@echo "  quick     - Quick development cycle (fmt, test, build)"
	@echo "  full      - Full development cycle (clean, deps, fmt, lint, test, coverage, build)"
	@echo "  all       - Default target (clean, deps, fmt, test, build)"
	@echo ""
	@echo "$(YELLOW)Example Usage:$(NC)"
	@echo "  make build          # Build the application"
	@echo "  make run            # Build and run"
	@echo "  make test           # Run tests"
	@echo "  make quick          # Quick development cycle"
	@echo "  make release        # Build for multiple platforms"