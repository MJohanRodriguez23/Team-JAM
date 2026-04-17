import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_ufpso/screens/home_screen.dart';
import 'package:to_do_ufpso/screens/login_screen.dart';
import 'package:to_do_ufpso/screens/register_screen.dart';
import 'package:to_do_ufpso/services/firebase_bootstrap.dart';
import 'package:to_do_ufpso/utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do UFPSO',
      theme: AppTheme.light(),
      home: const AppStartGate(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AppStartGate extends StatelessWidget {
  const AppStartGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: FirebaseBootstrap.ensureInitialized(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const LoginScreen();
        }

        if (FirebaseAuth.instance.currentUser != null) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
