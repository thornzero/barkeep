import 'package:flutter/material.dart';
import '../common/common.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

enum SettingsTabs {
  network(Icon(Icons.settings_ethernet), 'Network', NetworkSettingsWidget()),
  dateTime(Icon(Icons.alarm_sharp), 'Time & Date', DateTimeSettingsWidget()),
  jukebox(Icon(Icons.music_note), 'Jukebox', JukeboxSettingsWidget()),
  idCards(Icon(Icons.nfc), 'RFID', RFIDTagWriterWidget());

  final Icon icon;
  final String title;
  final Widget body;

  const SettingsTabs(this.icon, this.title, this.body);

  static List<PageTab> pageTabs() => values
      .map((t) => PageTab(
            Tab(
              icon: t.icon,
              text: t.title,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(cardPadding),
                child: Card(
                  shape: cardShape,
                  color: cardBackground,
                  child: t.body,
                ),
              ),
            ),
          ))
      .toList();
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
      icon: Icons.settings,
      title: 'Settings',
      pageTabs: SettingsTabs.pageTabs(),
    );
  }
}

class NetworkSettingsWidget extends StatefulWidget {
  const NetworkSettingsWidget();

  @override
  State<NetworkSettingsWidget> createState() => _NetworkSettingsWidgetState();
}

class _NetworkSettingsWidgetState extends State<NetworkSettingsWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}

class DateTimeSettingsWidget extends StatefulWidget {
  const DateTimeSettingsWidget();

  @override
  State<DateTimeSettingsWidget> createState() => _DateTimeSettingsWidgetState();
}

class _DateTimeSettingsWidgetState extends State<DateTimeSettingsWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}

class JukeboxSettingsWidget extends StatefulWidget {
  const JukeboxSettingsWidget();

  @override
  State<JukeboxSettingsWidget> createState() => _JukeboxSettingsWidgetState();
}

class _JukeboxSettingsWidgetState extends State<JukeboxSettingsWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}

class RFIDTagWriterWidget extends StatefulWidget {
  const RFIDTagWriterWidget();

  @override
  State<RFIDTagWriterWidget> createState() => _RFIDTagWriterWidgetState();
}

class _RFIDTagWriterWidgetState extends State<RFIDTagWriterWidget> {
  final SimpleWS1850S rfidReader = SimpleWS1850S();
  final TextEditingController _tagController = TextEditingController();
  bool _isWriting = false;
  String _statusMessage = "";

  @override
  void dispose() {
    rfidReader.dispose();
    _tagController.dispose();
    super.dispose();
  }

  String _generateUUID() {
    return Uuid().v4();
  }

  Future<void> _writeTag() async {
    setState(() {
      _isWriting = true;
      _statusMessage = "Writing tag...";
    });

    String tagData = _tagController.text.trim();
    if (tagData.isEmpty) {
      setState(() {
        _statusMessage = "Error: Tag data is empty.";
        _isWriting = false;
      });
      return;
    }

    try {
      var result = await rfidReader.write(tagData);

      if (result['id'] != null) {
        setState(() {
          _statusMessage = "Tag written successfully! UID: ${result['id']}";
        });
      } else {
        setState(() {
          _statusMessage = "Failed to write tag. Try again.";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isWriting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Enter Data for Tag:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          TextField(
            controller: _tagController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter custom data or generate UUID",
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  String newUUID = _generateUUID();
                  _tagController.text = newUUID;
                },
                child: Text("Generate UUID"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isWriting ? null : _writeTag,
                child: _isWriting
                    ? CircularProgressIndicator()
                    : Text("Write Tag"),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            _statusMessage,
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
