import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/app_config.dart';

class AppConfigService {
  static Future<AppConfig> load() async {
    try {
      final jsonText = await rootBundle.loadString('assets/app_config.json');
      final json = jsonDecode(jsonText) as Map<String, dynamic>;
      return AppConfig.fromJson(json);
    } catch (_) {
      return const AppConfig();
    }
  }
}
