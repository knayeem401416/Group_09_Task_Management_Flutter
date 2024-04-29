import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:task_management/screens/login.dart';
import 'package:task_management/screens/task_list_screen.dart';

import '../src/color.dart';
import '../src/image.dart';
import '../widgets/profile_screen_menu.dart';
import 'edit_profile_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  //final FirebaseStorage _storage = FirebaseStorage.instance;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phoneNumber = '';
  //String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    String userId = 'Ww3TyGV0FFKffe3ltQ3w';
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('Users').doc(userId).get();

      setState(() {
        _firstName = userSnapshot['FirstName'];
        _lastName = userSnapshot['LastName'];
        _email = userSnapshot['Email'];
        _phoneNumber = userSnapshot['PhoneNumber'];
        //_profileImageUrl = userSnapshot['ProfilePicture'];
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TaskListScreen()),
            );
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
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
              const SizedBox(height: 10),
              Text(
                '$_firstName $_lastName',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                '$_phoneNumber',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '$_email',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const EditProfile()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LineAwesomeIcons.user_edit,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: 'Settings & privacy',
                icon: LineAwesomeIcons.cog,
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: 'Security & privacy',
                icon: LineAwesomeIcons.lock,
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: 'Notification',
                icon: LineAwesomeIcons.bell,
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: 'Help & support',
                icon: LineAwesomeIcons.question,
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: 'Give feedback',
                icon: LineAwesomeIcons.comment,
                onPress: () {},
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              ProfileMenuWidget(
                title: 'Log out',
                icon: LineAwesomeIcons.alternate_sign_in,
                onPress: () async {
                  await auth.signOut();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const LogInScreen()),
                  );
                },
                endIcon: false,
                textColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
