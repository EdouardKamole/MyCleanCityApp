import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_clean_city_app/pages/auth_page.dart';
import 'firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CloudinaryContext.cloudinary = Cloudinary.fromCloudName(
    cloudName: 'dsojq0cm2',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp()); // Removed const
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize screen utils
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          // Removed const here
          debugShowCheckedModeBanner: false,
          title: 'MyCleanCity',
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: Color(0xFF4CAF50), // Green 500
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF4CAF50),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF4CAF50)),
            ),
          ),
          home: AuthPage(),
        );
      },
    );
  }
}
