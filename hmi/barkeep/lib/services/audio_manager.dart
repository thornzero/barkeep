import 'dart:async';
import 'dart:developer' as dev;
import 'package:just_audio/just_audio.dart';

const double normalVolumeLevel = 1.0;
const double normalSfxLevel = 1.0;

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();
  final StreamController<String> _nowPlayingController =
      StreamController.broadcast();

  Stream<String> get nowPlayingStream => _nowPlayingController.stream;

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _player.playerStateStream.listen((state) {
      if (state.playing) {
        _nowPlayingController.add(
            "Playing: ${_player.sequenceState?.currentSource?.tag ?? "Unknown"}");
      } else {
        _nowPlayingController.add("Paused/Stopped");
      }
    });
  }

  Future<void> play(String filePath) async {
    try {
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      dev.log("Error playing file: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> sfx(String filePath) async {
    try {
      await _sfx.setFilePath(filePath);
      await _sfx.play();
    } catch (e) {
      dev.log("Error playing file: $e");
    }
  }

  Future<void> setSfxVolume(double volume) async {
    await _sfx.setVolume(volume);
  }
}
