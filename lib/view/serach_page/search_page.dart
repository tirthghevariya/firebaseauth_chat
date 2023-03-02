// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauth/helper/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/database_services.dart';
import '../chat_screen/chat_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  bool isJoined = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearch = false;
  String userName = "";
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  getCurrentUserIdAndName() async {
    await HelperFunction.getUsernameFromSf().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(9.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              color: primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          hintText: "Search groups...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                          )),
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      initialSearchMethod();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color(0xffef9a9a),
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  )
                ],
              ),
            )),
        title: Text(
          'Search',
          style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w500),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Column(
              children: [
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : groupList()
              ],
            )
          ],
        ),
      ),
    );
  }

  initialSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DataBaseServices()
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearch = true;
        });
      });
    } else {
      return 'group Cannot found';
    }
  }

  groupList() {
    return hasUserSearch
        ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: searchSnapshot!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return groupTile(
                userName,
                searchSnapshot!.docs[index]['groupId'],
                searchSnapshot!.docs[index]['groupName'],
                searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupName, String admin) async {
    await DataBaseServices(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    // function to check whether user already exists in group
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 7.w,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17.sp),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          FocusScope.of(context).unfocus();

          await DataBaseServices(uid: user?.uid)
              .toggleGroupJoin(groupId, userName, groupName);

          if (isJoined) {
            setState(() {
              isJoined = isJoined;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('"Successfully joined he group"')));
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                        groupId: groupId,
                        groupName: groupName,
                        userName: userName),
                  ));
            });
          } else {
            setState(() {
              isJoined = isJoined;
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(' You left the group $groupName')));
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Join Now",
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
