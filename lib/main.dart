import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_clean_city_app/firebase_options.dart';
import 'package:my_clean_city_app/screens/initial_screen.dart';

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
            primaryColor: Color(0xFF4CAF50),
            scaffoldBackgroundColor: Colors.grey[100],
            textTheme: TextTheme(bodyMedium: TextStyle(fontFamily: 'Poppins')),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          home: InitialScreen(),
        );
      },
    );
  }
}
