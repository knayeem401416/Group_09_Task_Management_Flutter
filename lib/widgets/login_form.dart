import 'package:flutter/material.dart';
import 'package:task_management/src/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management/widgets/form_validator.dart';
import '../screens/task_list_screen.dart';

class LogInForm extends StatefulWidget {
  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildInputForm(
              'Email', false, emailController, FormValidator.validateEmail),
          buildInputForm('Password', true, passwordController,
              FormValidator.validatePassword),
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.08,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: kPrimaryColor,
            ),
            child: TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  print(
                      "Email: ${emailController.text.trim()}, Password: ${passwordController.text.trim()}");
                  try {
                    UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TaskListScreen(
                                userId: userCredential.user!.uid)));
                    print("User logged in: ${userCredential.user?.uid}");
                  } catch (e) {
                    if (e is FirebaseAuthException) {
                      showLoginError(e, context);
                    }
                  }
                }
              },
              child: Text(
                'Log In',
                style: textButton.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildInputForm(String label, bool isPassword,
      TextEditingController controller, String? Function(String?) validator) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: kTextFieldColor),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: kPrimaryColor,
                  ),
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  void showLoginError(FirebaseAuthException e, BuildContext context) {
    String errorMessage = 'Login failed. Please try again.';
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password provided for that user.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      default:
        errorMessage = e.message ?? errorMessage;
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}
