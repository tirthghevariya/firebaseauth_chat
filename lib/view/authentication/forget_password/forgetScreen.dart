import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauth/utils/variable_utils.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../component/custom_text_field.dart';
import '../../../utils/sizeUtils.dart';

class ForgetPassWordScreen extends StatefulWidget {
  const ForgetPassWordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPassWordScreen> createState() => _ForgetPassWordScreenState();
}

class _ForgetPassWordScreenState extends State<ForgetPassWordScreen> {
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String email = '';
  bool obsCureText = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password Screen'),
      ),
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
                        VariableUtils.reSet,
                        style: TextStyle(
                            fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                      SizeUtils.sh2,
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
                              resetPassword();
                              emailController.clear();
                            },
                            child: Text(
                              VariableUtils.reSet,
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

  Future resetPassword() async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text.trim());
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
                'Password reset link sent! to your register email address check your email'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        log(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.message.toString(),
            ),
          ),
        );
      }
    }
  }
}
