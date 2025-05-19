import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_clean_city_app/pages/history_page.dart';
import 'package:my_clean_city_app/pages/profile_page.dart';
import 'package:my_clean_city_app/pages/request_pickup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? username;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        username = user.displayName ?? user.email?.split('@')[0] ?? 'User';
        photoUrl = user.photoURL;
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((
        doc,
      ) {
        if (doc.exists) {
          setState(() {
            photoUrl = doc.data()?['photoUrl'] ?? photoUrl;
            username = doc.data()?['displayName'] ?? username;
          });
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.all(8.0),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          icon: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child:
                photoUrl != null
                    ? ClipOval(
                      child: Image.network(
                        photoUrl!,
                        width: 200.w,
                        height: 200.h,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF4CAF50),
                            ),
                      ),
                    )
                    : const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF4CAF50),
                    ),
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 20.sp,
            ),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fire_truck),
            label: 'Request',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4CAF50),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14.sp),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return HistoryPage();
      case 2:
        return RequestPickupScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${username ?? "User"}!',
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Help make our city cleaner by reporting waste locations.',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // Request Pickup Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Green Circle with Plus Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.fire_truck_outlined,
                      size: 30,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Request a New Pickup',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Schedule a pickup for your trash easily',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestPickupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Request Pickup',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // Recent Activity Section
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityCard(
              'Recycling',
              'Today, 2:30 PM',
              Icons.recycling,
              'Completed',
              Colors.green.shade100,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildActivityCard(
              'General Waste',
              'Yesterday, 10:00 AM',
              Icons.delete_outline,
              'Pending',
              Colors.amber.shade100,
              Colors.amber.shade800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String time,
    IconData icon,
    String status,
    Color statusBgColor,
    Color statusTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey.shade700),
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                color: statusTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
