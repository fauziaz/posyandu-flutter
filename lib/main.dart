// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/landing_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fatifoamnwbpkvadykin.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdGlmb2FtbndicGt2YWR5a2luIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3NTg4NjcsImV4cCI6MjA4MTMzNDg2N30.j865oYDp0YFAP4mu_b1PpiXdjURe_8UeaLkCXBuWlYk',
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Posyandu Harapan Bunda',
        theme: AppTheme.lightTheme,
        home: const LandingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
