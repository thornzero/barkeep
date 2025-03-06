import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';

const String propName = 'libinput Calibration Matrix';

void main() {
  runApp(TouchscreenCalibration());
}

class TouchscreenCalibration extends StatefulWidget {
  const TouchscreenCalibration({super.key});

  @override
  State<TouchscreenCalibration> createState() => _TouchscreenCalibrationState();
}

class _TouchscreenCalibrationState extends State<TouchscreenCalibration> {
  List<Offset> calibrationPoints = [];
  int currentPointIndex = 0;
  List<Offset> screenPoints = [
    Offset(0.05, 0.05),
    Offset(0.95, 0.05),
    Offset(0.05, 0.95),
    Offset(0.95, 0.95),
  ];
  double targetRadius = 20.0;

  Future<String> xInput(List<String> args) async {
    try {
      var result = await Process.run("xinput", args);
      return result.stdout;
    } catch (e) {
      developer.log("xinput call failed: $e");
      return '';
    }
  }

  Future<Map<int, String>> getDevs() async {
    var exp = RegExp(r'.(\w.+(\w|\(\d+\)))\s+id=(\d+)\D+slave *pointer');
    var groups = exp.allMatches(await xInput(['--list', '--short']));
    var devs = groups.map((group) {
      return MapEntry(group[2] as int, group[0]);
    });
    if (devs.isEmpty) {
      developer.log('No Suitable input devices found');
    }
    return devs as Map<int, String>;
  }

  void printDevs(Map<int, String> devs) {
    developer.log('Pointer devices:');
    developer.log('ID\tName');
    devs.forEach((i, name) {
      developer.log('$i\t$name');
    });
    developer.log('');
  }

  String choosePreferred(Map<int, String> devs) {
    List<String> preferred = [''];
    devs.forEach((i, name) {
      if (name.toLowerCase().contains('touch')) {
        preferred.add(name);
      }
    });
    if (preferred.isNotEmpty) {
      return preferred.first;
    }
    return devs.values.first;
  }

  Future<String> _chooseDev(Map<int, String> devs, String preferred) async {
    var selection = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Device to calibrate'),
          children: List<Widget>.generate(devs.length, (i) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, i);
              },
              child: Text(devs[i]!),
            );
          }),
        );
      },
    );
    if (selection != null) {
      return devs[selection]!;
    }
    return preferred;
  }

  Future<void> readCal(String dev)async{

    var exp = RegExp(propName + r'.*:\s+(\S.+)');
    var line= exp.firstMatch(await xInput(['--list-props', dev]));
    if (line != null){
      developer.log('Cal property not set; is this an xinput device?');
      exit(1);
    }
    var vals = Matrix4(double.parse(line.group(1)));

  }

  Future<void> applyCalibration(List<Offset> points) async {
    String calibrationMatrix = "1,0,0,0,1,0,0,0,1";
    await xInput([
      "--set-prop",
      "YourDeviceID",
      "libinput Calibration Matrix",
      calibrationMatrix,
    ]);
  }

  void onTapDown(TapDownDetails details) {
    if (currentPointIndex < screenPoints.length) {
      Offset tapPosition = details.localPosition;
      Offset targetPosition = Offset(
        screenPoints[currentPointIndex].dx * MediaQuery.of(context).size.width,
        screenPoints[currentPointIndex].dy * MediaQuery.of(context).size.height,
      );

      double distance = (tapPosition - targetPosition).distance;
      if (distance < targetRadius) {
        setState(() {
          calibrationPoints.add(tapPosition);
          currentPointIndex++;
        });

        if (calibrationPoints.length == screenPoints.length) {
          applyCalibration(calibrationPoints);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapDown: onTapDown,
          child: Stack(
            children: List.generate(screenPoints.length, (index) {
              Offset position = Offset(
                screenPoints[index].dx * MediaQuery.of(context).size.width,
                screenPoints[index].dy * MediaQuery.of(context).size.height,
              );
              return Positioned(
                left: position.dx - targetRadius,
                top: position.dy - targetRadius,
                child: Container(
                  width: targetRadius * 2,
                  height: targetRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color:
                        index < currentPointIndex ? Colors.green : Colors.red,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
