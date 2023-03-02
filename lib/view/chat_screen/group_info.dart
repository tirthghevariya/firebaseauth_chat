import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauth/services/database_services.dart';
import 'package:firebaseauth/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class GroupInfo extends StatefulWidget {
  GroupInfo(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.adminName})
      : super(key: key);
  String groupId;
  String groupName;
  String adminName;

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  void initState() {
    getMember();
    super.initState();
  }

  getMember() async {
    DataBaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMember(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      actions: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text('cancel'),
                        ),
                        TextButton(
                            onPressed: () {
                              DataBaseServices(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .toggleGroupJoin(
                                      widget.groupId,
                                      getName(widget.adminName),
                                      widget.groupName)
                                  .whenComplete(() {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ));
                              });
                            },
                            child: Text('Confirm'))
                      ],
                      title: Text('Exit'),
                      content: Text('Are you sure you exit the group?'),
                    );
                  },
                );
              },
              icon: Icon(Icons.exit_to_app))
        ],
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text(
          'Group info',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: primaryColor.withOpacity(
                      .25,
                    )),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20.sp,
                    backgroundColor: primaryColor,
                    child: Center(
                      child: Text(
                        widget.groupName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Group: ${getName(widget.groupName)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                        height: .1.h),
                  ),
                  subtitle: Text(
                    'Admin: ${getName(widget.adminName)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                        color: Colors.black),
                  ),
                )),
            SizedBox(
              height: 2.h,
            ),
            memberList()
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: (snapshot.data['members'] as List).length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.sp,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Center(
                        child: Text(
                            getName(
                              snapshot.data['members'][index],
                            ).substring(0, 1).toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 22.sp)),
                      ),
                    ),
                    title: Text(
                      getName(snapshot.data['members'][index]),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
                      ),
                    ),
                    subtitle: Text(
                      getId(snapshot.data['members'][index]),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('NO MEMBER'),
              );
            }
          } else {
            return Center(
              child: Text('No member'.toUpperCase()),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }
}
