package services

import (
	"time"
)

// AudioServiceInterface defines the interface for audio management
type AudioServiceInterface interface {
	// Playback control
	LoadTrack(filePath string) error
	Play() error
	Pause() error
	Stop() error
	Next() error
	Previous() error

	// Volume control
	SetVolume(volume float64)
	SetMusicVolume(volume float64)

	// Playlist management
	AddToPlaylist(tracks []string)
	SetPlaylist(tracks []string)

	// Status
	GetStatus() AudioStatus

	// Cleanup
	Close() error
}

// AudioStatus represents the current audio status
type AudioStatus struct {
	IsPlaying    bool
	IsPaused     bool
	CurrentTrack string
	Position     time.Duration
	Duration     time.Duration
	Volume       float64
}
