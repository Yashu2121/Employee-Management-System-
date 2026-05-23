import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = const Color(0xFFEE8E30);
        text = 'PENDING';
        break;
      case 'tl_approved':
        color = const Color(0xFFEE8E30);
        text = 'TL APPR';
        break;
      case 'tl_rejected':
        color = const Color(0xFFE74C3C);
        text = 'TL REJ';
        break;
      case 'hr_approved':
        color = const Color(0xFF2ECC71);
        text = 'APPROVED';
        break;
      case 'hr_rejected':
        color = const Color(0xFFE74C3C);
        text = 'REJECTED';
        break;
      case 'Present':
        color = const Color(0xFF2ECC71);
        text = 'PRESENT';
        break;
      default:
        color = const Color(0xFF7F8C8D);
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
