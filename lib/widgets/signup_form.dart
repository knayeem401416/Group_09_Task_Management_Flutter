import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_management/src/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management/widgets/form_validator.dart';
import '../screens/task_list_screen.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  CroppedFile? imageFile;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CupertinoButton(
            onPressed: () {
              showPhotoOptions();
            },
            padding: EdgeInsets.all(0),
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  (imageFile != null) ? FileImage(File(imageFile!.path)) : null,
              child: (imageFile == null)
                  ? Icon(
                      Icons.person,
                      size: 60,
                    )
                  : null,
            ),
          ),
          SizedBox(height: 20),
          buildInputForm('First Name', false, firstNameController,
              FormValidator.validateName),
          buildInputForm('Last Name', false, lastNameController,
              FormValidator.validateName),
          buildInputForm(
              'Email', false, emailController, FormValidator.validateEmail),
          buildInputForm(
              'Phone', false, phoneController, FormValidator.validatePhone),
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
              onPressed: _submitForm,
              child: Text('Sign Up',
                  style: textButton.copyWith(color: kWhiteColor)),
            ),
          ),
        ],
      ),
    );
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: file.path);

    if (croppedImage != null) {
      setState(() {
        imageFile = croppedImage;
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Upload Profile Picture"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.gallery);
                    },
                    title: Text("Select from Gallery"),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.camera);
                    },
                    title: Text("Take a photo"),
                  ),
                ],
              ));
        });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && imageFile != null) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String imageUrl = await _uploadUserImage(userCredential.user!.uid);

        FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .set({
          'Email': emailController.text.trim(),
          'FirstName': firstNameController.text.trim(),
          'LastName': lastNameController.text.trim(),
          'PhoneNumber': phoneController.text.trim(),
          'ImageUrl': imageUrl,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TaskListScreen(userId: userCredential.user!.uid)),
        );
      } catch (e) {
        print("Failed to create user: $e");
      }
    } else {
      print("Form is not valid or image is not picked");
    }
  }

  Future<String> _uploadUserImage(String userId) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('user_images').child('$userId.jpg');
    UploadTask uploadTask = ref.putFile(File(imageFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Padding buildInputForm(String hint, bool pass,
      TextEditingController controller, String? Function(String?) validator) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          controller: controller,
          obscureText: pass ? _isObscure : false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kTextFieldColor),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor)),
            suffixIcon: pass
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: _isObscure ? kTextFieldColor : kPrimaryColor),
                  )
                : null,
          ),
          validator: validator,
        ));
  }
}
