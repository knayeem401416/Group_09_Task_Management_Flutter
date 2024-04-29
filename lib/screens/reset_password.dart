import 'package:flutter/material.dart';
import 'package:task_management/screens/login.dart';
import 'package:task_management/src/color.dart';
import 'package:task_management/widgets/reset_form.dart';

class ResetPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Less than icon
          onPressed: () {

            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LogInScreen()));
          },
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: kDefaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
            ),
            Text(
              'Reset Password',
              style: titleText,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Please enter your email address',
              style: subTitle.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 50,
            ),
            ResetForm(),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
