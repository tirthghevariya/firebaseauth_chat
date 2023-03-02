import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauth/view/serach_page/search_page.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../helper/helper_function.dart';
import '../services/auth_services.dart';
import '../services/database_services.dart';
import '../utils/groupList.dart';
import 'authentication/login_user/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthServices authServices = AuthServices();
  String userName = "";
  String email = "";
  bool isLoading = false;
  bool isSelected = false;
  String groupName = "";
  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunction.getEmailFromSf().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunction.getUsernameFromSf().then((value) {
      setState(() {
        userName = value!;
      });
    });

    await DataBaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  Stream? groups;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      drawer: Drawer(
          child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              onTap: () {
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
                          child: const Text('cancel'),
                        ),
                        TextButton(
                            onPressed: () {
                              HelperFunction.clearLocalData();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false);
                            },
                            child: const Text('Confirm'))
                      ],
                      title: const Text('Logout'),
                      content: const Text('Are you sure to want to Logout'),
                    );
                  },
                );
              },
              leading: Icon(Icons.logout,
                  color: Theme.of(context).primaryColor, size: 21.sp),
              selected: true,
              title: Text(
                'Logout',
                style: TextStyle(fontSize: 15.sp),
              ))),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ));
            },
            icon: Icon(Icons.search),
          )
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text(
          'Groups',
          style: TextStyle(
            fontSize: 23.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
          elevation: 0,
          backgroundColor: primaryColor,
          onPressed: () {
            popUpDialog();
          },
          child: Icon(
            Icons.add,
            size: 22.sp,
          )),
    );
  }

  ListTile commonListStyle(
      {required Color primaryColor,
      icon,
      required String name,
      void Function()? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
      leading: Icon(icon, color: primaryColor, size: 21.sp),
      selected: true,
      title: Text(
        name,
        style: TextStyle(fontSize: 15.sp),
      ),
    );
  }

  groupList() {
    return StreamBuilder(
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: (snapshot.data['groups'] as List).length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupList(
                    groupName: getName(snapshot.data['groups'][reverseIndex]),
                    groupId: getId(snapshot.data['groups'][reverseIndex]),
                    userName: snapshot.data['fullName'],
                  );
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
      stream: groups,
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog();
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 50.sp,
            ),
          ),
          const Text(
            "You'v not joined any groups,tap on the add Icon to crate or also a search button from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  popUpDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              actions: [
                GestureDetector(
                    child: const Text('Cancel'),
                    onTap: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (groupName != "") {
                          setState(() {
                            isLoading = true;
                          });
                          DataBaseServices(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .creatingGroup(
                                  userName,
                                  FirebaseAuth.instance.currentUser!.uid,
                                  groupName)
                              .whenComplete(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Group Created Sucessfully.'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      }
                    },
                    child: const Text(
                      'Create',
                      style: TextStyle(),
                    ))
              ],
              title: const Text(
                'Create a group',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : Form(
                          key: formKey,
                          child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "please enter the group name";
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  groupName = value;
                                });
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide:
                                        const BorderSide(color: Colors.red)),
                              )),
                        )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
