// listen to auth state changes countinously and redirect to the appropriate screen

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youth_center/screens/Home/home.dart';
import 'package:youth_center/screens/welcome/welcome_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isCheckingSession = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkInitialSession();
  }

  Future<void> _checkInitialSession() async {
    // Check if there's a persisted session first
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isAuthenticated = session != null;
      _isCheckingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking initial session
    if (_isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Listen to auth state changes for real-time updates
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Use the stream session if available, otherwise use the initial check
        final session = snapshot.hasData 
            ? snapshot.data!.session 
            : (_isAuthenticated ? Supabase.instance.client.auth.currentSession : null);
        
        if (session != null) {
          return const HomeScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
