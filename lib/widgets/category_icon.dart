import 'package:flutter/material.dart';

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food': return Icons.restaurant;
    case 'medical': return Icons.local_hospital;
    case 'shelter': return Icons.home;
    case 'education': return Icons.school;
    case 'sanitation': return Icons.water_drop;
    default: return Icons.help_outline;
  }
}

Color categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food': return const Color(0xFFE65100);
    case 'medical': return const Color(0xFFB71C1C);
    case 'shelter': return const Color(0xFF1565C0);
    case 'education': return const Color(0xFF4A148C);
    case 'sanitation': return const Color(0xFF006064);
    default: return const Color(0xFF37474F);
  }
}

class CategoryIconWidget extends StatelessWidget {
  final String category;
  final double size;
  final bool showLabel;

  const CategoryIconWidget({
    super.key,
    required this.category,
    this.size = 32,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size + 16,
          height: size + 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(categoryIcon(category), color: color, size: size),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(category, style: Theme.of(context).textTheme.labelSmall),
        ],
      ],
    );
  }
}
