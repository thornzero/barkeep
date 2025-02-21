import 'package:flutter/material.dart';
import 'package:json_schema/json_schema.dart';

class RecipeCard extends StatelessWidget {
  RecipeCard({super.key, required this.recipe});

  final Map<String, dynamic> recipe;

  Future<bool> validate(Map<String, dynamic> recipe) async {
    var recipeSchemaPath = "assets/schema/recipe.sch";
    var schema = await JsonSchema.createFromUrl(recipeSchemaPath);
    var result = schema.validate(recipe);
    bool isValid = result.isValid;
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe['recipe_name'] ?? 'Unknown Recipe',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.0),
            if (recipe['notes'] != null)
              Text(
                "Notes: ${recipe['notes'].join(", ")}",
                style: TextStyle(color: Colors.grey[700]),
              ),
            SizedBox(height: 8.0),
            Text(
              'Ingredients:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._buildIngredientList(recipe['ingredients'] ?? []),
            SizedBox(height: 8.0),
            Text(
              'Steps:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._buildStepList(recipe['steps'] ?? []),
            if (recipe['oven_temp'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Oven Temp: ${_formatOvenTemp(recipe['oven_temp'])}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredientList(List<dynamic> ingredients) {
    return ingredients.map((ingredient) {
      final ingredientName = ingredient.keys.first;
      final details = ingredient[ingredientName];
      final amountList = details['amounts'] as List<dynamic>;
      final amounts =
          amountList.map((a) => "${a['amount']} ${a['unit']}").join(", ");
      final processing = (details['processing'] ?? []).join(", ");
      return Text(
        "- $ingredientName: $amounts${processing.isNotEmpty ? " ($processing)" : ""}",
      );
    }).toList();
  }

  List<Widget> _buildStepList(List<dynamic> steps) {
    return steps.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final step = entry.value;
      final description = step['step'];
      final notes = (step['notes'] ?? []).join(", ");
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          "$index. $description${notes.isNotEmpty ? " (Notes: $notes)" : ""}",
        ),
      );
    }).toList();
  }

  String _formatOvenTemp(dynamic ovenTemp) {
    if (ovenTemp is List) {
      return ovenTemp
          .map((temp) => "${temp['amount']}°${temp['unit']}")
          .join(", ");
    }
    return "N/A";
  }
}

class RecipeValidator {}
