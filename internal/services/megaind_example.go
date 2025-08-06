package services

import (
	"log"
	"time"
)

// ExampleMegaIndUsage demonstrates how to use the MegaInd controller
func ExampleMegaIndUsage() {
	// Get the singleton controller instance
	controller := GetMegaIndController()
	
	// Initialize with I2C bus 1 (typical for Raspberry Pi)
	if err := controller.Init(1); err != nil {
		log.Fatalf("Failed to initialize MegaInd controller: %v", err)
	}
	defer controller.Dispose()
	
	// Start listening for button events
	go func() {
		inputChannel := controller.GetInputChannel()
		for buttonMap := range inputChannel {
			// Check individual buttons
			if buttonMap.Get(ButtonA) {
				log.Println("Button A pressed!")
				// Light up LED 0 when A is pressed
				controller.LightButton(0, 50)
			} else {
				controller.LightButton(0, 0) // Turn off LED 0
			}
			
			if buttonMap.Get(ButtonB) {
				log.Println("Button B pressed!")
				// Start flashing LED 1 when B is pressed
				controller.StartFlashing(1, 75, 500*time.Millisecond)
			}
			
			if buttonMap.Get(ButtonX) {
				log.Println("Button X pressed!")
				// Stop flashing all LEDs when X is pressed
				controller.StopFlashing(1)
			}
			
			if buttonMap.Get(ButtonY) {
				log.Println("Button Y pressed!")
				// Set fan speed to 50% when Y is pressed
				controller.SetFanSpeed(50)
			}
			
			if buttonMap.Get(ButtonUp) {
				log.Println("Up button pressed!")
				// Increase fan speed
				controller.SetFanSpeed(100)
			}
			
			if buttonMap.Get(ButtonDown) {
				log.Println("Down button pressed!")
				// Decrease fan speed
				controller.SetFanSpeed(25)
			}
		}
	}()
	
	// Keep the example running for demonstration
	log.Println("MegaInd controller running... Press Ctrl+C to exit")
	
	// Example of programmatic LED control
	time.Sleep(1 * time.Second)
	controller.LightButton(0, 100) // Full brightness
	time.Sleep(1 * time.Second)
	controller.StartFlashing(0, 50, 200*time.Millisecond) // Fast flash
	time.Sleep(3 * time.Second)
	controller.StopFlashing(0)
	
	// Example of fan control
	log.Println("Testing fan control...")
	for speed := 0; speed <= 100; speed += 25 {
		log.Printf("Setting fan speed to %d%%", speed)
		controller.SetFanSpeed(speed)
		time.Sleep(2 * time.Second)
	}
	
	log.Println("Example completed")
}