import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youth_center/screens/auth/pages/login.dart';
import 'package:youth_center/screens/auth/services/auth_gate.dart';

void main() async {
  await Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmb2hyempreXJ5a3NzaHVla3NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4NDEzNzIsImV4cCI6MjA3NzQxNzM3Mn0.0i31xwry-xwy-D5iEtptxhcULj-IOkHuT5gR5O2CRmU',
    url: 'https://rfohrzjkyryksshueksq.supabase.co',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(),
    );
  }
}

