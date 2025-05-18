import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // Import http
import 'dart:convert';

class RequestPickupScreen extends StatefulWidget {
  const RequestPickupScreen({Key? key}) : super(key: key);

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

  // Cloudinary configuration
  final String cloudName = 'dsojq0cm2'; // Replace with your cloud name
  final String uploadPreset = 'ml_default'; // Replace with your upload preset

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 4) {
      // Optionally show a message that the limit has been reached
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only select up to 4 images.')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
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
            SnackBar(content: Text('Location permission is required.')),
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
        });
      } else {
        print("Location permission not granted");
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission is required.')),
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
    setState(() {
      _submitLoading = true;
    });

    try {
      List<String> imageUrls = [];

      // Upload images to Cloudinary
      for (File image in _images) {
        try {
          // Prepare the request
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

          // Send the request
          var response = await request.send();

          // Read the response
          var responseBody = await response.stream.bytesToString();
          var data = json.decode(responseBody);

          // Check for errors
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
              content: Text('Failed to upload image. Please try again.'),
            ),
          );
          setState(() {
            _submitLoading = false;
          });
          return;
        }
      }

      // Create a new document in Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference pickupRequests = firestore.collection(
        'pickup_requests',
      );

      await pickupRequests.add({
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'address': _currentAddress,
        'imageUrls': imageUrls,
        'additionalNotes': _additionalNotes,
        'timestamp': FieldValue.serverTimestamp(),
        'status': "pending",
        // Add other relevant data here
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted successfully!')),
      );

      // Clear the form
      setState(() {
        _images.clear();
        _additionalNotes = null;
      });
    } catch (e) {
      print("Error submitting request: $e");
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request. Please try again.')),
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
          style: GoogleFonts.poppins(fontSize: 15.sp),
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
                      // Image Selection Area
                      Container(
                        height: 100.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length + 1, // +1 for the add icon
                          itemBuilder: (context, index) {
                            if (index == _images.length) {
                              // Add icon
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
                              // Image preview
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
                        SizedBox(height: 15.h),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Current device location",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Colors.green,
                              size: 18.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _currentAddress != null
                                  ? " $_currentAddress"
                                  : _isLoading
                                  ? "Getting Location..."
                                  : "Location not available",

                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
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
                            style: GoogleFonts.poppins(fontSize: 12.5.sp),
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
                            fontSize: 12.sp,
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
                    backgroundColor: Color(0xFF4CAF50), // Match AppBar color
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
