import 'package:flutter/material.dart';

class HRDashboardView extends StatelessWidget {
  final List<dynamic> pendingLeaves;
  final Function(int, String) onAction;

  const HRDashboardView({
    super.key,
    required this.pendingLeaves,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PENDING FINAL APPROVALS (HR)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        pendingLeaves.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFECEFF1)),
                ),
                child: const Center(
                  child: Text('No leaves waiting for HR final approval.', style: TextStyle(color: Color(0xFF7F8C8D))),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingLeaves.length,
                itemBuilder: (context, index) {
                  final leave = pendingLeaves[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFECEFF1)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C3E50).withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              leave['employee_name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E50)),
                            ),
                            Text(
                              'ID: ${leave['employee_id']}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFECEFF1), height: 16),
                        Text(
                          'Reason: ${leave['reason']}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF34495E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Duration: ${leave['start_date']} to ${leave['end_date']}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => onAction(leave['id'], 'approve'),
                                icon: const Icon(Icons.done_all, size: 14, color: Colors.white),
                                label: const Text('APPROVE & DEDUCT'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2ECC71),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => onAction(leave['id'], 'reject'),
                                icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                label: const Text('REJECT'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE74C3C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}
