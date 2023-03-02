import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseauth/helper/helper_function.dart';
import 'package:firebaseauth/view/authentication/register_user/register_screen.dart';
import 'package:firebaseauth/view/home_screen.dart';
import 'package:firebaseauth/view/splash/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    getUserLoggedInStatus();
    super.initState();
  }

  bool? _isSignned = false;

  getUserLoggedInStatus() async {
    await HelperFunction.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignned = value;
        });
      }
    });
  }

  MaterialColor mainAppColor = const MaterialColor(
    0xffF0F2F5,
    <int, Color>{
      50: Color(0xffF0F2F5),
      100: Color(0xffF0F2F5),
      200: Color(0xffF0F2F5),
      300: Color(0xffF0F2F5),
      400: Color(0xffF0F2F5),
      500: Color(0xffF0F2F5),
      600: Color(0xffF0F2F5),
      700: Color(0xffF0F2F5),
      800: Color(0xffF0F2F5),
      900: Color(0xffF0F2F5),
    },
  );

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: mainAppColor,
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
