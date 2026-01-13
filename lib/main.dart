import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'config/app_config.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/user_session.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  await _initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Add other providers here
      ],
      child: MyApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  // Set base URL from configuration
  ApiService.setBaseUrl(AppConfig.backendUrl);

  // Enable/disable debug mode
  ApiService.setProductionMode(AppConfig.isProduction);

  // Initialize user session
  await UserSession.initialize();

  // Test connection on startup (optional)
  if (AppConfig.enableLogging) {
    final connection = await ApiService.testConnection();
    print('App Initialization:');
    print('🌐 Backend URL: ${AppConfig.backendUrl}');
    print('📱 Environment: ${AppConfig.environment}');
    print('🔗 Connection: ${connection['message']}');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppTheme.primaryBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.primaryButtonStyle(),
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: AppConfig.isDebug,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        // Add other routes here
      },
    );
  }
}
