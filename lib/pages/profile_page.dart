import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                  const SizedBox(height: 16),
                  // User Name
                  Text(
                    username ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // User Email
                  Text(
                    _auth.currentUser?.email ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  // Edit Profile Button
                  OutlinedButton.icon(
                    onPressed: () {
                      _showEditProfileDialog();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
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

            const SizedBox(height: 24),

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
                  const Text(
                    'Your Impact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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

            const SizedBox(height: 24),

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
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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

            const SizedBox(height: 24),

            // Version Info
            Center(
              child: Text(
                'MyCleanCity v1.0.0',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
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
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
        style: const TextStyle(fontSize: 16, color: Colors.black87),
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
          title: const Text('Change Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  // Handle camera option
                  Navigator.pop(context);
                  // Add camera functionality here
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
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
              child: const Text('CANCEL'),
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
          title: const Text('Edit Profile'),
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
              const Text(
                'Email cannot be changed',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                _auth.currentUser?.email ?? '',
                style: const TextStyle(fontSize: 14),
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
              child: const Text('SAVE'),
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
              title: const Text('Notification Preferences'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Alerts on your device'),
                    value: pushNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        pushNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Updates sent to your email'),
                    value: emailNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        emailNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Pickup Reminders'),
                    subtitle: const Text('Reminders before scheduled pickups'),
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
                  child: const Text('CANCEL'),
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
                  child: const Text('SAVE'),
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
          title: const Text('Help & Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('FAQ'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to FAQ screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Contact Support'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to contact support screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('User Manual'),
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
              child: const Text('CLOSE'),
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
          title: const Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Privacy Policy for MyCleanCity',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Last Updated: May 18, 2025',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
                SizedBox(height: 16),
                Text(
                  'MyCleanCity is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and disclose information about you when you use our mobile application.',
                ),
                SizedBox(height: 8),
                Text(
                  'Information We Collect:\n'
                  '• Personal information such as name and email address\n'
                  '• Location data when reporting waste\n'
                  '• Device information\n'
                  '• Usage data',
                ),
                SizedBox(height: 8),
                Text(
                  'How We Use Your Information:\n'
                  '• To provide and maintain our services\n'
                  '• To notify you about changes to our app\n'
                  '• To allow participation in interactive features\n'
                  '• To provide customer support\n'
                  '• To analyze usage patterns and improve our app',
                ),
                SizedBox(height: 8),
                Text(
                  'For more information, please contact support@mycleanity.com',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CLOSE'),
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
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout
                _auth.signOut();
                Navigator.pop(context);

                // Here you might want to navigate to login screen
                // Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('LOGOUT', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
