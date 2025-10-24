import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../models/enrollment_models.dart';

class EnrollmentApiService {
  /// Get programs and trainors (ft=100)
  static Future<Map<String, dynamic>> getProgramsAndTrainors(
      String itoken) async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}${AppConstants.enrollEndpoint}');

      print('🔵 Enrollment API - Get Programs & Trainors');
      print('URL: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ft': '100',
          'itoken': itoken,
        },
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Check if response contains the expected fields
        if (data.containsKey('pid')) {
          final enrollmentData = EnrollmentResponse.fromJson(data);
          return {
            'success': true,
            'data': enrollmentData,
          };
        } else {
          return {
            'success': false,
            'message': data['msg'] ?? 'Failed to load programs',
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

  /// Submit enrollment (ft=100-1)
  static Future<Map<String, dynamic>> submitEnrollment({
    required String itoken,
    required String programToken,
    required String type, // "1" for Daily, "2" for Monthly/Consumable
    required String amountPaid,
    required String trainorId,
    required DateTime startDate,
    DateTime? endDate, // Required for type='2' (Monthly/Consumable)
  }) async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}${AppConstants.enrollEndpoint}');

      // Format dates as MM/dd/yyyy (backend expects this format for db_date function)
      final dateFormat = DateFormat('MM/dd/yyyy');
      final dated = dateFormat.format(startDate);
      final ended = endDate != null ? dateFormat.format(endDate) : '';

      print('🔵 Enrollment API - Submit Enrollment');
      print('URL: $url');
      print('Type: $type, Amount: $amountPaid, Trainor: $trainorId');
      print('Start: $dated, End: $ended');

      // Backend expects 'data_' as JSON with token field
      final dataJson = json.encode({'token': programToken});

      // Backend expects 'data' as URL-encoded string with form fields
      // Note: trainorId should be empty string if not selected, not "null"
      final trainor = trainorId.isEmpty ? '' : trainorId;
      final dataString =
          'type=$type&paid=$amountPaid&trainor=$trainor&dated=$dated&ended=$ended';

      print('Data string: $dataString');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ft': '100-1',
          'itoken': itoken,
          'data': dataString,
          'data_': dataJson,
        },
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Backend returns an array with one object: [{"result":"1","ok":"X","message":"..."}]
        if (responseData is List && responseData.isNotEmpty) {
          final data = responseData[0];
          if (data['result'] == '1') {
            return {
              'success': true,
              'message': data['message'] ?? 'Enrollment successful!',
            };
          } else {
            return {
              'success': false,
              'message': data['message'] ?? 'Enrollment failed',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Invalid response format',
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
}
