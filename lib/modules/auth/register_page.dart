import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rablo_chat/modules/auth/login_page.dart';
import 'package:rablo_chat/modules/home/home_page.dart';
import 'package:rablo_chat/services/auth_services.dart';
import 'package:rablo_chat/widgets/custom_button.dart';
import 'package:rablo_chat/widgets/custom_text_field.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  void register(BuildContext context) async {
    final _authservice = AuthServices();

    try {
      final usercredential = await _authservice.signUpEnP(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        mobile: phoneController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "Welcome to \nRablo Chat",
                style: TextStyle(fontSize: 56, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),

              Text("Please Register to Continue"),
              SizedBox(height: 20),
              CustomTextField(
                controller: nameController,
                hintText: "Name",
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),

              CustomTextField(
                controller: emailController,
                hintText: "Email address",
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              CustomTextField(
                controller: phoneController,
                hintText: "Mobile number",
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    autofocus: false,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text("Sign In Now"),
                  ),
                  SizedBox(width: 12),
                ],
              ),
              SizedBox(height: 200),
              CustomButton(
                buttonName: "Sign Up",
                onPressedButton: () {
                  register(context);
                },
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
