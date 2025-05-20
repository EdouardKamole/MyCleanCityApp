import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestPickupScreen extends StatefulWidget {
  final bool showAppBar;
  const RequestPickupScreen({Key? key, this.showAppBar = false})
    : super(key: key);

  @override
  State<RequestPickupScreen> createState() => _RequestPickupScreenState();
}

class _RequestPickupScreenState extends State<RequestPickupScreen> {
  List<File> _images = [];
  Position? _currentPosition;
  String? _currentAddress;
  String? _additionalNotes;
  bool _isLoading = false;
  bool _submitLoading = false;
  final TextEditingController _locationController = TextEditingController();

  // Cloudinary configuration
  final String cloudName = 'dsojq0cm2';
  final String uploadPreset = 'ml_default';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _locationController.text = _currentAddress ?? '';
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only select up to 4 images.')),
      );
      return;
    }

    // Show enhanced bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              // Grabber handle
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
                'Choose Image Source',
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
                onTap: () => _pickImageFromSource(ImageSource.gallery),
              ),
              Divider(height: 1.h, color: Colors.grey.shade300),
              _buildOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () => _pickImageFromSource(ImageSource.camera),
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

  Future<void> _pickImageFromSource(ImageSource source) async {
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
                  style: GoogleFonts.poppins(fontSize: 15.sp),
                ),
              ),
            );
            return;
          }
        }
      }

      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } catch (e) {
      print('Error picking image from $source: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to pick image. Please try again.',
            style: GoogleFonts.poppins(fontSize: 15.sp),
          ),
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
        if (status.isDenied) {
          print("Location permission permanently denied");
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location permission is required.',
                style: GoogleFonts.poppins(fontSize: 15.sp),
              ),
            ),
          );
          return;
        }
      }

      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        Placemark place = placemarks[0];

        setState(() {
          _currentPosition = position;
          _currentAddress =
              '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
          _isLoading = false;
          _locationController.text = _currentAddress!;
        });
      } else {
        print("Location permission not granted");
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permission is required.',
              style: GoogleFonts.poppins(fontSize: 15.sp),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please select at least one image.',
            style: GoogleFonts.poppins(fontSize: 15.sp),
          ),
        ),
      );
      return;
    }

    setState(() {
      _submitLoading = true;
    });

    try {
      List<String> imageUrls = [];

      for (File image in _images) {
        try {
          var request =
              http.MultipartRequest(
                  'POST',
                  Uri.parse(
                    'https://api.cloudinary.com/v1_1/$cloudName/upload',
                  ),
                )
                ..fields['upload_preset'] = uploadPreset
                ..files.add(
                  await http.MultipartFile.fromPath('file', image.path),
                );

          var response = await request.send();
          var responseBody = await response.stream.bytesToString();
          var data = json.decode(responseBody);

          if (response.statusCode == 200) {
            imageUrls.add(data['secure_url']);
          } else {
            print('Cloudinary upload error: ${data['error']['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to upload image: ${data['error']['message']}',
                ),
              ),
            );
            setState(() {
              _submitLoading = false;
            });
            return;
          }
        } catch (e) {
          print('Cloudinary upload exception: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Failed to upload image. Please try again.',
                style: GoogleFonts.poppins(fontSize: 15.sp),
              ),
            ),
          );
          setState(() {
            _submitLoading = false;
          });
          return;
        }
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      CollectionReference pickupRequests = firestore.collection(
        'pickup_requests',
      );

      await pickupRequests.add({
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'address': _locationController.text,
        'imageUrls': imageUrls,
        'additionalNotes': _additionalNotes,
        'timestamp': FieldValue.serverTimestamp(),
        'status': "pending",
        'email': _auth.currentUser!.email ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Request submitted successfully!',
            style: GoogleFonts.poppins(fontSize: 15.sp),
          ),
        ),
      );

      setState(() {
        _images.clear();
        _additionalNotes = null;
      });
    } catch (e) {
      print("Error submitting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to submit request. Please try again.',
            style: GoogleFonts.poppins(fontSize: 15.sp),
          ),
        ),
      );
    } finally {
      setState(() {
        _submitLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50),
        elevation: 2,
        centerTitle: true,
        title: Text(
          "Request pickup",
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsetsDirectional.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upload Photos",
                        style: GoogleFonts.poppins(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Add photos of the waste for accurate assessment",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        height: 100.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _images.length) {
                              return InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  width: 80.w,
                                  margin: EdgeInsets.only(right: 5.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 30.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            } else {
                              return Stack(
                                children: [
                                  Container(
                                    width: 80.w,
                                    margin: EdgeInsets.only(right: 5.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
                                      image: DecorationImage(
                                        image: FileImage(_images[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2.w,
                                    right: 7.w,
                                    child: InkWell(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: EdgeInsets.all(2.w),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 14.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade400, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pickup Location",
                          style: GoogleFonts.poppins(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: "Enter pickup location",
                            hintStyle: GoogleFonts.poppins(fontSize: 12.sp),
                            prefixIcon: Icon(
                              Icons.location_pin,
                              color: Colors.green,
                            ),
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                        SizedBox(height: 8.h),
                        if (_currentAddress != null)
                          Text(
                            "Current device location: $_currentAddress",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (_isLoading)
                          Text(
                            "Getting Location...",
                            style: GoogleFonts.poppins(fontSize: 12.sp),
                          ),
                        if (_currentAddress == null && !_isLoading)
                          Text(
                            "Location not available",
                            style: GoogleFonts.poppins(fontSize: 12.sp),
                          ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Additional Notes",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "(Optional)",
                            style: GoogleFonts.poppins(fontSize: 13.5.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Add any details for the pickup crew",
                        style: GoogleFonts.poppins(
                          fontSize: 12.5.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter additional notes here...",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14.5.sp,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          _additionalNotes = value;
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: _submitLoading ? null : _submitRequest,
                  child:
                      _submitLoading
                          ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : Text("Request Pickup"),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
