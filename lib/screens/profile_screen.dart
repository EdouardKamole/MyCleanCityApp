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
import 'package:my_clean_city_app/screens/login_screen.dart'; // Adjust import

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? username;
  String? photoUrl;
  bool _isContentVisible = false;

  // Cloudinary configuration
  final String cloudName = 'dsojq0cm2';
  final String uploadPreset = 'ml_default';

  @override
  void initState() {
    super.initState();
    _getUserData();
    // Trigger animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isContentVisible = true;
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

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.status;
        if (status.isDenied) {
          status = await Permission.camera.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Camera permission is required.',
                  style: GoogleFonts.poppins(fontSize: 14.sp),
                ),
              ),
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
                  style: GoogleFonts.poppins(fontSize: 14.sp),
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
        SnackBar(
          content: Text(
            'Failed to update profile picture.',
            style: GoogleFonts.poppins(fontSize: 14.sp),
          ),
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to upload image.',
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
          ),
        );
        return null;
      }
    } catch (e) {
      print('Cloudinary upload exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload image.',
            style: GoogleFonts.poppins(fontSize: 14.sp),
          ),
        ),
      );
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
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
        iconTheme: IconThemeData(color: Colors.white, size: 24.sp),
      ),
      body: _buildProfileContent(),
    );
  }

  // Inside _buildProfileContent
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section (unchanged)
            AnimatedOpacity(
              opacity: _isContentVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Container(
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
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: CircleAvatar(
                            radius: 60.r,
                            backgroundColor: Colors.grey[200],
                            child:
                                photoUrl != null
                                    ? ClipOval(
                                      child: Image.network(
                                        photoUrl!,
                                        width: 120.w,
                                        height: 120.h,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  Icons.person,
                                                  size: 80.sp,
                                                  color: Color(0xFF4CAF50),
                                                ),
                                      ),
                                    )
                                    : Icon(
                                      Icons.person,
                                      size: 80.sp,
                                      color: Color(0xFF4CAF50),
                                    ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24.sp,
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _auth.currentUser?.email ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    OutlinedButton.icon(
                      onPressed: _showEditProfileDialog,
                      icon: Icon(
                        Icons.edit,
                        size: 20.sp,
                        color: Color(0xFF4CAF50),
                      ),
                      label: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF4CAF50), width: 2),
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            // Your Impact Section (updated)
            AnimatedOpacity(
              opacity: _isContentVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 400),
              child: Container(
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
                      'Your Impact',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
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
                              .where(
                                'email',
                                isEqualTo: _auth.currentUser?.email,
                              )
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4CAF50),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Error loading impact stats',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.red,
                            ),
                          );
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return Column(
                            children: [
                              SizedBox(height: 12.h),
                              Text(
                                'No impact yet. Request a pickup to start!',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }
                        final reports = docs.length;
                        final pickups =
                            docs
                                .where(
                                  (doc) =>
                                      (doc.data()
                                              as Map<String, dynamic>)['status']
                                          ?.toString()
                                          .toLowerCase() ==
                                      'completed',
                                )
                                .length;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AnimatedOpacity(
                              opacity: _isContentVisible ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 500),
                              child: _buildStatItem(
                                reports.toString(),
                                'Reports',
                                Icons.report_outlined,
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: _isContentVisible ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 600),
                              child: _buildStatItem(
                                pickups.toString(),
                                'Pickups',
                                Icons.delete_outline,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            // Settings Section (unchanged)
            AnimatedOpacity(
              opacity: _isContentVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Container(
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
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
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
                    _buildSettingsItem(
                      'Notification Preferences',
                      Icons.notifications_outlined,
                      _showNotificationSettingsDialog,
                      iconColor: Color(0xFF4CAF50),
                    ),
                    Divider(height: 1.h, color: Colors.grey[300]),
                    _buildSettingsItem(
                      'Help & Support',
                      Icons.help_outline,
                      _showHelpSupportDialog,
                      iconColor: Color(0xFF4CAF50),
                    ),
                    Divider(height: 1.h, color: Colors.grey[300]),
                    _buildSettingsItem(
                      'Privacy Policy',
                      Icons.privacy_tip_outlined,
                      _showPrivacyPolicyDialog,
                      iconColor: Color(0xFF4CAF50),
                    ),
                    Divider(height: 1.h, color: Colors.grey[300]),
                    _buildSettingsItem(
                      'Logout',
                      Icons.logout,
                      _showLogoutConfirmDialog,
                      textColor: Colors.red,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
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

  // Updated _buildStatItem
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
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
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey[700],
          ), // Reduced from 14.sp
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: iconColor, size: 22.sp),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: textColor),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18.sp,
          color: Colors.grey[600],
        ),
        onTap: onTap,
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
            transform:
                Matrix4.identity()..scale(_isContentVisible ? 1.0 : 0.95),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10.r,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.5.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Profile Picture',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                if (photoUrl != null) ...[
                  _buildOption(
                    icon: Icons.refresh,
                    label: 'Update Image',
                    onTap: _showImageSourcePicker,
                  ),
                  Divider(height: 10.h, color: Colors.grey[300]),
                ],
                _buildOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                Divider(height: 1.h, color: Colors.grey[300]),
                _buildOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                Divider(height: 1.h, color: Colors.grey[300]),
                _buildOption(
                  icon: Icons.cancel,
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                  color: Colors.red[400],
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
            transform:
                Matrix4.identity()..scale(_isContentVisible ? 1.0 : 0.95),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10.r,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.5.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Select Image Source',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                Divider(height: 1.h, color: Colors.grey[300]),
                _buildOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                Divider(height: 1.h, color: Colors.grey[300]),
                _buildOption(
                  icon: Icons.cancel,
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                  color: Colors.red[400],
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
                gradient: LinearGradient(
                  colors: [
                    (color ?? Color(0xFF4CAF50)).withOpacity(0.1),
                    Colors.grey[100]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
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
                fontSize: 16.sp,
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
            transform:
                Matrix4.identity()..scale(_isContentVisible ? 1.0 : 0.95),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10.r,
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
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
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
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[400]!),
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
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDialogButton(
                        label: 'Cancel',
                        color: Colors.red[400]!,
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
                            SnackBar(
                              content: Text(
                                'Profile updated successfully',
                                style: GoogleFonts.poppins(fontSize: 14.sp),
                              ),
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
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
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
            return Dialog(
              backgroundColor: Colors.transparent,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform:
                    Matrix4.identity()..scale(_isContentVisible ? 1.0 : 0.95),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10.r,
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
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2.5.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Notification Preferences',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SwitchListTile(
                        title: Text(
                          'Push Notifications',
                          style: GoogleFonts.poppins(fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          'Alerts on your device',
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                        value: pushNotifications,
                        onChanged:
                            (value) =>
                                setState(() => pushNotifications = value),
                        activeColor: Color(0xFF4CAF50),
                      ),
                      SwitchListTile(
                        title: Text(
                          'Email Notifications',
                          style: GoogleFonts.poppins(fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          'Updates sent to your email',
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                        value: emailNotifications,
                        onChanged:
                            (value) =>
                                setState(() => emailNotifications = value),
                        activeColor: Color(0xFF4CAF50),
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
                        onChanged:
                            (value) =>
                                setState(() => reminderNotifications = value),
                        activeColor: Color(0xFF4CAF50),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDialogButton(
                            label: 'Cancel',
                            color: Colors.red[400]!,
                            onTap: () => Navigator.pop(context),
                          ),
                          _buildDialogButton(
                            label: 'Save',
                            color: Color(0xFF4CAF50),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Notification preferences updated',
                                    style: GoogleFonts.poppins(fontSize: 14.sp),
                                  ),
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
      },
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform:
                Matrix4.identity()..scale(_isContentVisible ? 1.0 : 0.95),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10.r,
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
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Help & Support',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    leading: Icon(
                      Icons.help,
                      color: Color(0xFF4CAF50),
                      size: 24.sp,
                    ),
                    title: Text(
                      'FAQ',
                      style: GoogleFonts.poppins(fontSize: 16.sp),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.chat,
                      color: Color(0xFF4CAF50),
                      size: 24.sp,
                    ),
                    title: Text(
                      'Contact Support',
                      style: GoogleFonts.poppins(fontSize: 16.sp),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.book,
                      color: Color(0xFF4CAF50),
                      size: 24.sp,
                    ),
                    title: Text(
                      'User Manual',
                      style: GoogleFonts.poppins(fontSize: 16.sp),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 24.h),
                  _buildDialogButton(
                    label: 'Close',
                    color: Color(0xFF4CAF50),
                    onTap: () => Navigator.pop(context),
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

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform:
                Matrix4.identity()..scale(_isContentVisible ? 1.0 : 0.95),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10.r,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 0.6.sh, // 60% of screen height
                maxWidth: 0.9.sw, // 90% of screen width
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2.5.r),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Privacy Policy',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privacy Policy for MyCleanCity',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Last Updated: May 18, 2025',
                              style: GoogleFonts.poppins(
                                fontStyle: FontStyle.italic,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'MyCleanCity is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and disclose information about you when you use our mobile application.',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Information We Collect:\n'
                              '• Personal information such as name and email address\n'
                              '• Location data when reporting waste\n'
                              '• Device information\n'
                              '• Usage data',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'How We Use Your Information:\n'
                              '• To provide and maintain our services\n'
                              '• To notify you about changes to our app\n'
                              '• To allow participation in interactive features\n'
                              '• To provide customer support\n'
                              '• To analyze usage patterns and improve our app',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'For more information, please contact support@mycleanity.com',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: _buildDialogButton(
                      label: 'Close',
                      color: Color(0xFF4CAF50),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform:
                Matrix4.identity()..scale(_isContentVisible ? 1.0 : 0.95),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10.r,
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
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Are you sure you want to logout?',
                    style: GoogleFonts.poppins(fontSize: 14.sp, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDialogButton(
                        label: 'Cancel',
                        color: Colors.red[400]!,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildDialogButton(
                        label: 'Logout',
                        color: Color(0xFF4CAF50),
                        onTap: () {
                          Navigator.pop(context);
                          SignOut();
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
}
