import 'package:flutter/material.dart';
import '../../widgets/brand_card.dart';
import '../../widgets/status_chip.dart';

class EmployeeHistoryView extends StatelessWidget {
  final List<dynamic> myLeaves;
  final List<dynamic> attendanceList;

  const EmployeeHistoryView({
    super.key,
    required this.myLeaves,
    required this.attendanceList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Leaves History Card
        BrandCard(
          title: 'LEAVE APPLICATIONS HISTORY',
          icon: Icons.history,
          child: myLeaves.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('No leave applications recorded.', style: TextStyle(color: Color(0xFF7F8C8D))),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myLeaves.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFECEFF1)),
                  itemBuilder: (context, index) {
                    final leave = myLeaves[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leave['reason'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${leave['start_date']} to ${leave['end_date']}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D)),
                                ),
                              ],
                            ),
                          ),
                          StatusChip(status: leave['status']),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),

        // Attendance Logs Card
        BrandCard(
          title: 'ATTENDANCE LOGS (ERP)',
          icon: Icons.receipt_long_outlined,
          child: attendanceList.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('No attendance punch data found.', style: TextStyle(color: Color(0xFF7F8C8D))),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attendanceList.length > 5 ? 5 : attendanceList.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFECEFF1)),
                  itemBuilder: (context, index) {
                    final att = attendanceList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  att['attendance_date'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'In: ${att['in_time'] != null ? att['in_time'].toString().substring(11, 16) : '-'} | Out: ${att['out_time'] != null ? att['out_time'].toString().substring(11, 16) : '-'}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D)),
                                ),
                              ],
                            ),
                          ),
                          StatusChip(status: att['status']),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
