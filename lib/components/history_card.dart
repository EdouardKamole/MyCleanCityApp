import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.address,
    required this.dateTime,
    required this.status,
  });

  final String address;
  final String dateTime;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 25),
      color: Colors.white, // White background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1.5.w),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 18, bottom: 20, right: 20, left: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                width: 23.w,
                height: 23.w,
                decoration: BoxDecoration(
                  color:
                      status == "completed"
                          ? Colors.green.shade400
                          : Colors.amber.shade500,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      status == "completed"
                          ? Icon(
                            Icons.check_circle_outline,
                            size: 18.sp,
                            color: Colors.white,
                          )
                          : Icon(
                            Icons.timer_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status == "completed" ? "Completed" : "Pending",
                    style: GoogleFonts.poppins(
                      fontSize: 14.5.sp,
                      color:
                          status == "completed"
                              ? Colors.green.shade500
                              : Colors.amber.shade500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: 150.w,
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.black87,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              dateTime,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
