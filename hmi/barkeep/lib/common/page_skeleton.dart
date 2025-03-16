import 'dart:async';
import 'package:barkeep/services/audio_manager.dart';

import 'common.dart';
import 'package:flutter/material.dart';

const inProduction = true;

class PageTab {
  final Tab tab;
  final Widget child;

  const PageTab(this.tab, this.child);
}

class PageSkeleton extends StatefulWidget {
  const PageSkeleton({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.pageTabs = const [],
  });

  final IconData icon;
  final String title;
  final Widget? body;
  final List<PageTab> pageTabs;

  @override
  State<PageSkeleton> createState() => _PageSkeletonState();
}
 
class _PageSkeletonState extends State<PageSkeleton> with SingleTickerProviderStateMixin {
  String _cardId = '';
  bool _isDialogOpen = false;
  late TabController _tabController;
  final AudioManager audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length:widget.pageTabs.length,vsync: this );
    _tabController.addListener((){
      if (_tabController.indexIsChanging){
        audioManager.play(sfxTabSelectChange);
      }
    });
  }

  Future<void> read() async {
    var rfid = SimpleWS1850S();
    try {
      var result = await rfid.read();
      if (result.isNotEmpty) _cardId = result['id'].toString();
    } catch (e) {
      print('Error reading RFID: ${e.toString()}');
    } finally {
      rfid.dispose();
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDialogOpen) {}
    if (widget.pageTabs.isEmpty) {
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
            bottom: TabBar(
              controller: _tabController,
              tabs: widget.pageTabs.map((p) => p.tab).toList(),
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
            controller: _tabController,
            children: widget.pageTabs.map((p) => p.child).toList(),
          ),
        );
    }
  }
}
