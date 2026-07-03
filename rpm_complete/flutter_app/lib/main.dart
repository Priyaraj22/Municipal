import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/citizen_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ═══════════════════════════════════════════════════════════════════════════
  //  SET YOUR SERVER IP HERE before running flutter build apk --release
  //  Example: ApiService.baseUrl = 'http://192.168.1.100:3000/api';
  // ═══════════════════════════════════════════════════════════════════════════
  ApiService.baseUrl = 'http://172.16.147.122:3000/api';

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
      home: const _SplashRouter(),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthProvider>().restoreSession();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    Widget home;
    if (auth.isLoggedIn) {
      if (auth.isAdmin || auth.collectorName != null) {
        home = const HomeScreen();
      } else if (auth.isCitizen) {
        home = const CitizenHomeScreen();
      } else {
        home = const LoginScreen();
      }
    } else {
      home = const LoginScreen();
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => home,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text('🏛', style: TextStyle(fontSize: 46)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Rajapalayam Municipality',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('ராஜபாளையம் நகராட்சி',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const Text('Family Survey System · குடும்பப் பதிவேடு',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
