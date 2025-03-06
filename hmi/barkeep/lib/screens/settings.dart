import 'dart:io';
import 'package:flutter/material.dart';
import '../common/common.dart';

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

class TouchscreenCalibration extends StatefulWidget {
  @override
  State<TouchscreenCalibration> createState() => TouchscreenCalibrationState();
}

class TouchscreenCalibrationState extends State<TouchscreenCalibration> {
  List<Offset> calibrationPoints = [];
  int currentPointIndex = 0;
  List<Offset> screenPoints = [
    Offset(0.1, 0.1),
    Offset(0.9, 0.1),
    Offset(0.1, 0.9),
    Offset(0.9, 0.9)
  ];

  Future<void> applyCalibration(List<Offset> points) async {
    // Compute transformation matrix (placeholder, needs proper calculation)
    String calibrationMatrix = "1,0,0,0,1,0,0,0,1";

    try {
      await Process.run("xinput", [
        "--set-prop",
        "YourDeviceID",
        "libinput Calibration Matrix",
        calibrationMatrix
      ]);
    } catch (e) {
      print("Failed to apply calibration: $e");
    }
  }

  void onTapDown(TapDownDetails details) {
    if (currentPointIndex < screenPoints.length) {
      setState(() {
        calibrationPoints.add(details.localPosition);
        currentPointIndex++;
      });

      if (calibrationPoints.length == screenPoints.length) {
        applyCalibration(calibrationPoints);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Touchscreen Calibration")),
      body: GestureDetector(
        onTapDown: onTapDown,
        child: Stack(
          children: List.generate(screenPoints.length, (index) {
            return Positioned(
              left: screenPoints[index].dx * MediaQuery.of(context).size.width,
              top: screenPoints[index].dy * MediaQuery.of(context).size.height,
              child: Icon(
                index < currentPointIndex ? Icons.check_circle : Icons.circle,
                size: 30,
                color: index < currentPointIndex ? Colors.green : Colors.red,
              ),
            );
          }),
        ),
      ),
    );
  }
}
