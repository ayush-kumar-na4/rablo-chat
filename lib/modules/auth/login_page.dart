import 'package:flutter/material.dart';
import 'package:rablo_chat/modules/auth/register_page.dart';
import 'package:rablo_chat/modules/home/home_page.dart';
import 'package:rablo_chat/services/auth_services.dart';
import 'package:rablo_chat/widgets/custom_button.dart';
import 'package:rablo_chat/widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login(BuildContext context) async {
    final authServce = AuthServices();

    try {
      await authServce.signInEnP(emailController.text, passwordController.text);
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "Welcome to \nRablo Chat",
                style: TextStyle(fontSize: 56, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text("Please Login to Continue"),
              SizedBox(height: 80),
              CustomTextField(
                controller: emailController,
                hintText: "Email address",
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 30),
              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Didn't have any account?"),
                  TextButton(
                    autofocus: false,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text("Register Now"),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 250),
              CustomButton(
                buttonName: "Sign In",
                onPressedButton: () {
                  login(context);
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
