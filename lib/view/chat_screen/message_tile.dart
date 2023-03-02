import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FirebaseString {
  static const String appointment = "Appointment";
  static const String user = "User";
  static const String messages = "Messages";
}

class MessageTile extends StatefulWidget {
  const MessageTile({
    Key? key,
    required this.message,
    required this.sender,
    required this.sentByMe,

    // required this.time,
  }) : super(key: key);
  final String message;
  final String sender;
  final bool sentByMe;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  DateTime current_date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.only(
        top: .5.w,
        bottom: .5.w,
        left: widget.sentByMe ? 0 : 2.2.h,
        right: widget.sentByMe ? 2.2.h : 0,
      ),
      child: Container(
        margin: widget.sentByMe
            ? EdgeInsets.only(left: 7.w)
            : EdgeInsets.only(right: 7.w),
        padding: EdgeInsets.fromLTRB(2.h, 1.5.w, 2.w, 1.5.w),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color(0xffD2CFC8),
                spreadRadius: 1,
                offset: Offset(0, 1),
                blurRadius: 1)
          ],
          color: widget.sentByMe ? Color(0xffD9FDD3) : Colors.white,
          borderRadius: widget.sentByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(4.w),
                  topRight: Radius.circular(4.w),
                  bottomLeft: Radius.circular(4.w),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(4.w),
                  topRight: Radius.circular(4.w),
                  bottomRight: Radius.circular(4.w),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color(0xffE542A3),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  // color: Colors.white,
                  letterSpacing: -0.5),
            ),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xff111B21),
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
