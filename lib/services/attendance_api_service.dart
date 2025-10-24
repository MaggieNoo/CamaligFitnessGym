import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/attendance_models.dart';

class AttendanceApiService {
  /// Get attendance/DTR records with optional filters
  static Future<Map<String, dynamic>> getAttendanceRecords({
    required String itoken,
    int page = 1,
    int limit = 20,
    String? fromDate, // Format: YYYY-MM-DD
    String? toDate, // Format: YYYY-MM-DD
    String? enrollmentId,
  }) async {
    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.attendanceEndpoint}');

      print('🔵 Attendance API - Get Records');
      print('URL: $url');
      print('Page: $page, Limit: $limit');
      if (fromDate != null) print('From: $fromDate');
      if (toDate != null) print('To: $toDate');

      final body = {
        'ft': '100', // Feature code for getting DTR records
        'itoken': itoken,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (fromDate != null) body['from_date'] = fromDate;
      if (toDate != null) body['to_date'] = toDate;
      if (enrollmentId != null) body['enrollment_id'] = enrollmentId;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] == '1' &&
            data['data'] != null &&
            data['data'] is List) {
          final List<DtrRecordModel> records = [];

          // Skip first element (count/total info) and process records
          for (int i = 1; i < data['data'].length; i++) {
            records.add(DtrRecordModel.fromJson(data['data'][i]));
          }

          return {
            'success': true,
            'records': records,
            'total': data['total'] ?? records.length,
            'page': page,
          };
        }

        return {
          'success': false,
          'message': data['msg'] ?? 'No records found',
          'records': [],
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'records': [],
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
        'records': [],
      };
    }
  }

  /// Get attendance records for current month
  static Future<Map<String, dynamic>> getCurrentMonthAttendance(
      String itoken) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    return getAttendanceRecords(
      itoken: itoken,
      fromDate: _formatDate(firstDay),
      toDate: _formatDate(lastDay),
      limit: 100, // Get all records for the month
    );
  }

  /// Get attendance records for a specific date range
  static Future<Map<String, dynamic>> getAttendanceByDateRange({
    required String itoken,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    return getAttendanceRecords(
      itoken: itoken,
      fromDate: _formatDate(fromDate),
      toDate: _formatDate(toDate),
      limit: 100,
    );
  }

  /// Get recent attendance (last N records)
  static Future<Map<String, dynamic>> getRecentAttendance({
    required String itoken,
    int limit = 10,
  }) async {
    return getAttendanceRecords(
      itoken: itoken,
      page: 1,
      limit: limit,
    );
  }

  /// Helper to format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
