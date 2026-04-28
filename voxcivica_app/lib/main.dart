import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("Initializing Supabase...");
    await Supabase.initialize(
      url: 'https://fhrdjchxrkzcqmqgsuaz.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZocmRqY2h4cmt6Y3FtcWdzdWF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyMjgzNzEsImV4cCI6MjA5MjgwNDM3MX0.HlfkhzlRFOV3wORos-APBPDTHVyBSm4Sb8EkEwO3BcA',
    );
    print("Supabase Initialized Successfully!");
    runApp(const VoxCivicaApp());
  } catch (e) {
    print("ERROR: SUPABASE INIT ERROR: $e");
    // Show the error on screen so we can see it without the console
    runApp(MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: Center(child: Text("Startup Error: $e", style: const TextStyle(color: Colors.red))))
    ));
  }
}

class VoxCivicaApp extends StatelessWidget {
  const VoxCivicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoxCivica AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final session = snapshot.hasData ? snapshot.data!.session : null;
          return session != null ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
