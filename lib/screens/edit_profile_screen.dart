import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:task_management/screens/profile_screen.dart';

import '../src/color.dart';
import '../src/image.dart';

class EditProfile extends StatefulWidget {
  final String userId;

  EditProfile({required this.userId});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isPasswordVisible = false;
  String? _imageUrl;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File image = File(pickedFile.path);

      final Reference storageReference = FirebaseStorage.instance.ref().child(
          'profile_pictures/${DateTime.now().millisecondsSinceEpoch.toString()}');
      final UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.whenComplete(() => print('Image uploaded'));

      final imageUrl = await storageReference.getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
      });
    } else {
      print('No image selected.');
    }
  }

  void updateProfile() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      await signInWithEmailAndPassword(email, password);

      Map<String, dynamic> newData = {
        if (_firstNameController.text.isNotEmpty)
          'FirstName': _firstNameController.text,
        if (_lastNameController.text.isNotEmpty)
          'LastName': _lastNameController.text,
        if (_emailController.text.isNotEmpty) 'Email': _emailController.text,
        if (_phoneNumberController.text.isNotEmpty)
          'PhoneNumber': _phoneNumberController.text,
        if (_passwordController.text.isNotEmpty)
          'Password': _passwordController.text,
        if (_imageUrl != null) 'ProfilePicture': _imageUrl,
      };

      FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .update(newData);
      print('Profile updated successfully');
      _clearForm();
    } catch (error) {
      print('Failed to update profile: $error');
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
    _passwordController.clear();
    setState(() {
      _imageUrl = null;
    });
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User registration successful: ${userCredential.user!.uid}');
    } catch (e) {
      print('Failed to register user: $e');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User sign-in successful: ${userCredential.user!.uid}');
    } catch (e) {
      print('Failed to sign in user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => Profile(userId: widget.userId)),
            );
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Stack(
                children: [
                  if (_imageUrl != null)
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(_imageUrl!),
                        backgroundColor: primaryColor,
                        maxRadius: 50,
                      ),
                    ),
                  const SizedBox(
                    width: 120,
                    height: 120,
                    child: CircleAvatar(
                      backgroundImage: AssetImage(profilePic),
                      backgroundColor: primaryColor,
                      maxRadius: 50,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blueGrey.withOpacity(0.8),
                      ),
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(
                          LineAwesomeIcons.camera,
                          size: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(LineAwesomeIcons.user),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(LineAwesomeIcons.user),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(LineAwesomeIcons.envelope),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(LineAwesomeIcons.phone),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(LineAwesomeIcons.fingerprint),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 65,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    updateProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LineAwesomeIcons.user_check,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Done',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
