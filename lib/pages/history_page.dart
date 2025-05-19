import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_clean_city_app/components/history_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Align(
              child: Text(
                "Report History",
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            HistoryCard(
              address: "3 Oak street, Lagos",
              dateTime: "26-6-2028 10:00 AM",
              status: "pending",
            ),
            HistoryCard(
              address: "3 Oak street, Lagos",
              dateTime: "26-6-2028 10:00 AM",
              status: "completed",
            ),
          ],
        ),
      ),
    );
  }
}
