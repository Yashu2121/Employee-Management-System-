import 'package:flutter/material.dart';
import '../../widgets/brand_card.dart';

class HRDirectoryView extends StatelessWidget {
  final List<dynamic> userList;

  const HRDirectoryView({super.key, required this.userList});

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      title: 'USERS DIRECTORY',
      icon: Icons.folder_shared_outlined,
      child: userList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userList.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFECEFF1)),
              itemBuilder: (context, index) {
                final user = userList[index];
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
                              user['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                            ),
                            Text(
                              'ID: ${user['employee_id']} | ${user['role'].toString().replaceAll('_', ' ').toUpperCase()}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Leaves: ${user['remaining_leaves']}/${user['total_leaves']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFEE8E30)),
                          ),
                          const Text(
                            'days remaining',
                            style: TextStyle(fontSize: 9, color: Color(0xFF7F8C8D)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
