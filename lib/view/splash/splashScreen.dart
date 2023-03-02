import 'dart:async';
import 'package:firebaseauth/view/authentication/register_user/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../helper/helper_function.dart';
import '../home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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

  @override
  void initState() {
    getUserLoggedInStatus();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              _isSignned! ? const HomeScreen() : const RegisterScreen(),
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/lottie/chat.json'),
      ),
    );
  }
}
