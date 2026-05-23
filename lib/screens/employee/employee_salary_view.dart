import 'package:flutter/material.dart';
import '../../widgets/brand_card.dart';

class EmployeeSalaryView extends StatelessWidget {
  final List<dynamic> salarySlips;

  const EmployeeSalaryView({super.key, required this.salarySlips});

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      title: 'ERPNext LIVE SALARY SLIP',
      icon: Icons.receipt_long_outlined,
      child: salarySlips.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text('No salary slip found in ERPNext database.', style: TextStyle(color: Color(0xFF7F8C8D))),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSalaryRow('Gross Compensation', '₹${salarySlips[0]['gross_pay']}'),
                const Divider(height: 24, color: Color(0xFFECEFF1)),
                _buildSalaryRow('Total Deductions', '₹${salarySlips[0]['total_deduction']}', isNegative: true),
                const Divider(height: 24, color: Color(0xFFECEFF1)),
                _buildSalaryRow('Net Disbursed Pay', '₹${salarySlips[0]['net_pay']}', isNet: true),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFECEFF1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Posting Ref', style: TextStyle(fontSize: 11, color: Color(0xFF7F8C8D), fontWeight: FontWeight.bold)),
                      Text('${salarySlips[0]['name']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSalaryRow(String label, String value, {bool isNegative = false, bool isNet = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isNet ? 14 : 13,
            fontWeight: isNet ? FontWeight.bold : FontWeight.normal,
            color: isNet ? const Color(0xFF2C3E50) : const Color(0xFF34495E),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isNet ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isNegative
                ? const Color(0xFFE74C3C)
                : isNet
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }
}
