import 'package:flutter/material.dart';

import '../common/common.dart';
import '../models/jukebox.dart';

class EntertainmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
      icon: Icons.movie,
      title: 'Entertainment',
      pageTabs: {
        Tab(icon: Icon(Icons.music_note, size: 40), text: 'Jukebox'):
            JukeboxTab(),
        Tab(icon: Icon(Icons.movie_creation, size: 40), text: 'Theater'):
            TheaterTab(),
        Tab(icon: Icon(Icons.gamepad, size: 40), text: 'Games'): GamesTab(),
      },
    );
  }
}

class TheaterTab extends StatelessWidget {
  // todo: select movies
  // todo: select shows
  // todo: select music videos
  @override
  Widget build(BuildContext context) {
    return Container(
      color: InkCrimson.surfaceVariantColor.withValues(alpha: 0.2),
    );
  }
}

class GamesTab extends StatelessWidget {
  // todo: emulation consoles
  // todo: pc games
  // todo: arcade games
  // todo: board games
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
