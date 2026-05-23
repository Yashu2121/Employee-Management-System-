import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

// Import sub-views
import 'employee/employee_dashboard_view.dart';
import 'employee/employee_history_view.dart';
import 'employee/employee_apply_view.dart';
import 'employee/employee_salary_view.dart';
import 'team_leader/team_leader_dashboard_view.dart';
import 'hr/hr_dashboard_view.dart';
import 'hr/hr_create_user_view.dart';
import 'hr/hr_directory_view.dart';
import 'director/director_dashboard_view.dart';

class DashboardShell extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const DashboardShell({super.key, required this.token, required this.user});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  late Map<String, dynamic> _currentUser;
  bool _isPunching = false;
  int _mobileSelectedIndex = 0;

  // Data lists
  List<dynamic> _myLeaves = [];
  List<dynamic> _pendingLeavesTL = [];
  List<dynamic> _pendingLeavesHR = [];
  List<dynamic> _salarySlips = [];
  List<dynamic> _attendanceList = [];
  List<dynamic> _userList = [];

  // Controllers
  final _createUsername = TextEditingController();
  final _createPassword = TextEditingController();
  final _createName = TextEditingController();
  final _createEmpId = TextEditingController();
  final _createLeaves = TextEditingController(text: '12');
  String _createRole = 'employee';

  final _leaveStartDate = TextEditingController();
  final _leaveEndDate = TextEditingController();
  final _leaveReason = TextEditingController();

  Map<String, dynamic> _directorSummary = {};

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _refreshData();
  }

  Future<void> _refreshData() async {
    await _fetchProfile();
    final role = _currentUser['role'];
    if (role == 'employee') {
      await _fetchMyLeaves();
      await _fetchSalary();
      await _fetchAttendance();
    } else if (role == 'team_leader') {
      await _fetchPendingLeavesTL();
      await _fetchUserList(); // Attendance list
    } else if (role == 'hr') {
      await _fetchPendingLeavesHR();
      await _fetchUserList();
    } else if (role == 'director') {
      await _fetchDirectorSummary();
      await _fetchUserList();
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await ApiService.fetchProfile(widget.token);
      setState(() {
        _currentUser = data;
      });
    } catch (e) {
      debugPrint('Profile error: $e');
    }
  }

  Future<void> _fetchMyLeaves() async {
    try {
      final data = await ApiService.fetchMyLeaves(widget.token);
      setState(() {
        _myLeaves = data;
      });
    } catch (e) {
      debugPrint('My leaves error: $e');
    }
  }

  Future<void> _fetchSalary() async {
    try {
      final data = await ApiService.fetchSalary(widget.token, _currentUser['employee_id']);
      setState(() {
        _salarySlips = data;
      });
    } catch (e) {
      debugPrint('Salary error: $e');
    }
  }

  Future<void> _fetchAttendance() async {
    try {
      final data = await ApiService.fetchAttendance(widget.token, _currentUser['employee_id']);
      setState(() {
        _attendanceList = data;
      });
    } catch (e) {
      debugPrint('Attendance error: $e');
    }
  }

  Future<void> _fetchPendingLeavesTL() async {
    try {
      final data = await ApiService.fetchPendingLeavesTL(widget.token);
      setState(() {
        _pendingLeavesTL = data;
      });
    } catch (e) {
      debugPrint('TL pending error: $e');
    }
  }

  Future<void> _fetchPendingLeavesHR() async {
    try {
      final data = await ApiService.fetchPendingLeavesHR(widget.token);
      setState(() {
        _pendingLeavesHR = data;
      });
    } catch (e) {
      debugPrint('HR pending error: $e');
    }
  }

  Future<void> _fetchUserList() async {
    try {
      final data = await ApiService.fetchUserList(widget.token);
      setState(() {
        _userList = data;
      });
    } catch (e) {
      debugPrint('User list error: $e');
    }
  }

  Future<void> _fetchDirectorSummary() async {
    try {
      final data = await ApiService.fetchDirectorSummary(widget.token);
      setState(() {
        _directorSummary = data;
      });
    } catch (e) {
      debugPrint('Director summary error: $e');
    }
  }

  Future<void> _applyLeave() async {
    if (_leaveStartDate.text.isEmpty || _leaveEndDate.text.isEmpty || _leaveReason.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all leave fields.')),
      );
      return;
    }

    try {
      await ApiService.applyLeave(
        widget.token,
        _leaveStartDate.text,
        _leaveEndDate.text,
        _leaveReason.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave applied successfully!')),
        );
        _leaveStartDate.clear();
        _leaveEndDate.clear();
        _leaveReason.clear();
        _refreshData();
        setState(() {
          _mobileSelectedIndex = 1; // Switch to history tab on mobile
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _punchAttendance() async {
    setState(() {
      _isPunching = true;
    });

    final now = DateTime.now();
    final timeStr = now.toIso8601String().substring(0, 19).replaceFirst('T', ' ');
    final todayStr = timeStr.substring(0, 10);

    bool hasPunchedIn = false;
    for (var att in _attendanceList) {
      if (att['attendance_date'] == todayStr && att['in_time'] != null) {
        hasPunchedIn = true;
        break;
      }
    }

    try {
      await ApiService.punchAttendance(
        widget.token,
        'Present',
        timeStr,
        outTime: hasPunchedIn ? timeStr : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(hasPunchedIn ? 'Successfully punched out!' : 'Successfully punched in!')),
        );
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPunching = false;
        });
      }
    }
  }

  Future<void> _tlLeaveAction(int leaveId, String action) async {
    try {
      await ApiService.actionLeaveTL(widget.token, leaveId, action);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave successfully ${action}ed by Team Leader.')),
        );
        _refreshData();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _hrLeaveAction(int leaveId, String action) async {
    try {
      await ApiService.actionLeaveHR(widget.token, leaveId, action);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave successfully ${action}ed by HR. Leave balance updated.')),
        );
        _refreshData();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _createNewUser() async {
    if (_createUsername.text.isEmpty ||
        _createPassword.text.isEmpty ||
        _createName.text.isEmpty ||
        _createEmpId.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all user details.')),
      );
      return;
    }

    try {
      await ApiService.createNewUser(
        widget.token,
        _createUsername.text,
        _createPassword.text,
        _createRole,
        _createEmpId.text,
        _createName.text,
        int.tryParse(_createLeaves.text) ?? 12,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New user created successfully!')),
        );
        _createUsername.clear();
        _createPassword.clear();
        _createName.clear();
        _createEmpId.clear();
        _refreshData();
        setState(() {
          _mobileSelectedIndex = 2; // Switch to Directory listing
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = _currentUser['role'];
    final name = _currentUser['name'];
    final empId = _currentUser['employee_id'];
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'touchmatik',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFEE8E30),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Smart Employee Portal',
              style: TextStyle(fontSize: 10, color: const Color(0xFF2C3E50).withOpacity(0.6), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (!isMobile)
            Center(
              child: Text(
                '$name ($role) ',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E50)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.sync, color: Color(0xFFEE8E30)),
            onPressed: _refreshData,
            tooltip: 'Sync Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF2C3E50)),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNavigationBar(role) : null,
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF7F8FA),
          child: Column(
            children: [
              // User Mini Header bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFECEFF1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                          ),
                          Text(
                            'ID: $empId  |  Role: ${role.toString().replaceAll('_', ' ').toUpperCase()}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    ActionChip(
                      padding: EdgeInsets.zero,
                      label: const Text('SYNC LIVE'),
                      avatar: const Icon(Icons.sync, size: 12, color: Colors.white),
                      backgroundColor: const Color(0xFFEE8E30),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      onPressed: _refreshData,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: isMobile ? _buildMobileView(role) : _buildDesktopView(role),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Bottom navigation bar for mobile layout ---
  Widget? _buildBottomNavigationBar(String role) {
    if (role == 'employee') {
      return BottomNavigationBar(
        currentIndex: _mobileSelectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEE8E30),
        unselectedItemColor: const Color(0xFF7F8C8D),
        onTap: (index) => setState(() => _mobileSelectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Apply Leave'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), label: 'Salary'),
        ],
      );
    } else if (role == 'team_leader') {
      return BottomNavigationBar(
        currentIndex: _mobileSelectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEE8E30),
        unselectedItemColor: const Color(0xFF7F8C8D),
        onTap: (index) => setState(() => _mobileSelectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.approval), label: 'Approvals'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Attendance'),
        ],
      );
    } else if (role == 'hr') {
      return BottomNavigationBar(
        currentIndex: _mobileSelectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEE8E30),
        unselectedItemColor: const Color(0xFF7F8C8D),
        onTap: (index) => setState(() => _mobileSelectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.done_all), label: 'Approvals'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_outlined), label: 'New User'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_shared_outlined), label: 'Directory'),
        ],
      );
    } else if (role == 'director') {
      return BottomNavigationBar(
        currentIndex: _mobileSelectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEE8E30),
        unselectedItemColor: const Color(0xFF7F8C8D),
        onTap: (index) => setState(() => _mobileSelectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Metrics'),
          BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle_outlined), label: 'Directory'),
        ],
      );
    }
    return null;
  }

  // --- Mobile View Dispatcher ---
  Widget _buildMobileView(String role) {
    if (role == 'employee') {
      switch (_mobileSelectedIndex) {
        case 0:
          return EmployeeDashboardView(
            currentUser: _currentUser,
            attendanceList: _attendanceList,
            isPunching: _isPunching,
            onPunch: _punchAttendance,
          );
        case 1:
          return EmployeeHistoryView(
            myLeaves: _myLeaves,
            attendanceList: _attendanceList,
          );
        case 2:
          return EmployeeApplyView(
            startDateController: _leaveStartDate,
            endDateController: _leaveEndDate,
            reasonController: _leaveReason,
            onApply: _applyLeave,
          );
        case 3:
          return EmployeeSalaryView(
            salarySlips: _salarySlips,
          );
      }
    } else if (role == 'team_leader') {
      return TeamLeaderDashboardView(
        pendingLeaves: _pendingLeavesTL,
        userList: _userList,
        selectedIndex: _mobileSelectedIndex,
        onAction: _tlLeaveAction,
      );
    } else if (role == 'hr') {
      switch (_mobileSelectedIndex) {
        case 0:
          return HRDashboardView(
            pendingLeaves: _pendingLeavesHR,
            onAction: _hrLeaveAction,
          );
        case 1:
          return HRCreateUserView(
            usernameController: _createUsername,
            passwordController: _createPassword,
            nameController: _createName,
            empIdController: _createEmpId,
            leavesController: _createLeaves,
            selectedRole: _createRole,
            onRoleChanged: (val) {
              if (val != null) {
                setState(() => _createRole = val);
              }
            },
            onCreateUser: _createNewUser,
          );
        case 2:
          return HRDirectoryView(
            userList: _userList,
          );
      }
    } else if (role == 'director') {
      switch (_mobileSelectedIndex) {
        case 0:
          return DirectorDashboardView(
            directorSummary: _directorSummary,
          );
        case 1:
          return HRDirectoryView(
            userList: _userList,
          );
      }
    }
    return const Center(child: Text('Subview not found'));
  }

  // --- Desktop View Grid Dispatcher ---
  Widget _buildDesktopView(String role) {
    if (role == 'employee') {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    EmployeeDashboardView(
                      currentUser: _currentUser,
                      attendanceList: _attendanceList,
                      isPunching: _isPunching,
                      onPunch: _punchAttendance,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: EmployeeSalaryView(
                  salarySlips: _salarySlips,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: EmployeeApplyView(
                  startDateController: _leaveStartDate,
                  endDateController: _leaveEndDate,
                  reasonController: _leaveReason,
                  onApply: _applyLeave,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: EmployeeHistoryView(
                  myLeaves: _myLeaves,
                  attendanceList: _attendanceList,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (role == 'team_leader') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: TeamLeaderDashboardView(
              pendingLeaves: _pendingLeavesTL,
              userList: _userList,
              selectedIndex: 0,
              onAction: _tlLeaveAction,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: TeamLeaderDashboardView(
              pendingLeaves: _pendingLeavesTL,
              userList: _userList,
              selectedIndex: 1,
              onAction: _tlLeaveAction,
            ),
          ),
        ],
      );
    } else if (role == 'hr') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                HRDashboardView(
                  pendingLeaves: _pendingLeavesHR,
                  onAction: _hrLeaveAction,
                ),
                const SizedBox(height: 20),
                HRCreateUserView(
                  usernameController: _createUsername,
                  passwordController: _createPassword,
                  nameController: _createName,
                  empIdController: _createEmpId,
                  leavesController: _createLeaves,
                  selectedRole: _createRole,
                  onRoleChanged: (val) {
                    if (val != null) {
                      setState(() => _createRole = val);
                    }
                  },
                  onCreateUser: _createNewUser,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 4,
            child: HRDirectoryView(
              userList: _userList,
            ),
          ),
        ],
      );
    } else if (role == 'director') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: DirectorDashboardView(
              directorSummary: _directorSummary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 4,
            child: HRDirectoryView(
              userList: _userList,
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }
}
