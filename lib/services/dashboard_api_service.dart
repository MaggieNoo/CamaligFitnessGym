import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/dashboard_models.dart';
import 'package:intl/intl.dart';

class DashboardApiService {
  /// Get enrollment information (ft=200)
  static Future<Map<String, dynamic>> getEnrollmentInfo(String itoken) async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}${AppConstants.dashboardEndpoint}');

      print('🔵 Dashboard API - Get Enrollment Info');
      print('URL: $url');
      print('itoken: $itoken');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ft': '200',
          'itoken': itoken,
        },
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == '1' &&
            data['data'] != null &&
            data['data'] is List &&
            data['data'].length > 1) {
          // The API returns an array: [{"total":count}, enrollmentRecord]
          // Index 0 is the count, index 1 is the enrollment record
          final enrollmentData = data['data'][1];
          return {
            'success': true,
            'enrollment': EnrollmentInfoModel.fromJson(enrollmentData),
          };
        }
        return {
          'success': false,
          'message': data['msg'] ?? 'No enrollment found',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Get notifications (ft=300)
  static Future<Map<String, dynamic>> getNotifications(
    String itoken, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}${AppConstants.dashboardEndpoint}');

      print('🔵 Dashboard API - Get Notifications');
      print('URL: $url');
      print('Page: $page, Limit: $limit');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ft': '300',
          'itoken': itoken,
          'cpage': page.toString(),
          'limit': limit.toString(),
        },
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<NotificationModel> notifications = [];

        if (data['result'] == '1' &&
            data['data'] != null &&
            data['data'] is List) {
          // Skip the first element (count) and process the rest
          for (int i = 1; i < data['data'].length; i++) {
            notifications.add(NotificationModel.fromJson(data['data'][i]));
          }
        }

        return {
          'success': true,
          'notifications': notifications,
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Get calendar events (ft=100)
  static Future<Map<String, dynamic>> getCalendarEvents(
    String itoken, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}${AppConstants.dashboardEndpoint}');

      // Format dates as DD/MM/YYYY
      final dateFormat = DateFormat('dd/MM/yyyy');
      final from =
          fromDate ?? DateTime.now().subtract(const Duration(days: 30));
      final to = toDate ?? DateTime.now().add(const Duration(days: 30));
      final frDate = dateFormat.format(from);
      final toDate_ = dateFormat.format(to);

      print('🔵 Dashboard API - Get Calendar Events');
      print('URL: $url');
      print('Date Range: $frDate to $toDate_');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ft': '100',
          'itoken': itoken,
          'fr': frDate,
          'to': toDate_,
        },
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['sts'] == '01') {
          final List<DtrEventModel> events = [];
          if (data['result'] != null && data['result'] is List) {
            for (var item in data['result']) {
              events.add(DtrEventModel.fromJson(item));
            }
          }
          return {
            'success': true,
            'events': events,
          };
        } else {
          return {
            'success': false,
            'message': data['msg'] ?? 'Failed to get calendar events',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Update DTR label/remarks (ft=100-3)
  static Future<Map<String, dynamic>> updateDtrLabel({
    required String itoken,
    required String dtrId,
    required String label,
    required String remarks,
  }) async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}${AppConstants.dashboardEndpoint}');

      print('🔵 Dashboard API - Update DTR Label');
      print('DTR ID: $dtrId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ft': '100-3',
          'itoken': itoken,
          'id': dtrId,
          'label': label,
          'remarks': remarks,
        },
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['sts'] == '01',
          'message': data['msg'] ?? 'Update failed',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}
