import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';
import 'package:flutter/material.dart';
import 'package:audio_visualizer/audio_visualizer.dart';
import 'package:audio_visualizer/utils.dart';
import 'package:audio_visualizer/visualizers/audio_spectrum.dart';
import 'package:audio_visualizer/visualizers/visualizers.dart';
import 'package:metadata_god/metadata_god.dart';
import 'database.dart';
import '../common/common.dart';

class JukeboxTab extends StatefulWidget {
  const JukeboxTab({super.key});

  @override
  State<JukeboxTab> createState() => JukeboxTabState();
}

class JukeboxTabState extends State<JukeboxTab> {
  final audioPlayer = VisualizerPlayer();
  final _playlist = [
    "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
    "https://files.testfile.org/AUDIO/C/M4A/sample1.m4a",
  ];
  final db = JukeboxDB();
  final musicDirectoryWatcher =
      DirectoryWatcher(p.absolute(musicHomeDirectory));

  int playlistIndex = 0;
  int get playlistLength => _playlist.length;

  String? get currentSong =>
      _playlist.isNotEmpty ? _playlist[playlistIndex] : null;

  String? get nextSong =>
      _playlist.length > 1 ? _playlist[playlistIndex + 1] : null;

  void setPlaylistIndex(int index) {
    playlistIndex = index;
  }

  void shufflePlaylist() {
    _playlist.shuffle();
  }

  void addToPlaylist(String path) {
    _playlist.add(path);
  }

  void removeFromPlaylist(int index) {
    _playlist.removeAt(index);
  }

  void clearSongQueue() {
    _playlist.clear();
  }

  @override
  void initState() {
    super.initState();
    audioPlayer.initialize();
    audioPlayer.setDataSource(currentSong!);
    audioPlayer.addListener(onUpdate);
    _initalizePlaylist();
    musicDirectoryWatcher.events.listen(musicDirectoryEventListener);
    //_player.open(_playlist);
  }

  void musicDirectoryEventListener(WatchEvent event) async {
    if (event.path.isNotEmpty) {
      switch (event.type) {
        case ChangeType.ADD:
          db.createMetadata([event.path]);

        case ChangeType.MODIFY:
          db.updateMetadata(event.path);

        case ChangeType.REMOVE:
          db.deleteMetadata(event.path);

        default:
          print('Music directory updated at ${event.path}');
      }
    }
  }

  void onUpdate() {
    if (audioPlayer.value.status == PlayerStatus.ready) {
      audioPlayer.play(looping: true);
    }
  }

  void _initalizePlaylist() {
    db.createMetadata(_playlist);
  }

  Widget playlistQueue() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Queue'),
        Spacer(),
        _playlist.isNotEmpty
            ? ListView.builder(
                itemCount: _playlist.length,
                itemBuilder: (BuildContext context, int index) {
                  var data = db.readMetadata(_playlist[index]);
                  return ListTile(
                    leading: data.picture != null
                        ? Image.memory(data.picture!.data)
                        : Icon(Icons.music_note),
                    title: Text(data.title!),
                    subtitle: Text(data.artist!),
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => removeFromPlaylist(index),
                    ),
                    onTap: () => setPlaylistIndex(index),
                  );
                },
              )
            : const Center(child: Text('Queue is empty')),
      ],
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget playerBox() {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Audio Visualizer'),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListenableBuilder(
              listenable: audioPlayer,
              builder: (context, child) {
                final duration = audioPlayer.value.duration;
                final position = audioPlayer.value.position;
                final durationText = formatDuration(duration);
                final positionText = formatDuration(position);
                return Text(
                  "$positionText / $durationText",
                  style: Theme.of(context).textTheme.headlineLarge,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListenableBuilder(
              listenable: audioPlayer,
              builder: (context, child) {
                return Text(
                  audioPlayer.value.status == PlayerStatus.playing
                      ? "Now Playing"
                      : "",
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: audioPlayer,
              builder: (context, child) {
                final data = getMagnitudes(audioPlayer.value.fft);
                return AudioSpectrum(
                  fftMagnitudes: data,
                  bandType: BandType.tenBand,
                  builder: (context, value, child) {
                    return RainbowBlockVisualizer(
                      data: value.levels,
                      maxSample: 32,
                      blockHeight: 14,
                    );
                  },
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: audioPlayer,
            builder: (context, child) {
              final duration = audioPlayer.value.duration.inMilliseconds;
              final position = audioPlayer.value.position.inMilliseconds;
              return LinearProgressIndicator(
                value: position / max(1, duration),
                minHeight: 8,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                audioPlayer.play(looping: true);
              },
            ),
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () {
                audioPlayer.pause();
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                audioPlayer.stop();
              },
            ),
            IconButton(
              icon: const Icon(Icons.loop),
              onPressed: () {
                playlistIndex = (playlistIndex + 1) % _playlist.length;
                audioPlayer.stop();
                audioPlayer.setDataSource(_playlist[playlistIndex]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget nowPlaying(Metadata data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Now Playing'),
        Spacer(),
        ListTile(
          leading: Icon(Icons.music_note),
          title: Text(data.title!),
          subtitle: Text(data.artist!),
        ),
      ],
    );
  }

  @override
  void dispose() {
    audioPlayer.removeListener(onUpdate);
    audioPlayer.dispose();
    //_player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: InkCrimson.surfaceVariantColor.withValues(alpha: 0.6),
            child: Row(
              children: [
                playlistQueue(),
                Expanded(
                  child: Scaffold(
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        nowPlaying(db.readMetadata(currentSong!)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
