import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  // Perform user login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Login failed');
    }
  }

  // Fetch current user details
  static Future<Map<String, dynamic>> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch user profile');
  }

  // Apply for a leave
  static Future<Map<String, dynamic>> applyLeave(
      String token, String startDate, String endDate, String reason) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/leaves/apply'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Failed to apply leave');
    }
  }

  // Get employee's own applied leaves
  static Future<List<dynamic>> fetchMyLeaves(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/leaves/my'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch leave history');
  }

  // Get employee's own salary slips from ERPNext
  static Future<List<dynamic>> fetchSalary(String token, String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/employee/salary/$employeeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    throw Exception('Failed to fetch salary from ERPNext');
  }

  // Get employee's own attendance from ERPNext
  static Future<List<dynamic>> fetchAttendance(String token, String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/employee/attendance/$employeeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? [];
    }
    throw Exception('Failed to fetch attendance logs');
  }

  // Punch attendance (in/out)
  static Future<Map<String, dynamic>> punchAttendance(
      String token, String status, String inTime, {String? outTime}) async {
    final payload = {
      'status': status,
      'in_time': inTime,
      if (outTime != null) 'out_time': outTime,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/api/employee/punch'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Attendance punch failed');
    }
  }

  // TL: Get pending leave approvals
  static Future<List<dynamic>> fetchPendingLeavesTL(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/leaves/pending/tl'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch TL pending approvals');
  }

  // TL: Approve/reject a leave
  static Future<Map<String, dynamic>> actionLeaveTL(String token, int leaveId, String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/leaves/action/tl'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'leave_id': leaveId, 'action': action}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update TL leave action');
  }

  // HR: Get pending final approvals
  static Future<List<dynamic>> fetchPendingLeavesHR(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/leaves/pending/hr'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch HR pending approvals');
  }

  // HR: Finalize approve/reject a leave and deduct count
  static Future<Map<String, dynamic>> actionLeaveHR(String token, int leaveId, String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/leaves/action/hr'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'leave_id': leaveId, 'action': action}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to finalize HR leave action');
  }

  // HR: Create a new user account
  static Future<Map<String, dynamic>> createNewUser(
      String token, String username, String password, String role, String employeeId, String name, int totalLeaves) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
        'employee_id': employeeId,
        'name': name,
        'total_leaves': totalLeaves,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Failed to create new user');
    }
  }

  // HR/Director: List all portal users
  static Future<List<dynamic>> fetchUserList(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch user directory');
  }

  // Director: Get overview metrics summary
  static Future<Map<String, dynamic>> fetchDirectorSummary(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/director/summary'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to fetch director system summary');
  }
}
