import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const RajapalayamSurveyApp(),
    ),
  );
}

class RajapalayamSurveyApp extends StatelessWidget {
  const RajapalayamSurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rajapalayam Survey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Open HomeScreen directly, which contains the New Survey form
      home: const HomeScreen(),
    );
  }
}
