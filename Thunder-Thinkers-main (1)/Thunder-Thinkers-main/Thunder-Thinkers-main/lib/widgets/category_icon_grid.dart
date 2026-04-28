import 'package:flutter/material.dart';
import 'category_icon.dart';

class CategoryIconGrid extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const CategoryIconGrid({super.key, required this.onSelect, this.selected});

  static const _categories = [
    'Food', 'Medical', 'Shelter', 'Education', 'Sanitation', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: _categories.map((cat) {
        final isSelected = selected == cat;
        final color = categoryColor(cat);
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : theme.colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(categoryIcon(cat), color: color, size: 28),
                const SizedBox(height: 6),
                Text(
                  cat,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? color : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
