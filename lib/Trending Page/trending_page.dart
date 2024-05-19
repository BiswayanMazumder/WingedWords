import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wingedwords/Landing%20Page/LandingPage.dart';
import 'package:wingedwords/Others%20Profile/others_profile.dart';
import 'package:wingedwords/Profile%20Page/user_profile_page.dart';
import 'package:wingedwords/Search%20Page/Search_user.dart';
import 'package:wingedwords/Trending%20Page/Trending_Music_Page.dart';
class Trending_Page extends StatefulWidget {
  const Trending_Page({Key? key}) : super(key: key);

  @override
  State<Trending_Page> createState() => _Trending_PageState();
}

class _Trending_PageState extends State<Trending_Page> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  String profilepicture='';
  Future<void>getdp()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
    if(docsnap!=null){
      setState(() {
        profilepicture=docsnap.data()!['Profile Pic'];
      });
    }
    print('DP link $profilepicture');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdp();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions:const [
          // InkWell(
          //   onTap: (){
          //     _googleSignIn.signOut();
          //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage(),));
          //   },
          //   child:const Icon(Icons.logout,color: Colors.white,),
          // ),
           SizedBox(
            width: 30,
          ),
        ],
        leading: Row(
          children: [
            const SizedBox(
              width: 5,
            ),
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(profilepicture),
              child: InkWell(
                onTap: (){
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => other_profile_page(uid: 'KriwgKUMchRYsedhxZr9vGqs7Um2',
                  //     isOwner: false),));
                },
              ),
            ),
          ],
        ),
        title:InkWell(
          onTap: (){
            Navigator.push(context,MaterialPageRoute(builder: (context) =>const SearchScreen(),));
          },
          child: Container(
            height: 35,
            width: 330,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius:const BorderRadius.all(Radius.circular(30))
            ),
            child: const Center(
              child: Text('Search WingedWords',style: TextStyle(
                color: Colors.grey,fontSize: 15,fontWeight: FontWeight.w500
              ),),
            ),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
       body:  SingleChildScrollView(
         child: Column(
           children: [
             Stack(
               children: [

                 InkWell(
                     onTap: (){
                       Navigator.push(context,MaterialPageRoute(builder: (context) => Music_Page(
                         topic: 'Sunburn Goa',
                         videourl: 'https://firebasestorage.googleapis.com/v0/b/wingedwordsadmin.appspot.com/o/Trending%20Videos%2FSunburn%20Festival%20Goa%202022%20-%20Official%204K%20Aftermovie.mp4?alt=media&token=d5f0855e-f717-4835-8d53-0594c812939a',
                       ),));
                     },
                     child:const Image(image: NetworkImage('https://wallpapercave.com/wp/wp3634263.jpg'))),
                 // Positioned widget for the text
                 const Positioned(
                   bottom: 0, // Position the text at the bottom
                   left: 0, // Align the text to the left
                   right: 0, // Align the text to the right
                   child: Padding(
                     padding: EdgeInsets.only(left: 20.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Text(
                               'Music Festival',
                               style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),
                               textAlign: TextAlign.start, // Center align the text
                             ),
                             Padding(padding: EdgeInsets.only(left: 20.0)),
                             Text(
                               'LIVE',
                               style: TextStyle(color: Colors.white,fontWeight: FontWeight.w300
                                   ,fontSize: 18),
                               textAlign: TextAlign.start, // Center align the text
                             ),
                           ],
                         ),
                         Text(
                           'Sunburn 2024',
                           style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 28),
                           textAlign: TextAlign.start, // Center align the text
                         ),
                       ],
                     ),
                   ),
                 ),
               ],
             ),
             Stack(
               children: [

                 InkWell(
                     onTap: (){
                       Navigator.push(context,MaterialPageRoute(builder: (context) => Music_Page(
                         videourl: 'https://firebasestorage.googleapis.com/v0/b/wingedwordsadmin.appspot.com/o/Trending%20Videos%2FAlan%20Walker%2C%20Sabrina%20Carpenter%20%26%20Farruko%20%20-%20On%20My%20Way.mp4?alt=media&token=5c12bac0-a5e6-4c9f-b316-d9090199b479',
                         topic: 'Alan Walker',
                       ),));
                     },
                     child:const Image(image: NetworkImage('https://assets-in.bmscdn.com/nmcms/events/banner/desktop/media-desktop-sunburn-arena-ft-alan-walker-kolkata-0-2024-4-17-t-8-25-40.jpg'))),
                 // Positioned widget for the text
                 const Positioned(
                   bottom: 0, // Position the text at the bottom
                   left: 0, // Align the text to the left
                   right: 0, // Align the text to the right
                   child: Padding(
                     padding: EdgeInsets.only(left: 20.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Text(
                               'Music Concert',
                               style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),
                               textAlign: TextAlign.start, // Center align the text
                             ),
                             Padding(padding: EdgeInsets.only(left: 20.0)),
                             Text(
                               'LIVE',
                               style: TextStyle(color: Colors.red,fontWeight: FontWeight.w300
                                   ,fontSize: 18),
                               textAlign: TextAlign.start, // Center align the text
                             ),
                           ],
                         ),
                         Text(
                           'ALAN WALKER',
                           style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 28),
                           textAlign: TextAlign.start, // Center align the text
                         ),
                       ],
                     ),
                   ),
                 ),
               ],
             ),
             Stack(
               children: [

                 InkWell(
                     onTap: (){
                       Navigator.push(context,MaterialPageRoute(builder: (context) => Music_Page(
                         topic: 'Krishna Kaul',
                         videourl: 'https://firebasestorage.googleapis.com/v0/b/wingedwordsadmin.appspot.com/o/Trending%20Videos%2Fvideoplayback.mp4?alt=media&token=5b4ebb81-6012-4728-b651-4058766b4b2f',
                       ),));
                     },
                     child:const Image(image: NetworkImage('https://assets-in.bmscdn.com/discovery-catalog/events/tr:w-400,h-600,bg-CCCCCC/et00396472-mprupwdswf-portrait.jpg'),fit: BoxFit.cover,)),
               ],
             ),
           ],
         ),
       ),
    );
  }
}
