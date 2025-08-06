package services

import (
	"context"
	"fmt"
	"log"
	"sync"
	"time"

	"periph.io/x/conn/v3/i2c"
	"periph.io/x/conn/v3/i2c/i2creg"
	"periph.io/x/host/v3"
)

// Button represents the available physical buttons
type Button int

const (
	ButtonA Button = iota
	ButtonB
	ButtonX
	ButtonY
	ButtonUp
	ButtonDown
)

func (b Button) String() string {
	switch b {
	case ButtonA:
		return "A"
	case ButtonB:
		return "B"
	case ButtonX:
		return "X"
	case ButtonY:
		return "Y"
	case ButtonUp:
		return "Up"
	case ButtonDown:
		return "Down"
	default:
		return "Unknown"
	}
}

// ButtonMap represents the current state of all buttons
type ButtonMap struct {
	mu     sync.RWMutex
	states map[Button]bool
}

// NewButtonMap creates a new ButtonMap with all buttons released
func NewButtonMap() *ButtonMap {
	return &ButtonMap{
		states: make(map[Button]bool),
	}
}

// Get returns the current state of a button
func (bm *ButtonMap) Get(button Button) bool {
	bm.mu.RLock()
	defer bm.mu.RUnlock()
	return bm.states[button]
}

// Set updates the state of a button
func (bm *ButtonMap) Set(button Button, pressed bool) {
	bm.mu.Lock()
	defer bm.mu.Unlock()
	bm.states[button] = pressed
}

// GetAll returns a copy of all button states
func (bm *ButtonMap) GetAll() map[Button]bool {
	bm.mu.RLock()
	defer bm.mu.RUnlock()
	
	result := make(map[Button]bool)
	for k, v := range bm.states {
		result[k] = v
	}
	return result
}

// MegaIndController handles communication with the MegaInd hardware
type MegaIndController struct {
	mu           sync.RWMutex
	i2cDevice    i2c.Dev
	isRunning    bool
	ctx          context.Context
	cancel       context.CancelFunc
	buttonMap    *ButtonMap
	inputChannel chan *ButtonMap
	
	// LED flashing state
	ledFlashing  [4]bool
	ledMutex     sync.RWMutex
}

const (
	// I2C device address and registers
	deviceAddress           = 0x50
	digitalInputRegister    = 0x03
	analogInputRegister1    = 0x1C
	analogInputRegister2    = 0x1E
	pwmFanOutputRegister    = 0x14
	pwmLedOutputRegister0   = 0x16
	pwmLedOutputRegister1   = 0x18
	
	// Analog input thresholds for 5V button detection
	ainLowerLimit = 114.75
	ainUpperLimit = 140.25
	
	// Polling interval
	inputPollingInterval = 50 * time.Millisecond
)

var (
	pwmLedOutputRegisters = []int{pwmLedOutputRegister0, pwmLedOutputRegister1}
)

// Singleton instance
var (
	controllerInstance *MegaIndController
	controllerOnce     sync.Once
)

// GetMegaIndController returns the singleton instance of MegaIndController
func GetMegaIndController() *MegaIndController {
	controllerOnce.Do(func() {
		controllerInstance = &MegaIndController{
			buttonMap:    NewButtonMap(),
			inputChannel: make(chan *ButtonMap, 10),
		}
	})
	return controllerInstance
}

// Init initializes the MegaInd controller with the specified I2C bus
func (m *MegaIndController) Init(i2cBusNumber int) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	
	if m.isRunning {
		return fmt.Errorf("controller is already running")
	}
	
	// Initialize the host
	if _, err := host.Init(); err != nil {
		return fmt.Errorf("failed to initialize host: %w", err)
	}
	
	// Open I2C bus
	bus, err := i2creg.Open(fmt.Sprintf("I2C%d", i2cBusNumber))
	if err != nil {
		return fmt.Errorf("failed to open I2C bus %d: %w", i2cBusNumber, err)
	}
	
	// Create I2C device
	m.i2cDevice = i2c.Dev{Bus: bus, Addr: deviceAddress}
	
	// Create context for cancellation
	m.ctx, m.cancel = context.WithCancel(context.Background())
	m.isRunning = true
	
	// Start input polling goroutine
	go m.inputPollingLoop()
	
	log.Printf("MegaInd controller initialized on I2C bus %d", i2cBusNumber)
	return nil
}

// GetInputChannel returns the channel for receiving button state updates
func (m *MegaIndController) GetInputChannel() <-chan *ButtonMap {
	return m.inputChannel
}

// GetButtonMap returns the current button map
func (m *MegaIndController) GetButtonMap() *ButtonMap {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.buttonMap
}

// inputPollingLoop continuously polls the hardware for input changes
func (m *MegaIndController) inputPollingLoop() {
	ticker := time.NewTicker(inputPollingInterval)
	defer ticker.Stop()
	
	for {
		select {
		case <-m.ctx.Done():
			return
		case <-ticker.C:
			if err := m.pollInputs(); err != nil {
				log.Printf("Error polling inputs: %v", err)
			}
		}
	}
}

// pollInputs reads the current state of all inputs
func (m *MegaIndController) pollInputs() error {
	// Read digital inputs (buttons A, B, X, Y)
	digitalState, err := m.readByteRegister(digitalInputRegister)
	if err != nil {
		return fmt.Errorf("failed to read digital inputs: %w", err)
	}
	
	// Invert bits (active low) and mask to 4 bits
	digitalState = (^digitalState) & 0x0F
	
	// Update button states
	m.buttonMap.Set(ButtonA, (digitalState>>0)&1 == 1)
	m.buttonMap.Set(ButtonB, (digitalState>>1)&1 == 1)
	m.buttonMap.Set(ButtonX, (digitalState>>2)&1 == 1)
	m.buttonMap.Set(ButtonY, (digitalState>>3)&1 == 1)
	
	// Read analog inputs (Up/Down buttons)
	ain1, err := m.readWordRegister(analogInputRegister1)
	if err != nil {
		return fmt.Errorf("failed to read analog input 1: %w", err)
	}
	
	ain2, err := m.readWordRegister(analogInputRegister2)
	if err != nil {
		return fmt.Errorf("failed to read analog input 2: %w", err)
	}
	
	// Convert to float and check thresholds
	ain1Float := float64(ain1)
	ain2Float := float64(ain2)
	
	m.buttonMap.Set(ButtonUp, ain1Float > ainLowerLimit && ain1Float < ainUpperLimit)
	m.buttonMap.Set(ButtonDown, ain2Float > ainLowerLimit && ain2Float < ainUpperLimit)
	
	// Send update through channel (non-blocking)
	select {
	case m.inputChannel <- m.buttonMap:
	default:
		// Channel is full, skip this update
	}
	
	return nil
}

// LightButton sets the brightness of an LED (0-100)
func (m *MegaIndController) LightButton(ledIndex int, brightness int) error {
	if ledIndex < 0 || ledIndex >= len(pwmLedOutputRegisters) {
		return fmt.Errorf("invalid LED index: %d", ledIndex)
	}
	
	if brightness < 0 || brightness > 100 {
		return fmt.Errorf("brightness must be between 0 and 100, got: %d", brightness)
	}
	
	register := pwmLedOutputRegisters[ledIndex]
	if err := m.writeByteRegister(register, uint8(brightness)); err != nil {
		return fmt.Errorf("failed to set LED %d brightness: %w", ledIndex, err)
	}
	
	log.Printf("LED %d brightness set to: %d", ledIndex, brightness)
	return nil
}

// StartFlashing starts flashing an LED with the specified parameters
func (m *MegaIndController) StartFlashing(ledIndex int, brightness int, interval time.Duration) error {
	if ledIndex < 0 || ledIndex >= len(m.ledFlashing) {
		return fmt.Errorf("invalid LED index: %d", ledIndex)
	}
	
	if brightness < 0 || brightness > 100 {
		return fmt.Errorf("brightness must be between 0 and 100, got: %d", brightness)
	}
	
	m.ledMutex.Lock()
	m.ledFlashing[ledIndex] = true
	m.ledMutex.Unlock()
	
	go m.flashLED(ledIndex, brightness, interval)
	
	log.Printf("Started flashing LED %d with brightness %d and interval %v", ledIndex, brightness, interval)
	return nil
}

// StopFlashing stops flashing an LED
func (m *MegaIndController) StopFlashing(ledIndex int) error {
	if ledIndex < 0 || ledIndex >= len(m.ledFlashing) {
		return fmt.Errorf("invalid LED index: %d", ledIndex)
	}
	
	m.ledMutex.Lock()
	m.ledFlashing[ledIndex] = false
	m.ledMutex.Unlock()
	
	// Turn off the LED
	if err := m.LightButton(ledIndex, 0); err != nil {
		return fmt.Errorf("failed to turn off LED %d: %w", ledIndex, err)
	}
	
	log.Printf("Stopped flashing LED %d", ledIndex)
	return nil
}

// flashLED handles the flashing logic for an LED
func (m *MegaIndController) flashLED(ledIndex int, brightness int, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	
	isOn := false
	
	for {
		select {
		case <-m.ctx.Done():
			return
		case <-ticker.C:
			m.ledMutex.RLock()
			shouldContinue := m.ledFlashing[ledIndex]
			m.ledMutex.RUnlock()
			
			if !shouldContinue {
				return
			}
			
			// Toggle LED
			if isOn {
				m.LightButton(ledIndex, 0)
			} else {
				m.LightButton(ledIndex, brightness)
			}
			isOn = !isOn
		}
	}
}

// SetFanSpeed sets the PWM fan speed (0-100)
func (m *MegaIndController) SetFanSpeed(speed int) error {
	if speed < 0 || speed > 100 {
		return fmt.Errorf("fan speed must be between 0 and 100, got: %d", speed)
	}
	
	if err := m.writeByteRegister(pwmFanOutputRegister, uint8(speed)); err != nil {
		return fmt.Errorf("failed to set fan speed: %w", err)
	}
	
	log.Printf("Fan speed set to: %d", speed)
	return nil
}

// readByteRegister reads a single byte from an I2C register
func (m *MegaIndController) readByteRegister(register int) (uint8, error) {
	read := []byte{0}
	write := []byte{uint8(register)}
	
	if err := m.i2cDevice.Tx(write, read); err != nil {
		return 0, err
	}
	
	return read[0], nil
}

// readWordRegister reads a 16-bit word from an I2C register
func (m *MegaIndController) readWordRegister(register int) (uint16, error) {
	read := make([]byte, 2)
	write := []byte{uint8(register)}
	
	if err := m.i2cDevice.Tx(write, read); err != nil {
		return 0, err
	}
	
	// Assuming little-endian format
	return uint16(read[0]) | (uint16(read[1]) << 8), nil
}

// writeByteRegister writes a single byte to an I2C register
func (m *MegaIndController) writeByteRegister(register int, value uint8) error {
	write := []byte{uint8(register), value}
	
	if err := m.i2cDevice.Tx(write, nil); err != nil {
		return err
	}
	
	return nil
}

// Dispose properly shuts down the controller
func (m *MegaIndController) Dispose() error {
	m.mu.Lock()
	defer m.mu.Unlock()
	
	if !m.isRunning {
		return nil
	}
	
	// Stop all flashing LEDs
	m.ledMutex.Lock()
	for i := range m.ledFlashing {
		m.ledFlashing[i] = false
	}
	m.ledMutex.Unlock()
	
	// Cancel context to stop goroutines
	if m.cancel != nil {
		m.cancel()
	}
	
	// Close input channel
	close(m.inputChannel)
	
	m.isRunning = false
	
	log.Println("MegaInd controller disposed")
	return nil
}

// IsRunning returns whether the controller is currently running
func (m *MegaIndController) IsRunning() bool {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.isRunning
}