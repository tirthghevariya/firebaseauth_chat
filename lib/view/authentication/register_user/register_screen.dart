import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';
import '../../../component/custom_text_field.dart';
import '../../../helper/helper_function.dart';
import '../../../services/auth_services.dart';
import '../../../utils/sizeUtils.dart';
import '../../../utils/image_utils.dart';
import '../../home_screen.dart';

import '../login_user/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> signup(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      UserCredential result = await auth.signInWithCredential(authCredential);
      User? user = result.user;

      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } // if result not null we simply call the MaterialpageRoute,
      // for go to the HomePage screen
    }
  }

  // @override
  // void dispose() {
  //   userNameController.dispose();
  //   userNameController.dispose();
  //   passwordController.dispose();
  //   reEnterPasswordController.dispose();
  //   super.dispose();
  // }

  final AuthServices _fireBase = AuthServices();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reEnterPasswordController = TextEditingController();
  bool isLoading = false;
  String password = '';
  String email = '';
  String fullName = '';
  bool obsCureText = true;
  bool isObscure = true;
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
                        'Registration',
                        style: TextStyle(
                            fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                      SizeUtils.sh1,
                      Text(
                        'Create your account now to explore',
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400),
                      ),
                      SizeUtils.sh2,
                      // userName Field
                      TextFormField(
                        controller: userNameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return "Username cannot be empty";
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            fullName = value;
                          });
                        },
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Username',
                          labelStyle: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          prefixIcon: const Icon(
                            Icons.person,
                          ),
                        ),
                      ),
                      SizeUtils.sh2,
                      // emailField
                      TextFormField(
                        controller: emailController,
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
                      // password field
                      TextFormField(
                        autocorrect: true,
                        controller: passwordController,
                        validator: (value) {
                          if (value!.length < 6) {
                            return 'Password must be at least 6 character';
                          } else {
                            return null;
                          }
                        },
                        obscureText: obsCureText,
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
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      SizeUtils.sh2,
                      //confirm password field
                      TextFormField(
                        autocorrect: true,
                        controller: reEnterPasswordController,
                        validator: (value) {
                          if (value!.length < 6) {
                            return 'Password must be at least 6 character';
                          } else if (passwordController.text !=
                              reEnterPasswordController.text) {
                            return 'The password does not match';
                          } else {
                            return null;
                          }
                        },
                        obscureText: isObscure,
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
                                isObscure = !isObscure;
                              });
                              FocusScope.of(context).unfocus();
                            },
                            child: isObscure == true
                                ? Icon(
                                    Icons.visibility_off,
                                    color: primaryColor,
                                  )
                                : Icon(Icons.visibility, color: primaryColor),
                          ),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      SizeUtils.sh2,
                      Text.rich(
                        TextSpan(
                          text: "I already have an account? ",
                          style: TextStyle(fontSize: 12.sp),
                          children: <TextSpan>[
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                text: 'Login',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline))
                          ],
                        ),
                      ),
                      SizeUtils.sh2,
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
                              register();
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 15.sp, color: Colors.white),
                            )),
                      ),
                      // SizeUtils.sh2,
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       CircleAvatar(
                      //         backgroundColor: Colors.white,
                      //         radius: 7.w,
                      //         backgroundImage:
                      //             const AssetImage(ImageUtils.phoneCall),
                      //         child: GestureDetector(
                      //           onTap: () {
                      //             Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       const PhoneLoginScreen(),
                      //                 ));
                      //           },
                      //         ),
                      //       ),
                      //       CircleAvatar(
                      //         backgroundColor: Colors.white,
                      //         radius: 7.w,
                      //         backgroundImage:
                      //             const AssetImage(ImageUtils.faceBook),
                      //         child: GestureDetector(
                      //           onTap: () {
                      //             facebookLogin();
                      //           },
                      //         ),
                      //       ),
                      //       CircleAvatar(
                      //         backgroundColor: Colors.white,
                      //         radius: 7.w,
                      //         backgroundImage:
                      //             const AssetImage(ImageUtils.google),
                      //         child: GestureDetector(
                      //           onTap: () {
                      //             signup(context);
                      //           },
                      //         ),
                      //       ) //
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                ), //
              ),
            ),
    );
  }

  facebookLogin() async {
    print("FaceBook");
    try {
      final result =
          await FacebookAuth.i.login(permissions: ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.i.getUserData();
        print(userData);
      }
    } catch (error) {
      print(error);
    }
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await _fireBase
          .registerUserWithEmailAndPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          // await HelprerFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUsernameSf(fullName);
          await HelperFunction.saveEmailSf(email);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Failed to Register',
              style: TextStyle(fontSize: 12.sp),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
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
