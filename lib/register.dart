import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_clean_city_app/components/my_textField.dart';
import 'package:my_clean_city_app/components/square_tile.dart';
import 'package:my_clean_city_app/login_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegesterPage extends StatefulWidget {
  final Function()? onTap;

  const RegesterPage({super.key, required this.onTap});

  @override
  State<RegesterPage> createState() => _RegesterPageState();
}

class _RegesterPageState extends State<RegesterPage> {
  // Text controllers for form fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up user method
  void signUserUp() async {
    // Validate inputs
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all fields";
      });
      return;
    }

    // Validate password match
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords don't match";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Update display name in Firebase Auth
      await userCredential.user?.updateDisplayName(nameController.text.trim());

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'displayName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'uid': userCredential.user!.uid,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration successful',
            style: GoogleFonts.poppins(fontSize: 15.sp),
          ),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'This email is already registered.';
          break;
        case 'weak-password':
          _errorMessage = 'Password is too weak.';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is not valid.';
          break;
        default:
          _errorMessage = e.message ?? 'Registration failed. Please try again.';
      }
      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Google Sign-In method
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);

        // Get display name (prefer Google-provided name, fallback to nameController)
        String displayName =
            userCredential.user?.displayName ??
            (nameController.text.trim().isNotEmpty
                ? nameController.text.trim()
                : googleUser.displayName ?? 'User');

        // Update display name in Firebase Auth if needed
        if (userCredential.user?.displayName == null ||
            userCredential.user?.displayName != displayName) {
          await userCredential.user?.updateDisplayName(displayName);
        }

        // Save user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'displayName': displayName,
          'email': userCredential.user!.email,
          'uid': userCredential.user!.uid,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google Sign-In successful',
              style: GoogleFonts.poppins(fontSize: 15.sp),
            ),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign up with Google. Please try again.';
      });
      print("Google Sign-In error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),

                // Logo
                Container(
                  height: 100.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.recycling,
                    size: 60,
                    color: Color(0xFF4CAF50),
                  ),
                ),

                SizedBox(height: 10.h),

                // App name
                Text(
                  'MyCleanCity',
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF388E3C),
                  ),
                ),

                SizedBox(height: 10.h),

                // Welcome message
                Text(
                  'Join us and help keep our city clean!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16.sp),
                ),

                SizedBox(height: 20.h),

                // Error message if any
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[900]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                if (_errorMessage != null) SizedBox(height: 15.h),

                // Name field
                MyTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                  obscureText: false,
                  prefixIcon: Icons.person,
                ),

                SizedBox(height: 10.h),

                // Email field
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  prefixIcon: Icons.email,
                ),

                SizedBox(height: 10.h),

                // Password field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  prefixIcon: Icons.lock,
                ),

                SizedBox(height: 10.h),

                // Confirm password field
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),

                SizedBox(height: 25.h),

                // Sign Up button
                _isLoading
                    ? CircularProgressIndicator(color: Color(0xFF4CAF50))
                    : Container(
                      margin: EdgeInsets.symmetric(horizontal: 25),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signUserUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            padding: EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 14,
                            ),
                          ),
                          child: Text(
                            'Sign up',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                SizedBox(height: 20.h),

                // Or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Google Sign-In button
                GestureDetector(
                  onTap: _signInWithGoogle,
                  child: SquareTile(imagePath: 'lib/images/google logo.png'),
                ),

                SizedBox(height: 15.h),

                // Already a member? Login now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Login now',
                        style: GoogleFonts.poppins(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
