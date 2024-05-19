import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wingedwords/HomePage/HomePage.dart';
import 'package:wingedwords/Navigation%20Button/Nav_Bar.dart';
import 'Landing Page/LandingPage.dart';
import 'firebase_options.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    FirebaseAuth _auth=FirebaseAuth.instance;
    final user=_auth.currentUser;
    return MaterialApp(
      title: 'WingedWords',
      debugShowCheckedModeBanner: false,
      home: user!=null?BottomNavBarExample():LandingPage(),
    );
  }
}
