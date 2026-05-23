import 'package:flutter/material.dart';
import '../../widgets/brand_card.dart';

class EmployeeApplyView extends StatelessWidget {
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController reasonController;
  final VoidCallback onApply;

  const EmployeeApplyView({
    super.key,
    required this.startDateController,
    required this.endDateController,
    required this.reasonController,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      title: 'APPLY FOR LEAVE',
      icon: Icons.edit_calendar_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: startDateController,
            decoration: const InputDecoration(
              labelText: 'Start Date (YYYY-MM-DD)',
              hintText: 'e.g. 2026-05-25',
              prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF7F8C8D)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: endDateController,
            decoration: const InputDecoration(
              labelText: 'End Date (YYYY-MM-DD)',
              hintText: 'e.g. 2026-05-26',
              prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF7F8C8D)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Describe the reason for leave...',
              prefixIcon: Icon(Icons.notes, color: Color(0xFF7F8C8D)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE8E30),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('SUBMIT LEAVE REQUEST', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
