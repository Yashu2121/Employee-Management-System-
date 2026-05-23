import 'package:flutter/material.dart';
import '../../widgets/brand_card.dart';

class HRCreateUserView extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController empIdController;
  final TextEditingController leavesController;
  final String selectedRole;
  final ValueChanged<String?> onRoleChanged;
  final VoidCallback onCreateUser;

  const HRCreateUserView({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.nameController,
    required this.empIdController,
    required this.leavesController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onCreateUser,
  });

  @override
  State<HRCreateUserView> createState() => _HRCreateUserViewState();
}

class _HRCreateUserViewState extends State<HRCreateUserView> {
  @override
  Widget build(BuildContext context) {
    return BrandCard(
      title: 'REGISTER NEW PORTAL USER',
      icon: Icons.person_add_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.usernameController,
            decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.nameController,
            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.badge_outlined)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.empIdController,
            decoration: const InputDecoration(labelText: 'Employee ID (e.g. EMP-0006)', prefixIcon: Icon(Icons.numbers)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: widget.selectedRole,
            decoration: const InputDecoration(labelText: 'Access Role', prefixIcon: Icon(Icons.work_outline)),
            items: const [
              DropdownMenuItem(value: 'employee', child: Text('Employee')),
              DropdownMenuItem(value: 'team_leader', child: Text('Team Leader')),
              DropdownMenuItem(value: 'hr', child: Text('HR Manager')),
              DropdownMenuItem(value: 'director', child: Text('Director')),
            ],
            onChanged: widget.onRoleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.leavesController,
            decoration: const InputDecoration(labelText: 'Total Leave Balance (Yearly)', prefixIcon: Icon(Icons.calendar_month_outlined)),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onCreateUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE8E30),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('CREATE PORTAL ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
