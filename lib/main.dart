import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'presentation/screens/calendar/calendar_screen.dart';
import 'core/themes/app_theme.dart';
import 'core/services/notification_service.dart'; // Import notification service
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database berdasarkan platform
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    developer.log('🌐 Running on WEB - Using IndexedDB', name: 'main');
  } else {
    await databaseFactory.getDatabasesPath();
    developer.log('📱 Running on MOBILE - Using SQLite', name: 'main');
    
    // ✅ TAMBAHAN: Initialize notification service (only for mobile)
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      
      // Request permission
      final hasPermission = await notificationService.requestPermission();
      if (hasPermission) {
        developer.log('✅ Notification permission granted', name: 'main');
      } else {
        developer.log('⚠️ Notification permission denied', name: 'main');
      }
    } catch (e) {
      developer.log('⚠️ Error initializing notifications: $e', name: 'main');
    }
  }
  
  // Set preferred orientations (hanya untuk mobile)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  runApp(
    const ProviderScope(
      child: CalendarApp(),
    ),
  );
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const CalendarScreen(),
    );
  }
}