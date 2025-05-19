import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_clean_city_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define onboarding slides
  final List<Map<String, String>> _slides = [
    {
      'title': 'Welcome to MyCleanCity',
      'description': 'Join us in making our city cleaner and greener!',
      'image': 'assets/images/kampala.jpg',
    },
    {
      'title': 'Request Pickups',
      'description': 'Easily schedule trash pickups with a few taps.',
      'image': 'assets/images/city_trash.jpg',
    },
    {
      'title': 'Track Your Impact',
      'description': 'View your pickup history and contributions.',
      'image': 'assets/images/pickup_truck.jpg',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Save onboarding completion
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 10.h,
                  ),
                  backgroundColor: Colors.grey.shade100.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // PageView for slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image with decoration
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.asset(
                            _slides[index]['image']!,
                            height: 300.h, // Increased from 250.h
                            width: 300.w, // Increased from 200.w
                            fit:
                                BoxFit
                                    .cover, // Changed to cover for better scaling
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 300.h,
                                  width: 300.w,
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 100.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25.h), // Increased spacing
                      // Title with shadow
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          _slides[index]['title']!,
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp, // Increased from 22.sp
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 15.h), // Increased spacing
                      // Description with subtle shadow
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Text(
                          _slides[index]['description']!,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp, // Increased from 16.sp
                            color: Colors.grey.shade700, // More contrast
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Page indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: _slides.length,
              effect: ExpandingDotsEffect(
                activeDotColor: Color(0xFF4CAF50),
                dotColor: Colors.grey.shade300,
                dotHeight: 10.h, // Slightly larger
                dotWidth: 10.w,
                expansionFactor: 3,
              ),
            ),
            SizedBox(height: 25.h),
            // Next/Get Started button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == _slides.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 4, // Added elevation
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: Text(
                  _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
