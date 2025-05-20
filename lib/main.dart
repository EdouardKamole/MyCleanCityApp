import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_clean_city_app/firebase_options.dart';
import 'package:my_clean_city_app/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  CloudinaryContext.cloudinary = Cloudinary.fromCloudName(
    cloudName: 'dsojq0cm2',
  );
  runApp(MyCleanCityApp());
}

class MyCleanCityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyCleanCity',
          theme: ThemeData(
            textTheme: TextTheme(
              bodyLarge: GoogleFonts.poppins(fontSize: 15.sp),
              bodyMedium: GoogleFonts.poppins(fontSize: 13.5.sp),
            ),
            primaryColor: Color(0xFF4CAF50),
            scaffoldBackgroundColor: Colors.grey[100],
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          home: AuthWrapper(),
        );
      },
    );
  }
}
