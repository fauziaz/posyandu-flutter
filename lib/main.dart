// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/article_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/main_navigation.dart';
import 'utils/theme.dart';
import 'utils/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
      ],
      child: MaterialApp(
        title: 'Posyandu Harapan Bunda',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingScreen(),
          '/main': (context) => const MainNavigation(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
