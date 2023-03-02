import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../view/chat_screen/chat_page.dart';

class GroupList extends StatefulWidget {
  const GroupList(
      {Key? key,
      required this.groupName,
      required this.userName,
      required this.groupId})
      : super(key: key);
  final String groupName;
  final String groupId;
  final String userName;
  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                groupName: widget.groupName,
                userName: widget.userName,
                groupId: widget.groupId,
              ),
            ));
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: ListTile(
            leading: CircleAvatar(
              radius: 6.w,
              backgroundColor: primaryColor,
              child: Text(
                widget.groupName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: Colors.white),
              ),
            ),
            subtitle: Text(
              "Join the Conversion as ${widget.groupName}",
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            title: Text(widget.groupName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
          )),
    );
  }
}
