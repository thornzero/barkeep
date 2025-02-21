import 'package:barkeep/common/common.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Color cardBackground =
      InkCrimson.surfaceVariantColor.withValues(alpha: 0.6);
  final ShapeBorder cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(40.0)));

  Widget _settingsNetwork() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Card(
          shape: cardShape,
          color: cardBackground,
          child: Placeholder(),
        ),
      ),
    );
  }

  Widget _settingsDateTime() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Card(
          shape: cardShape,
          color: cardBackground,
          child: Placeholder(),
        ),
      ),
    );
  }

  Widget _settingsJukebox() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Card(
          shape: cardShape,
          color: cardBackground,
          child: Placeholder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageSkeleton(icon: Icons.settings, title: 'Settings', pageTabs: {
      Tab(
        icon: Icon(Icons.settings_ethernet),
        text: "Network",
      ): _settingsNetwork(),
      Tab(
        icon: Icon(Icons.alarm_sharp),
        text: 'Time & Date',
      ): _settingsDateTime(),
      Tab(
        icon: Icon(Icons.music_note),
        text: 'Jukebox',
      ): _settingsJukebox(),
    });
  }
}
