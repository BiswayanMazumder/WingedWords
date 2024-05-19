import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:wingedwords/AI%20integration/AIVA.dart';
import 'package:wingedwords/AI%20integration/AIVA_HomePage.dart';
import 'package:wingedwords/Content%20creation%20page/tweet_page.dart';
import 'package:wingedwords/HomePage/HomePage.dart';
import 'package:wingedwords/Profile%20Page/user_profile_page.dart';
import 'package:wingedwords/Trending%20Page/trending_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating NavBar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BottomNavBarExample(),
    );
  }
}

class BottomNavBarExample extends StatefulWidget {
  @override
  _BottomNavBarExampleState createState() => _BottomNavBarExampleState();
}

class _BottomNavBarExampleState extends State<BottomNavBarExample> {
  int _index = 0;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  bool isSubscribed=false;
  Future<void>getpremiumstatus()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Premium Subscribers').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        isSubscribed=docsnap.data()?['Premium'];
      });
    }
    print('Subscribed $isSubscribed');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getpremiumstatus();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens =  [
      const HomePage(),
      const Trending_Page(),
      const Tweet_Creation(),
      const AIVA_landing(),
      User_ProfilePage(),
    ];
    return Scaffold(
      extendBody: true,
      body: _screens[_index],
      bottomNavigationBar: FloatingNavbar(
        unselectedItemColor: Colors.white,
        onTap: (int val) => setState(() => _index = val),
        currentIndex: _index,
        items: [
          FloatingNavbarItem(icon: Icons.home),
          FloatingNavbarItem(icon: Icons.trending_up_rounded),
          FloatingNavbarItem(icon:Icons.add),
          FloatingNavbarItem(icon:Icons.person_4),
          FloatingNavbarItem(icon: Icons.person),
        ],
      ),
    );
  }
}
