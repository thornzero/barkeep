import 'package:barkeep/common/common.dart';
import 'package:flutter/material.dart';

class AtmospherePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
      icon: Icons.forest,
      title: 'Atmosphere',
      body: Placeholder(),
    );
  }
}
