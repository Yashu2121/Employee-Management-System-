import 'package:flutter/material.dart';
import '../../widgets/brand_card.dart';

class EmployeeDashboardView extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final List<dynamic> attendanceList;
  final bool isPunching;
  final VoidCallback onPunch;

  const EmployeeDashboardView({
    super.key,
    required this.currentUser,
    required this.attendanceList,
    required this.isPunching,
    required this.onPunch,
  });

  @override
  Widget build(BuildContext context) {
    final leavesLeft = currentUser['remaining_leaves'] ?? 12;
    final leavesTotal = currentUser['total_leaves'] ?? 12;
    final percent = leavesTotal > 0 ? (leavesLeft / leavesTotal) : 0.0;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    Map<String, dynamic>? todayAttendance;
    for (var att in attendanceList) {
      if (att['attendance_date'] == todayStr) {
        todayAttendance = att;
        break;
      }
    }

    final hasPunchedIn = todayAttendance != null && todayAttendance['in_time'] != null;
    final hasPunchedOut = todayAttendance != null && todayAttendance['out_time'] != null;

    String punchStatusText = 'Not Punched In Today';
    if (hasPunchedIn && !hasPunchedOut) {
      punchStatusText = 'Punched In: ${todayAttendance['in_time'].toString().substring(11, 16)}';
    } else if (hasPunchedIn && hasPunchedOut) {
      punchStatusText = 'Punched Out: ${todayAttendance['out_time'].toString().substring(11, 16)}';
    }

    return Column(
      children: [
        // Leave Balance Widget
        BrandCard(
          title: 'LEAVE BALANCE',
          icon: Icons.calendar_month,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$leavesLeft / $leavesTotal',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Remaining Days Approved',
                style: TextStyle(fontSize: 12, color: Color(0xFF7F8C8D), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: const Color(0xFFECEFF1),
                color: const Color(0xFFEE8E30),
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Attendance Punch Widget
        BrandCard(
          title: 'ATTENDANCE PUNCH',
          icon: Icons.fingerprint,
          child: Column(
            children: [
              Text(
                punchStatusText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 16),
              isPunching
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: hasPunchedIn && hasPunchedOut ? null : onPunch,
                      icon: Icon(hasPunchedIn ? Icons.logout_outlined : Icons.login_outlined, color: Colors.white, size: 16),
                      label: Text(hasPunchedIn ? 'PUNCH OUT' : 'PUNCH IN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasPunchedIn ? const Color(0xFFE74C3C) : const Color(0xFFEE8E30),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
