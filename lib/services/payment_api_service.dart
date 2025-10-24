import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/payment_models.dart';

class PaymentApiService {
  // Get list of enrollments for payment
  static Future<Map<String, dynamic>> getEnrollments(
      String token, int page, int limit) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.dtrEndpoint}'),
        body: {
          'itoken': token,
          'ft': '100',
          'cpage': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] == '1' &&
            data['data'] != null &&
            data['data'] is List) {
          final dataList = data['data'] as List;

          if (dataList.isNotEmpty) {
            final total =
                int.tryParse(dataList[0]['total']?.toString() ?? '0') ?? 0;
            final enrollments = <EnrollmentDetailModel>[];

            // Parse enrollment data (starts from index 1)
            for (int i = 1; i < dataList.length; i++) {
              enrollments.add(EnrollmentDetailModel.fromJson(dataList[i]));
            }

            return {
              'success': true,
              'total': total,
              'data': enrollments,
            };
          }
        }

        return {'success': false, 'message': 'No enrollments found'};
      }

      return {'success': false, 'message': 'Failed to load enrollments'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  } // Get payment history for specific enrollment

  static Future<Map<String, dynamic>> getPaymentHistory(
      String token, String enrollmentIdToken) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.dtrEndpoint}'),
        body: {
          'itoken': enrollmentIdToken, // Use enrollment's itoken
          'ft': '100-2',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Backend returns: {'result': '1', 'data': [{'total': 1}, {...payment data...}]}
        if (data is Map<String, dynamic>) {
          final result = data['result']?.toString() ?? '0';

          if (result == '1') {
            final dataArray = data['data'] as List? ?? [];
            final payments = <PaymentHistoryModel>[];

            // Skip first element if it's pagination data (has 'total' key)
            for (var i = 0; i < dataArray.length; i++) {
              if (dataArray[i] is Map && !dataArray[i].containsKey('total')) {
                payments.add(PaymentHistoryModel.fromJson(dataArray[i]));
              } else if (dataArray[i] is Map && i > 0) {
                // After pagination object, all are payment records
                payments.add(PaymentHistoryModel.fromJson(dataArray[i]));
              }
            }

            return {
              'success': true,
              'data': payments,
            };
          }

          return {'success': false, 'message': result};
        }

        return {'success': false, 'message': 'Invalid response format'};
      }

      return {'success': false, 'message': 'Failed to load payment history'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Submit payment
  static Future<Map<String, dynamic>> submitPayment(
      String token, String enrollmentId, double amount) async {
    try {
      // Create form data
      final formData = 'amount=${amount.toString()}';

      // Create JSON data for token
      final jsonData = json.encode({'token': enrollmentId});

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.dtrEndpoint}'),
        body: {
          'itoken': token,
          'ft': '100-3',
          'data': formData,
          'data_': jsonData,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          final result = data[0]['result']?.toString() ?? '0';
          final message = data[0]['message']?.toString() ?? 'Payment submitted';

          return {
            'success': result == '1',
            'message': message,
          };
        }

        return {'success': false, 'message': 'Invalid response format'};
      }

      return {'success': false, 'message': 'Failed to submit payment'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
