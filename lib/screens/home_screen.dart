import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_clean_city_app/screens/history_screen.dart';
import 'package:my_clean_city_app/screens/profile_screen.dart';
import 'package:my_clean_city_app/screens/request_pickup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of widgets for each tab
  final List<Widget> _screens = [
    const HomeContent(), // Separate widget for home content
    const HistoryPage(),
    const RequestPickupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 35),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 35),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recycling, size: 35),
            label: 'Request',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Separate widget for Home content
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? username;
  String? photoUrl;
  bool _isActivityVisible = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isActivityVisible = true;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          iconSize: 40.sp,
          padding: EdgeInsets.all(4.w),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          icon: CircleAvatar(
            radius: 80.r,
            backgroundColor: Colors.grey[200],
            child:
                photoUrl != null
                    ? ClipOval(
                      child: Image.network(
                        photoUrl!,
                        width: 240.w,
                        height: 240.h,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 70.sp,
                              color: Color(0xFF4CAF50),
                            ),
                      ),
                    )
                    : Icon(Icons.person, size: 60.sp, color: Color(0xFF4CAF50)),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 25.sp,
            ),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${username ?? "User"}!',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Help keep our city clean! Use the Request tab to schedule a pickup.',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              // Logo and Request Pickup Button Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.eco, size: 100.sp, color: Color(0xFF4CAF50)),
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
                        backgroundColor: Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Request Pickup',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              // Recent Activity Section
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('pickup_requests')
                        .where('email', isEqualTo: _auth.currentUser?.email)
                        .orderBy('timestamp', descending: true)
                        .limit(2)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error loading activities',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.red,
                      ),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'No recent activity. Request a pickup to get started!',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Column(
                    children: List.generate(docs.length, (index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final timestamp =
                          (data['timestamp'] as Timestamp?)?.toDate();
                      final status = data['status']?.toString() ?? 'Pending';
                      final time =
                          timestamp != null
                              ? '${timestamp.day}/${timestamp.month}/${timestamp.year}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                              : 'Unknown';
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AnimatedOpacity(
                          opacity: _isActivityVisible ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 300 + index * 100),
                          child: _buildActivityCard(
                            'Pickup Request',
                            time,
                            Icons.delete_outline,
                            status,
                            status.toLowerCase() == 'completed'
                                ? Colors.green.shade100
                                : Colors.amber.shade100,
                            status.toLowerCase() == 'completed'
                                ? Colors.green.shade700
                                : Colors.amber.shade800,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50).withOpacity(0.1), Colors.grey[100]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Color(0xFF4CAF50), size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: statusTextColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                color: statusTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
