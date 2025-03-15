import 'package:flutter/material.dart';
import '../common/common.dart';
import '../widgets/jukebox_card.dart';

enum EntertainmentTabs {
  jukebox(Icon(Icons.music_note, size: 40),'Jukebox', JukeboxCard()),
  theater(Icon(Icons.movie_creation, size: 40),'Theater',TheaterTab()),
  games(Icon(Icons.gamepad, size: 40),'Games',GamesTab());

  final Icon icon;
  final String title;
  final Widget body;

  const EntertainmentTabs(this.icon,this.title,this.body);

  static List<PageTab> pageTabs() => values
      .map((t) => PageTab(
            Tab(
              icon: t.icon,
              text: t.title,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(cardPadding),
                child: t.body,
              ),
            ),
          ))
      .toList();
}

class EntertainmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
      icon: Icons.movie,
      title: 'Entertainment',
      pageTabs: EntertainmentTabs.pageTabs(),
    );
  }
}

class TheaterTab extends StatefulWidget {
  const TheaterTab();

  @override
  State<TheaterTab> createState() => _TheaterTabState();
}

class _TheaterTabState extends State<TheaterTab> {
  // TODO: select movies
  @override
  Widget build(BuildContext context) {
    return Container(
      color: InkCrimson.surfaceVariantColor.withValues(alpha: 0.2),
    );
  }
}

class GamesTab extends StatefulWidget {
  const GamesTab();

  // TODO: emulation consoles
  // TODO: pc games
  // TODO: arcade games
  // TODO: board games

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab>{
  
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}