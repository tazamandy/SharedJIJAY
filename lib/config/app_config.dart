// lib/config/app_config.dart
class AppConfig {
  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  // Backend URLs
  static const String productionBackend = 'https://newset.onrender.com';
  static const String stagingBackend =
      'https://newset-staging.onrender.com'; // Optional
  static const String developmentBackend = 'http://10.0.2.2:3000';

  // App settings
  static const String appName = 'Attendance System';
  static const String appVersion = '1.0.0';
  static const int apiTimeoutSeconds = 30;
  static const bool enableLogging = true;

  // Get current backend URL
  static String get backendUrl {
    switch (environment.toLowerCase()) {
      case 'development':
        return developmentBackend;
      case 'staging':
        return stagingBackend;
      case 'production':
      default:
        return productionBackend;
    }
  }

  // Check if running in production
  static bool get isProduction => environment == 'production';

  // Check if running in debug mode
  static bool get isDebug {
    bool inDebugMode = false;
    assert(() {
      inDebugMode = true;
      return true;
    }());
    return inDebugMode;
  }

  // Get API timeout duration
  static Duration get apiTimeout => Duration(seconds: apiTimeoutSeconds);
}
