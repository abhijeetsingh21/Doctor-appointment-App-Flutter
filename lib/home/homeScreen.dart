// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_appointment/Models/userModel.dart';
import 'package:doctors_appointment/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String searchValue = '';
  TextStyle _style = TextStyle(color: Colors.white);
  Paint paint = Paint();
  String userName = '';
  String email = '';
  String userImage = '';

  Future<String> emailGetter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
    });

    return email;
  }

  Future<UserModel> getUser(String email) async {
    final snapshot = await _firebaseFirestore
        .collection('user')
        .where('email', isEqualTo: email)
        .get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;
    userName = userData.name;
    userImage = userData.img;
    print(userName);
    return userData;
  }

  @override
  void initState() {
    // TODO: implement initState
    emailGetter();
    getUser(email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 204, 226, 223),
        gapLocation: GapLocation.none,
        activeIndex: 0,
        icons: [Icons.home, Icons.person, Icons.phone],
        onTap: (idx) {},
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 35, left: 12, right: 12, bottom: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: getUser(email),
                      builder: (context, snapshot) {
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: userImage == ''
                                    ? CircularProgressIndicator()
                                    : GestureDetector(
                                        onTap: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          FirebaseAuth.instance.signOut();
                                          prefs.setBool('loginState', false);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          fit: BoxFit.cover,
                                          height: double.infinity,
                                          width:  double.infinity,
                                          userImage,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: 17),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome Back,'),
                                Text(
                                  userName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              color: Colors.black87,
                              onPressed: () {},
                              icon: Icon(CupertinoIcons.chat_bubble),
                              // visualDensity: VisualDensity(horizontal: 10),
                            ),
                            // SizedBox(width: 5),
                            IconButton(
                                color: Colors.black87,
                                onPressed: () {},
                                icon: Icon(CupertinoIcons.heart)),
                            IconButton(
                                color: Colors.black87,
                                onPressed: () {},
                                icon: Icon(Icons.notification_add_outlined)),
                          ],
                        );
                      }),
                  SizedBox(height: 10),
                  SearchAnchor(
                    dividerColor: Colors.white,
                    viewSurfaceTintColor: Colors.white,
                    viewBackgroundColor: Colors.white,
                    builder:
                        (BuildContext context, SearchController controller) {
                      return SearchBar(
                        controller: controller,
                        // backgroundColor:,
                        leading: const Icon(Icons.search),
                      );
                    },
                    suggestionsBuilder:
                        (BuildContext context, SearchController controller) {
                      return List<ListTile>.generate(5, (int index) {
                        final String item = 'item $index';
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            setState(
                              () {
                                controller.closeView(item);
                              },
                            );
                          },
                        );
                      });
                    },
                  ),
                  SizedBox(height: 15.0),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(color: Colors.black12)),
                    child: Row(
                      children: [
                        Text(
                          'We will assign quick \nand best doctor',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color.alphaBlend(
                                    Color.fromARGB(255, 12, 33, 190),
                                    Colors.red)),
                            onPressed: () {
                              Navigator.pushNamed(context, '/quickConsult',
                                  arguments: 'all');
                            },
                            child: Text(
                              'Quick Consult',
                              style: _style,
                            ))
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, '/ParticularDoctor',
                            arguments: QuickConsultParticularScreenArguments(
                                img:
                                    'https://images.hindustantimes.com/rf/image_size_640x362/HT/p2/2016/07/01/Pictures/_04695dbe-3f6d-11e6-86cd-639e2418d1d4.jpg',
                                name: 'Rawnak',
                                type: 'General',
                                workAt: 'AIIMS')),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: 120,
                          width: size.width * 0.28,
                          decoration: BoxDecoration(
                              // color: Colors.black12,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(color: Colors.black12)),
                          child: Column(
                            children: [
                              Container(
                                height: 75,
                                width: 75,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                      fit: BoxFit.cover,
                                      'https://images.rawpixel.com/image_800/czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvdjg2OC1zYXNpLTA2LmpwZw.jpg'),
                                ),
                              ),
                              SizedBox(height: 7),
                              Text('Doctor'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/LabTest'),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: 120,
                          width: size.width * 0.28,
                          decoration: BoxDecoration(
                              // color: Colors.black12,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(color: Colors.black12)),
                          child: Column(
                            children: [
                              Container(
                                height: 75,
                                width: 75,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                      fit: BoxFit.cover,
                                      'https://www.shutterstock.com/image-photo/doctor-hand-taking-blood-sample-600nw-1114244621.jpg'),
                                ),
                              ),
                              SizedBox(height: 7),
                              Text('Lab Test'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Container(
                        padding: EdgeInsets.all(8),
                        height: 120,
                        width: size.width * 0.28,
                        decoration: BoxDecoration(
                            // color: Colors.black12,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(color: Colors.black12)),
                        child: Column(
                          children: [
                            Container(
                              height: 75,
                              width: 75,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                    fit: BoxFit.cover,
                                    'https://media.istockphoto.com/id/1300036753/photo/falling-antibiotics-healthcare-background.jpg?s=612x612&w=0&k=20&c=oquxJiLqE33ePw2qML9UtKJgyYUqjkLFwxT84Pr-WPk='),
                              ),
                            ),
                            SizedBox(height: 7),
                            Text('Medicine'),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.0),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black38)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                                'https://www.shutterstock.com/image-vector/young-nurse-pointing-index-finger-600nw-112271837.jpg'),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              'Dr. palmanicham ',
                              style: _style,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Gastrologist',
                              style: _style,
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'Today 6:00 AM',
                              style: _style,
                            ),
                          ],
                        ),
                        Spacer(),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.video_call),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Doctor Specialty',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1000),
                                  border: Border.all(color: Colors.blue)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvsYpK4tvigZPthCgY28501f5QyOIKnBQs8rSgyt3dog&s')),
                            ),
                            SizedBox(height: 5.0),
                            Text('ortho'),
                          ],
                        ),
                        SizedBox(width: 10.0),
                        SpecialityIcon(),
                        SizedBox(width: 10.0),
                        SpecialityIcon(),
                        SizedBox(width: 10.0),
                        SpecialityIcon(),
                        SizedBox(width: 10.0),
                        SpecialityIcon(),
                        SizedBox(width: 10.0),
                        SpecialityIcon(),
                        SizedBox(width: 10.0),
                        SpecialityIcon(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Top Doctors',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black38)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                                'https://st2.depositphotos.com/2931363/6569/i/450/depositphotos_65699901-stock-photo-black-man-keeping-arms-crossed.jpg'),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              'Dr. Praveen ',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Neurologist',
                            ),
                          ],
                        ),
                        Spacer(),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(CupertinoIcons.heart),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black38)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                                'https://st2.depositphotos.com/2931363/6569/i/450/depositphotos_65699901-stock-photo-black-man-keeping-arms-crossed.jpg'),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              'Dr. Praveen ',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Neurologist',
                            ),
                          ],
                        ),
                        Spacer(),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(CupertinoIcons.heart),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SpecialityIcon extends StatelessWidget {
  const SpecialityIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            // border: Border.all(color: Colors.blue),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSVhdOXcjMSjxD29zT8lIHHnAV3uUBnwuvp_aNJaQ_qQA&s')),
        ),
        SizedBox(height: 5.0),
        Text('neuro'),
      ],
    );
  }
}