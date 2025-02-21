import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        bottom: TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.gavel),
              text: 'License',
            ),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          AboutLicensePage(),
        ],
      ),
    );
  }
}

class AboutLicensePage extends StatelessWidget {
  // todo: load license text from assets/licenses/

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
