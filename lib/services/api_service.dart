import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/user_model.dart';

class ApiService {
  // Login API
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final url = '${AppConstants.baseUrl}${AppConstants.loginEndpoint}';
      print('Login URL: $url'); // Debug log

      final response = await http.post(
        Uri.parse(url),
        body: {
          'ftr': '100-0',
          'token': AppConstants.apiToken,
          'key': '',
          'un': username,
          'pw': password,
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['count'] == '1' && data['data'] != null) {
          final userData = json.decode(data['data']);
          final user = UserModel.fromJson(userData);

          return {'success': true, 'message': 'Login successful', 'user': user};
        } else {
          return {
            'success': false,
            'message': data['result'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Server error (${response.statusCode}). Please check your connection.',
        };
      }
    } on SocketException catch (e) {
      print('SocketException: $e'); // Debug log
      return {
        'success': false,
        'message':
            'Cannot connect to server. Please check:\n1. XAMPP is running\n2. Same WiFi network\n3. IP: ${AppConstants.baseUrl}',
      };
    } catch (e) {
      print('Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Registration API
  static Future<Map<String, dynamic>> register({
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
      final response = await http.post(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.registrationEndpoint}',
        ),
        body: {
          'ftr': '100-1',
          'token': AppConstants.apiToken,
          'key': '',
          'fn': firstName,
          'mn': middleName,
          'ln': lastName,
          'gender': gender,
          'dob': birthday, // Format: MM-DD-YYYY
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['count'] == '1') {
          return {
            'success': true,
            'message': data['result'] ?? 'Registration successful',
            'id': data['id'],
            'token': data['token'],
          };
        } else {
          return {
            'success': false,
            'message': data['result'] ?? 'Registration failed',
            'code': data['code'],
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
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

  // Forgot Password API
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
        body: {
          'ftr': '110-0',
          'token': AppConstants.apiToken,
          'key': '',
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['count'] == '1') {
          return {
            'success': true,
            'message': data['result'] ?? 'OTP sent to your email',
            'sid': data['sid'],
            'email': data['email'],
          };
        } else {
          return {
            'success': false,
            'message': data['result'] ?? 'Email not found',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
}
