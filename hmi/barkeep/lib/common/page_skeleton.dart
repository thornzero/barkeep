import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mfrc522/mfrc522.dart';
import 'themes.dart';

const inProduction = false;

class PageSkeleton extends StatefulWidget {
  const PageSkeleton({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.pageTabs,
  });

  final IconData icon;
  final String title;
  final Widget? body;
  final Map<Tab, Widget>? pageTabs;

  @override
  State<PageSkeleton> createState() => _PageSkeletonState();
}

class _PageSkeletonState extends State<PageSkeleton> {
  String _cardId = '';
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> read() async {
    final rfid = SimpleMfrc522();
    try {
      var result = await rfid.read();
      if (result.isNotEmpty) _cardId = result['id'];
    } finally {
      rfid.mfrc522.dispose();
    }
  }

  void _startScanning() {
    setState(() {
      _isDialogOpen = true;
    });

    if (inProduction) read();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Scan your ID card"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.nfc, size: 50, color: InkCrimson.tertiaryColor),
                SizedBox(height: 10),
                Text("Please tap your ID Card on the reader below."),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  setState(() {
                    _isDialogOpen = false;
                  });
                },
                child: Text("Cancel"),
              ),
            ],
          );
        });

    // Close the popup when a valid UID is detected
    if (_isDialogOpen && _cardId.isNotEmpty) {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        _isDialogOpen = false;
      });

      // Show confirmation (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID: $_cardId scanned")),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDialogOpen) {}
    if (widget.pageTabs == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor:
              InkCrimson.surfaceVariantColor.withValues(alpha: 0.6),
          leading: Icon(
            widget.icon,
            size: 32.0,
          ),
          title: Text(widget.title, style: TextStyle(fontSize: 32.0)),
          actions: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(end: 16.0),
              child: IconButton(
                onPressed: _startScanning,
                icon: CircleAvatar(child: Icon(Icons.account_circle)),
                iconSize: 32.0,
              ),
            ),
          ],
          shape: InkCrimson.border,
        ),
        body: widget.body,
      );
    } else {
      return DefaultTabController(
        initialIndex: 1,
        length: widget.pageTabs!.length,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor:
                InkCrimson.surfaceVariantColor.withValues(alpha: 0.6),
            leading: Icon(
              widget.icon,
              size: 32.0,
            ),
            title: Text(widget.title, style: TextStyle(fontSize: 32.0)),
            bottom: TabBar(
              tabs: widget.pageTabs!.keys.toList(),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsetsDirectional.only(end: 16.0),
                child: IconButton(
                  onPressed: _startScanning,
                  icon: CircleAvatar(child: Icon(Icons.account_circle)),
                  iconSize: 32.0,
                ),
              ),
            ],
            shape: InkCrimson.border,
          ),
          body: TabBarView(
            children: widget.pageTabs!.values.toList(),
          ),
        ),
      );
    }
  }
}
