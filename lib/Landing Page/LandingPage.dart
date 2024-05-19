import 'dart:convert';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:video_player/video_player.dart';
import 'package:wingedwords/FAQ_Page/FAQ_Page.dart';
import 'package:wingedwords/Login%20or%20signup/loginorsinguplanding.dart';
import 'package:wingedwords/Utils/Colors/Colours.dart';
import '../Navigation Button/Nav_Bar.dart';
import '../api keys/api_keys.dart';
import 'package:http/http.dart' as http;
class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}
class _LandingPageState extends State<LandingPage> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  EmailOTP myauth = EmailOTP();
  List<Offset> _dots = [];

  void _addDot(Offset position) {
    setState(() {
      _dots.add(position);
    });
    // Remove the dot after a delay
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _dots.remove(position);
      });
    });
  }
  bool isloading=false;
  void _handleSignIn() async {
    try {
      setState(() {
        isloading=true;
      });
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
        print('Username ${_googleSignIn.currentUser!.displayName}');
        print('Photo ${_googleSignIn.currentUser!.photoUrl}');
        // await _googleSignIn.signOut();
        final User? user = authResult.user;
        await _getLocation();
        if (user != null) {
          print('User UID: ${user.uid}');
          await _firestore.collection('User Details').doc(user.uid).set({
            'Name':_googleSignIn.currentUser!.displayName,
            'Email':_googleSignIn.currentUser!.email,
            'Profile Pic':_googleSignIn.currentUser!.photoUrl!=null?_googleSignIn.currentUser!.photoUrl:'https://plus.unsplash.com/premium_photo-1700268374954-f06052915608?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            'Time Of Registration':FieldValue.serverTimestamp(),
            'Location':_country,
          });
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavBarExample(),));
          setState(() {
            isloading=false;
          });
          // Now the user should appear in Firebase Authentication
        }
        // Now the user should appear in Firebase Authentication
      } else {
        // User cancelled sign-in
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  void twitterlogin()async{
    final twitterlogin=TwitterLogin(apiKey: Apikeys.Xapikey,
        apiSecretKey: Apikeys.Xapisecret,
        redirectURI: 'flutter-twitter-login://');
    await twitterlogin.login().then((value)async{
      final twitterAuthCredentials=TwitterAuthProvider.credential(accessToken: value.authToken!,
          secret: value.authTokenSecret!);
      await FirebaseAuth.instance.signInWithCredential(twitterAuthCredentials);
    });
  }
  String _country = 'Unknown';
  Future<void> _getLocation() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _country = data['country_name'] ?? 'Unknown';
        });
        debugPrint('country $_country');
      } else {
        debugPrint('Failed to get location: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    _getLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      // appBar: PreferredSize(
      //   preferredSize: const Size(double.infinity, 95),
      //   child: AppBar(
      //     backgroundColor: AppColors.greencolour,
      //     leading: Image.asset('assets/images/wingedwordslogo.png',height: 80,width: 80,),
      //     leadingWidth: 100,
      //     actions: [
      //        Padding(
      //          padding:const EdgeInsets.only(right: 20.0),
      //          child: Row(
      //           children: [
      //             InkWell(
      //               onTap:(){
      //                 Navigator.push(context, MaterialPageRoute(builder: (context) => FAQ_Page(),));
      //               },
      //               child:const Icon(CupertinoIcons.headphones,color: Colors.black,size: 30,),
      //             )
      //             //Image(image: AssetImage('assets/images/indian_flag.jpg'),height: 50,width: 50,)
      //           ],
      //          ),
      //        )
      //     ],
      //   ),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/coverphoto.jpg'),fit: BoxFit.cover)),
        child: Stack(
          children: [
             Positioned(
              left: 0,
              right: 0,
              top: 100, // adjust the top margin as needed
              child: Center(
                child:Column(
                  children: [
                     Column(
                      children: [
                        Padding(
                          padding:const EdgeInsets.only(left: 20.0,right: 20.0),
                          child: ShaderMask(shaderCallback: (Rect bounds) {
                            return  const LinearGradient(
                              colors: [Colors.white70, Colors.green,Colors.red],
                              stops: [0.0, 1.0,2.0],
                            ).createShader(bounds);
                          },
                            child:const Text(
                              "See what's happening around you right now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                          )
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0,right: 20.0,top: 20.0),
                          child: Text(
                            "A platform fostering free expression and open dialogue.",
                            style: TextStyle(
                              color: Colors.white,
                              decorationStyle: TextDecorationStyle.dotted,
                              fontWeight: FontWeight.w300,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20, // adjust the bottom margin as needed
              child: Center(
                child:Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white,width: 3),
                        ),
                        child: InkWell(
                          onTap: () {
                           isloading?():_handleSignIn();
                          },
                          child:  Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image(
                                //   image: NetworkImage(
                                //       'https://firebasestorage.googleapis.com/v0/b/wingedwordsadmin.appspot.com/o/Logo%2Fkisspng-google-logo-g-suite-chrome-5ab6e618b3b2c3.5810634915219358967361-removebg-preview.png?alt=media&token=9b037f70-1352-431e-a5e7-f3e503d6e24d'),
                                // ),
                                // SizedBox(
                                //   width: 10,
                                // ),
                                isloading?const CircularProgressIndicator(color: Colors.black,): const Text(
                                  'Continue using Google',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                    padding: const EdgeInsets.only(left: 20.0,right: 20.0),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white,width: 3),
                        ),
                        child: InkWell(
                          onTap: () {
                            twitterlogin();
                          },
                          child:  Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image(
                                //   image: NetworkImage(
                                //       'https://img.freepik.com/free-vector/new-2023-twitter-logo-x-icon-design_1017-45418.jpg?size=338&ext=jpg&ga=GA1.1.553209589.1713744000&semt=ais'),
                                // ),
                                // SizedBox(
                                //   width: 10,
                                // ),
                                Text(
                                  'Continue using X',
                                  style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'OR',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0,right: 20.0,bottom: 20.0),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Loginsignuplanding(),));
                          },
                          child: const Center(
                            child: Text(
                              'Continue Using Email',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }
}
