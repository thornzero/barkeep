package services

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/faiface/beep"
	"github.com/faiface/beep/effects"
	"github.com/faiface/beep/mp3"
	"github.com/faiface/beep/speaker"
	"github.com/faiface/beep/wav"
)

// AudioManager manages audio playback and sound effects
type AudioManager struct {
	// Playback state
	speaker       *beep.Mixer
	musicStreamer beep.StreamSeekCloser
	musicControl  *beep.Ctrl
	musicVolume   *effects.Volume
	sfxVolume     *effects.Volume

	// Current state
	currentTrack string
	isPlaying    bool
	isPaused     bool
	position     time.Duration
	duration     time.Duration

	// Volume levels
	masterVolume     float64
	musicVolumeLevel float64
	sfxVolumeLevel   float64

	// Queue management
	playlist     []string
	currentIndex int
	shuffleMode  bool
	repeatMode   RepeatMode

	// Channels for communication
	nowPlayingChan chan string
	statusChan     chan AudioStatus

	// Synchronization
	mutex sync.RWMutex

	// Configuration
	musicDirectory string
	sfxDirectory   string
}

// RepeatMode defines the repeat behavior
type RepeatMode int

const (
	RepeatOff RepeatMode = iota
	RepeatOne
	RepeatAll
)

// NewAudioManager creates a new audio manager instance
func NewAudioManager() *AudioManager {
	am := &AudioManager{
		masterVolume:     1.0,
		musicVolumeLevel: 1.0,
		sfxVolumeLevel:   1.0,
		playlist:         make([]string, 0),
		currentIndex:     0,
		repeatMode:       RepeatOff,
		nowPlayingChan:   make(chan string, 10),
		statusChan:       make(chan AudioStatus, 10),
		musicDirectory:   "~/music",
		sfxDirectory:     "assets/sounds",
	}

	// Initialize speaker with reasonable sample rate
	sr := beep.SampleRate(44100)
	err := speaker.Init(sr, sr.N(time.Second/10))
	if err != nil {
		log.Printf("Failed to initialize speaker: %v", err)
		return am
	}

	// Create mixer
	am.speaker = &beep.Mixer{}
	speaker.Play(am.speaker)

	return am
}

// LoadTrack loads a music track for playback
func (am *AudioManager) LoadTrack(filePath string) error {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	// Stop current track if playing
	if am.musicControl != nil {
		am.musicControl.Paused = true
	}

	// Close previous streamer
	if am.musicStreamer != nil {
		am.musicStreamer.Close()
	}

	// Open the audio file
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open audio file: %w", err)
	}

	// Determine file type and decode
	ext := strings.ToLower(filepath.Ext(filePath))
	var streamer beep.StreamSeekCloser
	var format beep.Format

	switch ext {
	case ".mp3":
		streamer, format, err = mp3.Decode(file)
	case ".wav":
		streamer, format, err = wav.Decode(file)
	default:
		file.Close()
		return fmt.Errorf("unsupported audio format: %s", ext)
	}

	if err != nil {
		file.Close()
		return fmt.Errorf("failed to decode audio: %w", err)
	}

	// Create volume control
	am.musicVolume = &effects.Volume{
		Streamer: streamer,
		Base:     2,
		Volume:   am.volumeToDecibels(am.musicVolumeLevel),
		Silent:   false,
	}

	// Create playback control
	am.musicControl = &beep.Ctrl{
		Streamer: am.musicVolume,
		Paused:   true,
	}

	// Store references
	am.musicStreamer = streamer
	am.currentTrack = filePath
	am.isPlaying = false
	am.isPaused = true

	// Calculate duration (approximate)
	am.duration = format.SampleRate.D(streamer.Len())

	// Add to mixer
	am.speaker.Add(am.musicControl)

	// Notify about track change
	am.nowPlayingChan <- fmt.Sprintf("Loaded: %s", filepath.Base(filePath))

	return nil
}

// Play starts or resumes playback
func (am *AudioManager) Play() error {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if am.musicControl == nil {
		return fmt.Errorf("no track loaded")
	}

	am.musicControl.Paused = false
	am.isPlaying = true
	am.isPaused = false

	am.nowPlayingChan <- fmt.Sprintf("Playing: %s", filepath.Base(am.currentTrack))

	return nil
}

// Pause pauses playback
func (am *AudioManager) Pause() error {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if am.musicControl == nil {
		return fmt.Errorf("no track loaded")
	}

	am.musicControl.Paused = true
	am.isPlaying = false
	am.isPaused = true

	am.nowPlayingChan <- "Paused"

	return nil
}

// Stop stops playback and resets position
func (am *AudioManager) Stop() error {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if am.musicControl != nil {
		am.musicControl.Paused = true
	}

	if am.musicStreamer != nil {
		am.musicStreamer.Seek(0)
	}

	am.isPlaying = false
	am.isPaused = false
	am.position = 0

	am.nowPlayingChan <- "Stopped"

	return nil
}

// SetVolume sets the master volume (0.0 to 1.0)
func (am *AudioManager) SetVolume(volume float64) {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if volume < 0 {
		volume = 0
	}
	if volume > 1 {
		volume = 1
	}

	am.masterVolume = volume
	am.updateVolumes()
}

// SetMusicVolume sets the music volume (0.0 to 1.0)
func (am *AudioManager) SetMusicVolume(volume float64) {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if volume < 0 {
		volume = 0
	}
	if volume > 1 {
		volume = 1
	}

	am.musicVolumeLevel = volume
	am.updateVolumes()
}

// SetSFXVolume sets the sound effects volume (0.0 to 1.0)
func (am *AudioManager) SetSFXVolume(volume float64) {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if volume < 0 {
		volume = 0
	}
	if volume > 1 {
		volume = 1
	}

	am.sfxVolumeLevel = volume
}

// PlaySFX plays a sound effect
func (am *AudioManager) PlaySFX(filename string) error {
	// Build full path
	fullPath := filepath.Join(am.sfxDirectory, filename)

	// Open the file
	file, err := os.Open(fullPath)
	if err != nil {
		return fmt.Errorf("failed to open SFX file: %w", err)
	}
	defer file.Close()

	// Decode based on file extension
	ext := strings.ToLower(filepath.Ext(filename))
	var streamer beep.StreamCloser

	switch ext {
	case ".wav":
		streamer, _, err = wav.Decode(file)
	case ".mp3":
		streamer, _, err = mp3.Decode(file)
	default:
		return fmt.Errorf("unsupported SFX format: %s", ext)
	}

	if err != nil {
		return fmt.Errorf("failed to decode SFX: %w", err)
	}

	// Apply volume
	volume := &effects.Volume{
		Streamer: streamer,
		Base:     2,
		Volume:   am.volumeToDecibels(am.sfxVolumeLevel * am.masterVolume),
		Silent:   false,
	}

	// Play the sound effect
	done := make(chan bool)
	speaker.Play(beep.Seq(volume, beep.Callback(func() {
		done <- true
	})))

	// Don't wait for completion, let it play asynchronously
	go func() {
		<-done
		streamer.Close()
	}()

	return nil
}

// GetStatus returns the current audio status
func (am *AudioManager) GetStatus() AudioStatus {
	am.mutex.RLock()
	defer am.mutex.RUnlock()

	return AudioStatus{
		IsPlaying:    am.isPlaying,
		IsPaused:     am.isPaused,
		CurrentTrack: am.currentTrack,
		Position:     am.position,
		Duration:     am.duration,
		Volume:       am.masterVolume,
	}
}

// GetNowPlayingChannel returns the channel for now playing updates
func (am *AudioManager) GetNowPlayingChannel() <-chan string {
	return am.nowPlayingChan
}

// GetStatusChannel returns the channel for status updates
func (am *AudioManager) GetStatusChannel() <-chan AudioStatus {
	return am.statusChan
}

// AddToPlaylist adds tracks to the playlist
func (am *AudioManager) AddToPlaylist(tracks []string) {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	am.playlist = append(am.playlist, tracks...)
}

// SetPlaylist replaces the current playlist
func (am *AudioManager) SetPlaylist(tracks []string) {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	am.playlist = make([]string, len(tracks))
	copy(am.playlist, tracks)
	am.currentIndex = 0
}

// Next moves to the next track in the playlist
func (am *AudioManager) Next() error {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if len(am.playlist) == 0 {
		return fmt.Errorf("playlist is empty")
	}

	switch am.repeatMode {
	case RepeatOne:
		// Stay on the same track
	case RepeatAll:
		am.currentIndex = (am.currentIndex + 1) % len(am.playlist)
	default:
		if am.currentIndex < len(am.playlist)-1 {
			am.currentIndex++
		} else {
			return fmt.Errorf("end of playlist reached")
		}
	}

	if am.currentIndex < len(am.playlist) {
		return am.LoadTrack(am.playlist[am.currentIndex])
	}

	return nil
}

// Previous moves to the previous track in the playlist
func (am *AudioManager) Previous() error {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if len(am.playlist) == 0 {
		return fmt.Errorf("playlist is empty")
	}

	if am.currentIndex > 0 {
		am.currentIndex--
	} else if am.repeatMode == RepeatAll {
		am.currentIndex = len(am.playlist) - 1
	} else {
		return fmt.Errorf("beginning of playlist reached")
	}

	return am.LoadTrack(am.playlist[am.currentIndex])
}

// SetRepeatMode sets the repeat mode
func (am *AudioManager) SetRepeatMode(mode RepeatMode) {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	am.repeatMode = mode
}

// GetPlaylist returns the current playlist
func (am *AudioManager) GetPlaylist() []string {
	am.mutex.RLock()
	defer am.mutex.RUnlock()

	playlist := make([]string, len(am.playlist))
	copy(playlist, am.playlist)
	return playlist
}

// SetMusicDirectory sets the directory to scan for music
func (am *AudioManager) SetMusicDirectory(dir string) {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	am.musicDirectory = dir
}

// Close cleans up the audio manager
func (am *AudioManager) Close() error {
	am.mutex.Lock()
	defer am.mutex.Unlock()

	if am.musicControl != nil {
		am.musicControl.Paused = true
	}

	if am.musicStreamer != nil {
		am.musicStreamer.Close()
	}

	close(am.nowPlayingChan)
	close(am.statusChan)

	return nil
}

// Helper methods

// updateVolumes updates the volume controls
func (am *AudioManager) updateVolumes() {
	if am.musicVolume != nil {
		am.musicVolume.Volume = am.volumeToDecibels(am.musicVolumeLevel * am.masterVolume)
	}
}

// volumeToDecibels converts a 0.0-1.0 volume to decibels
func (am *AudioManager) volumeToDecibels(volume float64) float64 {
	if volume <= 0 {
		return -10 // Very quiet but not silent
	}
	if volume >= 1 {
		return 0
	}
	// Convert linear volume to logarithmic (decibels)
	// -20dB to 0dB range
	return -20 + (20 * volume)
}

// Global audio manager instance
var GlobalAudioManager *AudioManager

// InitAudio initializes the global audio manager
func InitAudio() error {
	GlobalAudioManager = NewAudioManager()
	return nil
}
