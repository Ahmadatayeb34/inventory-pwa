import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/storage_service.dart';
import 'providers/inventory_provider.dart';
import 'providers/orders_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InventoryProvider()..loadInventory(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider()..loadOrders(),
        ),
      ],
      child: MaterialApp(
        title: 'نظام الإدارة المتكامل',
        debugShowCheckedModeBanner: false,
        
        // RTL support
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        
        // Theme configuration matching the PWA colors
        theme: ThemeData(
          useMaterial3: true,
          
          // Use default font (can be replaced with Cairo when font files are added)
          // fontFamily: 'Cairo',
          
          // Primary colors based on brand colors
          primaryColor: const Color(0xFF1e1b4b), // brand-900
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4f46e5), // brand-600
            secondary: Color(0xFFf59e0b), // accent-500
            surface: Colors.white,
            background: Color(0xFFF8FAFC),
            error: Colors.red,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFF1e293b), // slate-800
            onBackground: Color(0xFF1e293b),
            onError: Colors.white,
          ),
          
          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1e1b4b),
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: false,
          ),
          
          // Card theme
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          
          // Button themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          
          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4f46e5), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          
          // Text theme with Cairo font
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1e1b4b),
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1e1b4b),
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e1b4b),
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF1e293b),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF475569),
            ),
          ),
        ),
        
        home: const HomeScreen(),
      ),
    );
  }
}
