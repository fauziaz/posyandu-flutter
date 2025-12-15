// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/landing_screen.dart';
import 'utils/theme.dart';
import 'providers/history_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/schedule_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  await Supabase.initialize(
    url: 'https://fatifoamnwbpkvadykin.supabase.co',
    anonKey: 'sb_publishable_uRSYxCS8XQ5yvjBJKdbEhw_GLOq7hHs'
    );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: MaterialApp(
        title: 'Posyandu Harapan Bunda',
        theme: AppTheme.lightTheme,
        home: const LandingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
