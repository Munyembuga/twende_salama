import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:twende/models/overall_stats_model.dart';
import 'package:twende/services/storage_service.dart';
import 'package:twende/services/device_info_service.dart';

class StatsService {
  static const String baseUrl = 'http://move.itecsoft.site/api';

  static Future<Map<String, dynamic>> getOverallStats() async {
    try {
      // Check if user is registered or guest
      final userData = await StorageService.getUserData();
      final clientData = await StorageService.getClientData();
      final isGuestMode = await StorageService.isGuestMode();

      String url;

      if (userData != null && userData['id'] != null) {
        // Registered user - use client_id
        url = '$baseUrl/clientDash/overallRide?client_id=${userData['id']}';
      } else if (clientData != null && clientData['id'] != null) {
        // Registered client - use client_id
        url = '$baseUrl/clientDash/overallRide?client_id=${clientData['id']}';
      } else {
        // Guest user - use device_id
        final deviceId = await DeviceInfoService.getDeviceId();
        url = '$baseUrl/clientDash/overallRide?device_id=$deviceId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final overallStats = OverallStatsModel.fromJson(data);

          return {
            'success': true,
            'data': overallStats,
            'message': 'Statistics retrieved successfully',
          };
        } else {
          return {
            'success': false,
            'data': null,
            'message': 'Failed to load statistics',
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
