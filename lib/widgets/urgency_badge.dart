import 'package:flutter/material.dart';

class UrgencyBadge extends StatelessWidget {
  final String level;
  final bool small;

  const UrgencyBadge({super.key, required this.level, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (level.toLowerCase()) {
      'critical' => (const Color(0xFFD32F2F), const Color(0xFFFFEBEE)),
      'medium'   => (const Color(0xFFF57C00), const Color(0xFFFFF3E0)),
      _          => (const Color(0xFF388E3C), const Color(0xFFE8F5E9)),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
