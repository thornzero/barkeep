import 'package:flutter/material.dart';
import '../common/common.dart';

class FoodAndDrinkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
      icon: Icons.fastfood,
      title: 'Food & Drink',
      body: Placeholder(),
    );
  }
}
