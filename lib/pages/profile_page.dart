import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_clean_city_app/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? username;
  bool isDarkMode = false;

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

  Future<void> SignOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                children: [
                  // Profile Picture
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            // Handle profile picture change
                            _showImagePickerDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // User Name
                  Text(
                    username ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // User Email
                  Text(
                    _auth.currentUser?.email ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14.5.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 14.5.sp),
                  // Edit Profile Button
                  OutlinedButton.icon(
                    onPressed: () {
                      _showEditProfileDialog();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(fontSize: 13.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // User Stats
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
                    'Your Impact',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('12', 'Reports', Icons.report_outlined),
                      _buildStatItem('8', 'Pickups', Icons.delete_outline),
                      _buildStatItem('4', 'Recycled', Icons.recycling),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Settings Section
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
                    'Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 14.5.sp),
                  // Notification Settings
                  _buildSettingsItem(
                    'Notification Preferences',
                    Icons.notifications_outlined,
                    () {
                      _showNotificationSettingsDialog();
                    },
                  ),
                  const Divider(),
                  // Dark Mode
                  _buildSettingsToggleItem(
                    'Dark Mode',
                    Icons.dark_mode_outlined,
                    isDarkMode,
                    (value) {
                      // Handle dark mode toggle
                      setState(() {
                        isDarkMode = value;
                      });
                      // Here you would implement actual theme change
                    },
                  ),
                  const Divider(),
                  // Language
                  _buildSettingsItem('Language', Icons.language, () {
                    // Show language selection
                    _showLanguageSelectionDialog();
                  }),
                  const Divider(),
                  // Help & Support
                  _buildSettingsItem('Help & Support', Icons.help_outline, () {
                    // Navigate to help screen
                    _showHelpSupportDialog();
                  }),
                  const Divider(),
                  // Privacy Policy
                  _buildSettingsItem(
                    'Privacy Policy',
                    Icons.privacy_tip_outlined,
                    () {
                      // Show privacy policy
                      _showPrivacyPolicyDialog();
                    },
                  ),
                  const Divider(),
                  // Logout
                  _buildSettingsItem(
                    'Logout',
                    Icons.logout,
                    () {
                      _showLogoutConfirmDialog();
                    },
                    textColor: Colors.red,
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Version Info
            Center(
              child: Text(
                'MyCleanCity v1.0.0',
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // Helper method to build stat items
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Helper method to build settings items
  Widget _buildSettingsItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color textColor = Colors.black87,
    Color iconColor = Colors.black54,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14.5.sp, color: textColor),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Helper method to build settings toggle items
  Widget _buildSettingsToggleItem(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14.5.sp, color: Colors.black87),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  // Dialog for image picker
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text(
                  'Take a photo',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                onTap: () {
                  // Handle camera option
                  Navigator.pop(context);
                  // Add camera functionality here
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(
                  'Choose from gallery',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                onTap: () {
                  // Handle gallery option
                  Navigator.pop(context);
                  // Add gallery functionality here
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  // Dialog for editing profile
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(fontSize: 13.sp),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Email cannot be changed',
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
              Text(
                _auth.currentUser?.email ?? '',
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
            ),
            TextButton(
              onPressed: () {
                // Update user profile
                if (_auth.currentUser != null) {
                  _auth.currentUser!.updateDisplayName(nameController.text);
                  setState(() {
                    username = nameController.text;
                  });
                }
                Navigator.pop(context);

                // Show success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
              child: Text('SAVE', style: GoogleFonts.poppins(fontSize: 13.sp)),
            ),
          ],
        );
      },
    );
  }

  // Dialog for notification settings
  void _showNotificationSettingsDialog() {
    bool pushNotifications = true;
    bool emailNotifications = true;
    bool reminderNotifications = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Notification Preferences',
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text(
                      'Push Notifications',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    subtitle: Text(
                      'Alerts on your device',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    value: pushNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        pushNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      'Email Notifications',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    subtitle: Text(
                      'Updates sent to your email',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    value: emailNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        emailNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      'Pickup Reminders',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    subtitle: Text(
                      'Reminders before scheduled pickups',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    value: reminderNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        reminderNotifications = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Save notification preferences
                    Navigator.pop(context);

                    // Show success snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification preferences updated'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                  child: Text(
                    'SAVE',
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog for language selection
  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing: const Icon(Icons.check, color: Color(0xFF4CAF50)),
                onTap: () {
                  Navigator.pop(context);
                  // Apply language selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language set to English'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Spanish'),
                onTap: () {
                  Navigator.pop(context);
                  // Apply language selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language set to Spanish'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('French'),
                onTap: () {
                  Navigator.pop(context);
                  // Apply language selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language set to French'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }

  // Dialog for help & support
  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Help & Support',
            style: GoogleFonts.poppins(fontSize: 13.sp),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.help),
                title: Text('FAQ', style: GoogleFonts.poppins(fontSize: 13.sp)),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to FAQ screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: Text(
                  'Contact Support',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to contact support screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: Text(
                  'User Manual',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to user manual screen
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('CLOSE', style: GoogleFonts.poppins(fontSize: 13.sp)),
            ),
          ],
        );
      },
    );
  }

  // Dialog for privacy policy
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Privacy Policy for MyCleanCity',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Last Updated: May 18, 2025',
                  style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'MyCleanCity is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and disclose information about you when you use our mobile application.',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Information We Collect:\n'
                  '• Personal information such as name and email address\n'
                  '• Location data when reporting waste\n'
                  '• Device information\n'
                  '• Usage data',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'How We Use Your Information:\n'
                  '• To provide and maintain our services\n'
                  '• To notify you about changes to our app\n'
                  '• To allow participation in interactive features\n'
                  '• To provide customer support\n'
                  '• To analyze usage patterns and improve our app',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'For more information, please contact support@mycleanity.com',
                  style: GoogleFonts.poppins(fontSize: 13.sp),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('CLOSE', style: GoogleFonts.poppins(fontSize: 16.sp)),
            ),
          ],
        );
      },
    );
  }

  // Dialog for logout confirmation
  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(fontSize: 13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
            ),
            TextButton(
              onPressed: SignOut,
              child: Text(
                'LOGOUT',
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
