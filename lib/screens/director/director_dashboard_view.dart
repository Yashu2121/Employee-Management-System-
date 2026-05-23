import 'package:flutter/material.dart';
import '../../widgets/brand_card.dart';

class DirectorDashboardView extends StatelessWidget {
  final Map<String, dynamic> directorSummary;

  const DirectorDashboardView({super.key, required this.directorSummary});

  @override
  Widget build(BuildContext context) {
    final int totalEmployees = directorSummary['total_employees'] ?? 0;
    final Map<String, dynamic> leaves = directorSummary['leaves'] ??
        {'pending_tl': 0, 'pending_hr': 0, 'approved': 0, 'rejected': 0};
    final Map<String, dynamic> attendance = directorSummary['attendance'] ??
        {'present_today': 0, 'total_records': 0};

    return Column(
      children: [
        // Total Employees Card
        BrandCard(
          title: 'TOTAL REGISTERED EMPLOYEES',
          icon: Icons.people_outline,
          child: Column(
            children: [
              Text(
                '$totalEmployees',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50)),
              ),
              const Text('Active Portal Users',
                  style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Leave Summary Card
        BrandCard(
          title: 'LEAVE APPLICATIONS MONITOR',
          icon: Icons.calendar_month_outlined,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDirectorMetricItem('Pending TL', leaves['pending_tl'].toString(), const Color(0xFFEE8E30)),
                  _buildDirectorMetricItem('Pending HR', leaves['pending_hr'].toString(), const Color(0xFFEE8E30)),
                  _buildDirectorMetricItem('Approved', leaves['approved'].toString(), const Color(0xFF2ECC71)),
                  _buildDirectorMetricItem('Rejected', leaves['rejected'].toString(), const Color(0xFFE74C3C)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Attendance Card
        BrandCard(
          title: 'TODAY\'S ATTENDANCE RATE (ERP)',
          icon: Icons.fact_check_outlined,
          child: Column(
            children: [
              Text(
                '${attendance['present_today']} Present',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2ECC71)),
              ),
              const SizedBox(height: 4),
              Text(
                'Total recorded punches in ERPNext: ${attendance['total_records']}',
                style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectorMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF7F8C8D), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
