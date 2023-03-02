import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauth/utils/variable_utils.dart';
import 'package:firebaseauth/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../component/custom_text_field.dart';
import '../../../helper/helper_function.dart';
import '../../../services/auth_services.dart';
import '../../../services/database_services.dart';
import '../../../utils/sizeUtils.dart';
import '../forget_password/forgetScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthServices authServices = AuthServices();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String password = '';
  String email = '';
  bool obsCureText = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      body: isLoading
          ? Container(
              height: double.maxFinite,
              width: double.maxFinite,
              color: Colors.transparent,
              child: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        VariableUtils.login,
                        style: TextStyle(
                            fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                      SizeUtils.sh1,
                      Text(
                        'Login your account to explore more',
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400),
                      ),
                      SizeUtils.sh2,
                      SizeUtils.sh2,
                      TextFormField(
                        // controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value!)
                              ? null
                              : 'Please Enter a valid Email';
                        },
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Email',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.w400),
                          prefixIcon: const Icon(
                            Icons.email,
                          ),
                        ),
                      ),
                      SizeUtils.sh2,
                      TextFormField(
                        autocorrect: true,
                        // controller: passwordController,
                        validator: (value) {
                          if (value!.length < 6) {
                            return 'Password must be at least 6 character';
                          } else {
                            return null;
                          }
                        },
                        obscureText: obsCureText,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        decoration: textInputDecoration.copyWith(
                          suffixIconColor: primaryColor,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                obsCureText = !obsCureText;
                              });
                              FocusScope.of(context).unfocus();
                            },
                            child: obsCureText == true
                                ? Icon(
                                    Icons.visibility_off,
                                    color: primaryColor,
                                  )
                                : Icon(Icons.visibility, color: primaryColor),
                          ),
                          labelText: VariableUtils.password,
                          labelStyle: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgetPassWordScreen(),
                                  ),
                                );
                              },
                              child: const Text(VariableUtils.forget),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 2.0.h),
                                backgroundColor: const Color(0xff880e4f),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              login();
                            },
                            child: Text(
                              VariableUtils.login,
                              style: TextStyle(
                                  fontSize: 15.sp, color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await authServices
          .signInWithEmailAndPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot = await DataBaseServices(
                  uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserData(email);
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUsernameSf(
              snapshot.docs[0][VariableUtils.fullName]);
          await HelperFunction.saveEmailSf(email);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to Login', style: TextStyle(fontSize: 12.sp)),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            action: SnackBarAction(
                label: 'OK', onPressed: () {}, textColor: Colors.white),
          ));
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }
}
