import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  void _getUserName() {
    final user = _auth.currentUser;
    if (user != null) {
      // Extract name from email or use displayName if available
      setState(() {
        username = user.displayName ?? user.email?.split('@')[0] ?? 'User';
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
        // title: Text(
        //   'MyCleanCity',
        //   style: GoogleFonts.poppins(
        //     color: Colors.white,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              "https://avatar.iran.liara.run/public/21",
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
      // drawer: _buildDrawer(),
      body: _buildBody(),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
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

  // Widget _buildDrawer() {
  //   return Drawer(
  //     child: ListView(
  //       padding: EdgeInsets.zero,
  //       children: <Widget>[
  //         DrawerHeader(
  //           decoration: const BoxDecoration(color: Color(0xFF4CAF50)),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const CircleAvatar(
  //                 radius: 32,
  //                 backgroundColor: Colors.white70,
  //                 child: Icon(Icons.person, size: 40, color: Color(0xFF4CAF50)),
  //               ),
  //               SizedBox(height: 10.h),
  //               Text(
  //                 'Welcome, ${username ?? "User"}',
  //                 style: GoogleFonts.poppins(
  //                   color: Colors.white,
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               Text(
  //                 _auth.currentUser?.email ?? '',
  //                 style: GoogleFonts.poppins(
  //                   color: Colors.white70,
  //                   fontSize: 14.sp,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.map),
  //           title: const Text('Waste Map'),
  //           onTap: () {
  //             // Navigate to waste map
  //             Navigator.pop(context);
  //           },
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.history),
  //           title: const Text('Report History'),
  //           onTap: () {
  //             // Navigate to report history
  //             Navigator.pop(context);
  //           },
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.settings),
  //           title: const Text('Settings'),
  //           onTap: () {
  //             // Navigate to settings screen
  //             Navigator.pop(context);
  //           },
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.help_outline),
  //           title: const Text('Help & Support'),
  //           onTap: () {
  //             // Navigate to help screen
  //             Navigator.pop(context);
  //           },
  //         ),
  //         const Divider(),
  //         ListTile(
  //           leading: const Icon(Icons.logout),
  //           title: const Text('Logout'),
  //           onTap: () {
  //             _auth.signOut();
  //             Navigator.pop(context);
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildHomeContent();
    } else if (_selectedIndex == 1) {
      return _buildProfileContent();
    } else {
      return _buildHistoryContent();
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

  Widget _buildProfileContent() {
    // Placeholder for Profile tab
    return const Center(
      child: Text(
        'Profile section coming soon',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildHistoryContent() {
    // Placeholder for History tab
    return const Center(
      child: Text(
        'History section coming soon',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
