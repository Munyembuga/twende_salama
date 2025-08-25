import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:twende/models/guest_user_model.dart';
import 'package:twende/services/device_info_service.dart';

class UserService {
  static const String baseUrl = 'http://move.itecsoft.site/api';

  static Future<Map<String, dynamic>> getGuestUserInfo() async {
    try {
      final deviceId = await DeviceInfoService.getDeviceId();

      final response = await http.get(
        Uri.parse('$baseUrl/clientDash/guest_client_info?device_id=$deviceId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final guestUserInfo = GuestUserModel.fromJson(data);

          return {
            'success': true,
            'data': guestUserInfo,
            'message': 'Guest user information retrieved successfully',
          };
        } else {
          return {
            'success': false,
            'data': null,
            'message':
                data['message'] ?? 'Failed to load guest user information',
          };
        }
      } else {
        return {
          'success': false,
          'data': null,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
