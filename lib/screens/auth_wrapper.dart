import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_clean_city_app/screens/initial_screen.dart';
import 'package:my_clean_city_app/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Handle different connection states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error occurred. Please try again.',
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.red),
              ),
            ),
          );
        }

        // If user is signed in, show HomePage
        if (snapshot.hasData) {
          return HomePage();
        }

        // If user is not signed in, show InitialScreen
        return InitialScreen();
      },
    );
  }
}
