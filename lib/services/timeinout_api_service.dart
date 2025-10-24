import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/timeinout_models.dart';
import '../utils/constants.dart';

class TimeInOutApiService {
  // Scan QR code and either time-in or get current attendance status
  static Future<TimeInOutResponse> scanQRCode({
    required String itoken,
    required String qrCode,
  }) async {
    try {
      print('🔍 DEBUG - Sending QR scan request:');
      print('   itoken (user.id): $itoken');
      print('   qrCode: $qrCode');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}qr.account.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': AppConstants.apiToken,
          'key': 'gym',
          'ftr': '100-0', // Scan QR and time-in/get status
          'uid': itoken,
          'qr': qrCode,
        },
      );

      print('📱 Scan QR Code Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TimeInOutResponse.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Scan QR Code Error: $e');
      return TimeInOutResponse(
        result: '0',
        message: 'Failed to process QR code: $e',
      );
    }
  }

  // Submit payment or time-out action
  static Future<TimeActionResponse> submitTimeAction({
    required String actionType, // "0" = pay only, "1" = time-out
    required String dtrId,
    required String amount, // Amount paid (for payment action)
  }) async {
    try {
      // Format lid parameter: "actionType-dtrId-amount"
      final lid = '$actionType-$dtrId-$amount';

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}qr.account.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': AppConstants.apiToken,
          'key': 'gym',
          'ftr': '100-1', // Submit payment or time-out
          'lid': lid,
        },
      );

      print('📤 Submit Time Action Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TimeActionResponse.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Submit Time Action Error: $e');
      return TimeActionResponse(
        result: '0',
        message: 'Failed to submit action: $e',
      );
    }
  }

  // Time-in again after already timing out (second workout session)
  static Future<TimeActionResponse> timeInAgain({
    required String enrollmentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}qr.account.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'token': AppConstants.apiToken,
          'key': 'gym',
          'ftr': '100-2', // Time-in again
          'eid': enrollmentId, // Enrollment ID
        },
      );

      print('🔄 Time-in Again Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TimeActionResponse.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Time-in Again Error: $e');
      return TimeActionResponse(
        result: '0',
        message: 'Failed to time-in again: $e',
      );
    }
  }
}
