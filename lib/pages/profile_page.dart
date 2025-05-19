import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_clean_city_app/login_page.dart'; // Adjust import based on your project structure

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? username;
  String? photoUrl;
  bool isDarkMode = false;

  // Cloudinary configuration
  final String cloudName = 'dsojq0cm2';
  final String uploadPreset = 'ml_default';

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

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.status;
        if (status.isDenied) {
          status = await Permission.camera.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Camera permission is required.')),
            );
            return;
          }
        }
      }

      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        String? imageUrl = await _uploadImageToCloudinary(File(image.path));
        if (imageUrl != null) {
          final user = _auth.currentUser;
          if (user != null) {
            await user.updatePhotoURL(imageUrl);
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                  'photoUrl': imageUrl,
                  'displayName': username,
                  'email': user.email,
                }, SetOptions(merge: true));
            setState(() {
              photoUrl = imageUrl;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Profile picture updated successfully',
                  style: GoogleFonts.poppins(fontSize: 15.sp),
                ),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking image from $source: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture.')),
      );
    }
  }

  Future<String?> _uploadImageToCloudinary(File image) async {
    try {
      var request =
          http.MultipartRequest(
              'POST',
              Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload'),
            )
            ..fields['upload_preset'] = uploadPreset
            ..files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);

      if (response.statusCode == 200) {
        return data['secure_url'];
      } else {
        print('Cloudinary upload error: ${data['error']['message']}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image.')));
        return null;
      }
    } catch (e) {
      print('Cloudinary upload exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image.')));
      return null;
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
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child:
                            photoUrl != null
                                ? ClipOval(
                                  child: Image.network(
                                    photoUrl!,
                                    width: 100.w,
                                    height: 100.h,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
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
                          onPressed: _showImagePickerDialog,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    username ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _auth.currentUser?.email ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14.5.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 14.5.h),
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
                  SizedBox(height: 14.5.h),
                  _buildSettingsItem(
                    'Notification Preferences',
                    Icons.notifications_outlined,
                    () {
                      _showNotificationSettingsDialog();
                    },
                  ),
                  const Divider(),
                  _buildSettingsToggleItem(
                    'Dark Mode',
                    Icons.dark_mode_outlined,
                    isDarkMode,
                    (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                  ),
                  const Divider(),
                  _buildSettingsItem('Language', Icons.language, () {
                    _showLanguageSelectionDialog();
                  }),
                  const Divider(),
                  _buildSettingsItem('Help & Support', Icons.help_outline, () {
                    _showHelpSupportDialog();
                  }),
                  const Divider(),
                  _buildSettingsItem(
                    'Privacy Policy',
                    Icons.privacy_tip_outlined,
                    () {
                      _showPrivacyPolicyDialog();
                    },
                  ),
                  const Divider(),
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

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.5.r),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Profile Picture',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10.h),
                if (photoUrl != null) ...[
                  _buildOption(
                    icon: Icons.refresh,
                    label: 'Update Image',
                    onTap: () => _showImageSourcePicker(),
                  ),
                  Divider(height: 1.h, color: Colors.grey.shade300),
                ],
                _buildOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                Divider(height: 1.h, color: Colors.grey.shade300),
                _buildOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                Divider(height: 1.h, color: Colors.grey.shade300),
                _buildOption(
                  icon: Icons.cancel,
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                  color: Colors.red.shade400,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageSourcePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.5.r),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Select Image Source',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                Divider(height: 1.h, color: Colors.grey.shade300),
                _buildOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                Divider(height: 1.h, color: Colors.grey.shade300),
                _buildOption(
                  icon: Icons.cancel,
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                  color: Colors.red.shade400,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: (color ?? Color(0xFF4CAF50)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4.r,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 24.sp, color: color ?? Color(0xFF4CAF50)),
            ),
            SizedBox(width: 15.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8.r,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: TextEditingController(
                      text: _auth.currentUser?.email ?? '',
                    ),
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDialogButton(
                        label: 'Cancel',
                        color: Colors.red.shade400,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildDialogButton(
                        label: 'Save',
                        color: Color(0xFF4CAF50),
                        onTap: () async {
                          final user = _auth.currentUser;
                          if (user != null) {
                            await user.updateDisplayName(nameController.text);
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                                  'displayName': nameController.text,
                                  'email': user.email,
                                  'photoUrl': photoUrl,
                                }, SetOptions(merge: true));
                            setState(() {
                              username = nameController.text;
                            });
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4.r,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

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
                    Navigator.pop(context);
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
                    fontSize: 12.sp,
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
