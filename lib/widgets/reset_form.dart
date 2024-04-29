import 'package:flutter/material.dart';
import 'package:task_management/src/color.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetForm extends StatefulWidget {
  @override
  _ResetFormState createState() => _ResetFormState();
}

class _ResetFormState extends State<ResetForm> {
  final emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: kTextFieldColor),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor))),
              validator: (value) => value != null && !value.contains('@')
                  ? "Please enter a valid email!"
                  : null,
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    resetPassword(emailController.text.trim(), context);
                  }
                },
                child: Text('Reset Password',
                    style: textButton.copyWith(color: kWhiteColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void resetPassword(String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset email sent successfully')));
    } catch (e) {
      // Ensure the error message is accurate and useful.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error sending reset email: ${e.toString()}')));
    }
  }

  TextFormField buildPasswordTextField(
      TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(
            Icons.visibility_off),
      ),
    );
  }
}
