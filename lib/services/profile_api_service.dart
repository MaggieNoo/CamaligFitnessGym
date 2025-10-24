import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ProfileApiService {
  // Update Profile API
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String gender,
    required String birthday,
    required String address,
    required String company,
    required String email,
    required String phone,
    String? phone2,
    required String username,
    required String password,
    String? profileBase64,
  }) async {
    try {
      final url = '${AppConstants.baseUrl}app.account.php';
      print('Update Profile URL: $url');
      print('User ID: $userId');
      print('Birthday: $birthday');

      final response = await http.post(
        Uri.parse(url),
        body: {
          'ftr': '100-3',
          'token': AppConstants.apiToken,
          'key': '',
          'sid': userId,
          'fn': firstName,
          'mn': middleName,
          'ln': lastName,
          'gender': gender,
          'bday': birthday, // Format: MM-DD-YYYY
          'address': address,
          'company': company,
          'email': email,
          'phone': phone,
          'phone2': phone2 ?? '',
          'un': username,
          'pw': password,
          'profile': profileBase64 ?? '',
        },
      );

      print('Update Profile Response Status: ${response.statusCode}');
      print('Update Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['count'] == '1') {
          return {
            'success': true,
            'message': 'Profile updated successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['result'] ?? 'Update failed',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Server error (${response.statusCode}). Please try again later.',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Change Password API
  static Future<Map<String, dynamic>> changePassword({
    required String userToken,
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final url = '${AppConstants.baseUrl}app.account.php';
      print('Change Password URL: $url');
      print('User Token: $userToken');
      print('Username: $username');

      // Send the encrypted token (from user.token field)
      final response = await http.post(
        Uri.parse(url),
        body: {
          'ftr': '110-3',
          'token': AppConstants.apiToken,
          'key': 'x',
          'itoken': userToken, // Using encrypted token from user.token
          'un': username,
          'pw': newPassword,
        },
      );

      print('Change Password Response Status: ${response.statusCode}');
      print('Change Password Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['count'] == '1' && data['code'] == '0') {
          return {
            'success': true,
            'message': data['msg'] ?? 'Password changed successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['result'] ?? 'Password change failed',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Server error (${response.statusCode}). Please try again later.',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
}
