import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/screens/auth/services/auth_service.dart';
import 'package:youth_center/screens/auth/services/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final AuthService authService = AuthService();
    try {
      await authService.signOut();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out')));

      // Navigate back to AuthGate which will handle showing WelcomeScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'An error occurred';
        if (e is AuthException) {
          errorMessage = e.message;
        } else if (e is Exception) {
          errorMessage = e.toString();
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final userEmail = authService.getCurrentUserEmail();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (userEmail != null)
              Text(
                'Email: $userEmail',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
