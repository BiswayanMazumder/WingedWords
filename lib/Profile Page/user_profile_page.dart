import 'dart:async';
import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:info_popup/info_popup.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wingedwords/HomePage/Comment_Page.dart';
import 'package:wingedwords/Payments/payment_history.dart';
import 'package:wingedwords/Profile%20Page/Edit_Profile.dart';
class User_ProfilePage extends StatefulWidget {
   User_ProfilePage({Key? key}) : super(key: key);

  @override
  State<User_ProfilePage> createState() => _User_ProfilePageState();
}

class _User_ProfilePageState extends State<User_ProfilePage> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  bool ispublic=true;
  bool coverpicuploading=false;
  String profilepicture='';
  String username='';
  bool foryou=true;
  String _country='NaN';
  List<String> tweetIDs = [];
  List<String> tweetbody=[];
  List<String> tweetphoto=[];
  List<int> tweetviews=[];
  List<Timestamp>tweetuploaddate=[];
  late Timestamp timestamp;
  List<String> wings_uploaded=[];
  Future<List<String>> fetchTweetIDs(String uid) async {
    try {
      final snapshot = await _firestore.collection('User Uploaded Tweet ID').doc(uid).get();
      if (snapshot.exists) {
        final List<dynamic> tweetIDs = snapshot.data()?['TIDs'] ?? [];
        //debugPrint('Tweet ID ${tweetIDs}');
        for(String ids in tweetIDs){
          final docsnap=await _firestore.collection('Global Tweets').doc(ids).get();
          if(docsnap.exists){
            tweetbody.add(docsnap.data()?['Tweet Message']);
            tweetviews.add(docsnap.data()?['Views']);
            tweetuploaddate.add(docsnap.data()?['Uploaded At']);
            final imageUrl = docsnap.data()?['Image URL'];
            for (dynamic timestamp in tweetuploaddate) {
              // Convert the Firestore Timestamp to a DateTime object
              DateTime uploadedAt = (timestamp as Timestamp).toDate();

              // Format the DateTime object to "EEEE, dd MMMM yyyy" format
              String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(uploadedAt);

              // Add the formatted date string to your list
              wings_uploaded.add(formattedDate);
            }
            if (imageUrl != null && imageUrl is String) {
              tweetphoto.add(imageUrl);
            } else {
              // Insert a placeholder value instead of null
              tweetphoto.add('placeholder');
            }
          }
        }
        // print('body $tweetbody');
        // print('views $tweetviews');
        // print('photos $tweetphoto');
        return List<String>.from(tweetIDs);

      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching tweet IDs: $e');
      return [];
    }
  }
  bool following=false;
  String formattedDate='';
  //String bio='';
  List<Timestamp>usercreated=[];
  Future<void>getdp()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
    if(docsnap!=null){
      setState(() {
        _country=docsnap.data()?['Location'];
        profilepicture=docsnap.data()!['Profile Pic'];
        username=docsnap.data()!['Name'];
        //bio=docsnap.data()!['Bio'];
        timestamp=(docsnap.data()!['Time Of Registration']);
      });
    //  print('timestamp created: $timestamp');
      DateTime dateTime = timestamp.toDate();

      // Format DateTime to desired format
      formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    //  print('Formatted Date: $formattedDate');
     // debugPrint('DP link profie $profilepicture, $username, ');
    }
    //timestamp = Timestamp.fromMillisecondsSinceEpoch(1620259287000);

    // Convert Timestamp to DateTime


  }
  List<String> followerIDs = [];
  List<String> followingIDs = [];
  Future<void> fetchFollowerList() async {
    try {
      final user=_auth.currentUser;
      final snapshot = await _firestore.collection('Followers').doc(user!.uid).get();
      if (snapshot.exists) {
        final followerList = List<Map<String, dynamic>>.from(snapshot.data()?['Follower'] ?? []);
        setState(() {
          // Extract user IDs from followerList and store them in followerIDs
          followerIDs = followerList.map((follower) => follower['ID']).cast<String>().toList();
        });
        // print('followers $followerIDs , follower $isfollowed');
      } else {
        setState(() {
          followerIDs = []; // Clear follower IDs if document doesn't exist
        });
      }
    } catch (e) {
      print('Error fetching follower list: $e');
    }
  }
  Future<void> fetchFollowingList() async {
    try {
      final user=_auth.currentUser;
      final snapshot = await _firestore.collection('Following').doc(user!.uid).get();
      if (snapshot.exists) {
        final followerList = List<Map<String, dynamic>>.from(snapshot.data()?['Follower'] ?? []);
        setState(() {
          // Extract user IDs from followerList and store them in followerIDs
          followingIDs = followerList.map((follower) => follower['ID']).cast<String>().toList();
        });
        //print('following list$followingIDs');
      } else {
        setState(() {
          followingIDs = []; // Clear follower IDs if document doesn't exist
        });
      }
    } catch (e) {
      print('Error fetching follower list: $e');
    }
  }
  late Timer _timer;
  void startFetching() {
    // Schedule the fetchFollowerList function to be called every two seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
     fetchFollowingList();
     fetchcoverpic();
     fetchverification();
     fetchFollowerList();
      //getdp();
    });
  }
  Future<void>getpublicstatus()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Account Status').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        ispublic=docsnap.data()?['Public Account'];
      });
    }
  }
  @override
  void initState() {
    final user = _auth.currentUser;
    super.initState();
    getdp();
    getpublicstatus();
    fetchcoverpic();
    fetchverification();
    fetchFollowerList();
    startFetching();
    fetchFollowingList();
    fetchTweetIDs(user!.uid).then((ids) {
      setState(() {
        tweetIDs = ids;
      //  print('Tweet IDs: $tweetIDs');
      });
    });
  }
  File? _pickedImage;
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }
  Future<void>uploadcoverpicture()async{
    await pickImage();
    try{
      final user=_auth.currentUser;
      if(_pickedImage!=null){
        final storageRef = FirebaseStorage.instance.ref().child('Cover Picture').child(user!.uid);
        await storageRef.putFile(_pickedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await _firestore.collection('Cover Picture').doc(user!.uid).set({
          'Cover Picture':imageUrl
        });
        setState(() {
          coverpicuploading=true;
        });
      }
    }catch(e){
      debugPrint('error in uploading $e');
    }
  }
  String? coverpiclink;
  Future<void> fetchcoverpic()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Cover Picture').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        coverpiclink=docsnap.data()?['Cover Picture'];
      });
    }
  }
  bool isverified=false;
  Future<void>fetchverification()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Verifications').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        isverified=docsnap.data()?['verified'];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final user=_auth.currentUser;
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: '1111111111',
      queryParameters: <String, String>{
        'body': Uri.encodeComponent('Connect With Me'),
      },
    );
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: user!.email,
    );
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){}, icon:const  Icon(Icons.search,color: Colors.white,)),
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>const Payment_History(),));
          }, icon:const  Icon(Icons.menu,color: Colors.white,)),
        ],
        title:const  Image(image: NetworkImage('https://firebasestorage.'
            'googleapis.com/v0/b/wingedwordsadmin.appspot.'
            'com/o/Logo%2Fwingedwords-removebg-preview.png?'
            'alt=media&token=0dedd044-cffa-40fa-8dd0-0168bb4'
            '78b39'),height: 80,width: 80,),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             Padding(
               padding: const EdgeInsets.only(right: 5,left: 5),
               child: Container(
                height: 100,
                width: double.infinity,
                 decoration: const BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.all(Radius.circular(10))
                 ),
                 child: InkWell(
                   onTap: (){
                     uploadcoverpicture();
                   },
                   child:coverpiclink!=null? Image.network(coverpiclink!,fit: BoxFit.cover,): Image.network('https://images.unsplash.com/photo-1510777554755-dd3dad598'
                       '0ab?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8f'
                       'GVufDB8fHx8fA%3D%3D',fit: BoxFit.cover,),
                 )
               ),
             ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(profilepicture),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                   Column(
                    children: [
                      const Text('Stars',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,fontSize: 15),),
                      Text('${followerIDs.length}',style:const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                    ],
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                   Column(
                    children: [
                      const Text('From',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,fontSize: 15),),
                      Text(_country,style:const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                    ],
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Column(
                    children: [
                      const Text('Starred',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,fontSize: 15),),
                      Text('${followingIDs.length}',style:const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                    ],
                  ),
                  //  Column(
                  //   children: [
                  //     const Text('Member Since',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,fontSize: 15),),
                  //     Text(formattedDate,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                  //   ],
                  // )
                ],
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Row(
                    children: [
                      Text(username,style:const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),),
                      const SizedBox(
                        width: 10,
                      ),
                      ispublic?Container():const Icon(Icons.lock,size: 20,color: Colors.white,),
                      ispublic?Container():const SizedBox(
                        width: 10,
                      ),
                      isverified?const Icon(Icons.verified_user_rounded,color: Colors.blue,size: 20,):Container(),
                    ],
                  ),
                ),

              ],
            ),
             const SizedBox(
              height: 8,
            ),
             Row(

              children: [
                //   Padding(
                //   padding:const  EdgeInsets.only(left: 30.0),
                //   child: Text(bio,style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,fontSize: 12),),
                // ),
                 const SizedBox(
                  width: 40,
                ),
                InkWell(
                  onTap: (){
                    launchUrl(emailLaunchUri);
                  },
                  child:const Icon(Icons.email_outlined,color: Colors.white,size: 18,),
                ),
               isverified?Container():const SizedBox(
                  width: 40,
                ),
                isverified?Container():InkWell(
                  onTap: ()async{
                    //launchUrl(emailLaunchUri);
                    followerIDs.length>0?
                        await _firestore.collection('Verifications').doc(user!.uid).set(
                            {
                              'verified':false
                            })
                        :ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Sorry, your stars count should be greater than 0 to apply for verification',
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: Icon(Icons.verified,color: followerIDs.length>0?Colors.green:Colors.red,size: 18,),
                ),
                const SizedBox(
                  width: 40,
                ),
                InkWell(
                  onTap: ()async{
                    setState(() {
                      ispublic=!ispublic;

                    });
                    await _firestore.collection('Account Status').doc(user!.uid).set(
                        {
                          'Public Account':ispublic
                        });
                    debugPrint('public status $ispublic');
                  },
                  child: Icon(ispublic?Icons.public:Icons.public_off,color: Colors.white,size: 18,),
                )
                // InkWell(
                //   onTap: (){
                //     launchUrl(smsLaunchUri);
                //   },
                //   child:const Icon(Icons.phone_android_rounded,color: Colors.white,size: 18,),
                // )
              ],
            ),
            const SizedBox(
              height: 50,
            ),
           Container(
              height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
              child: ListView.builder(
                itemCount: tweetIDs.length,
                itemBuilder: (context, index) {
                  return  InkWell(
                    onTap: (){
                      print(index);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Comment_Page(
                          owner: username,
                          image_link: tweetphoto[index],
                          owner_photo: profilepicture,
                          uid: user!.uid,
                          wings_body: tweetbody[index],
                          wings_id: tweetIDs[index],
                          wings_date: wings_uploaded[index]
                      ),));
                    },
                    child: Column(

                      children: [
                        Padding(
                          padding:const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage(profilepicture),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                                Text(username,style:const TextStyle(color: Colors.white,fontSize:15 ,fontWeight: FontWeight.bold),),
                              const  SizedBox(
                                width: 10,
                              ),
                              // const Spacer(),
                              // InkWell(
                              //   onTap: (){
                              //     showDialog(context: context, builder:(context) {
                              //       return  Container(
                              //         color: Colors.black.withOpacity(0.5), // Adjust opacity for the blur effect
                              //         constraints: BoxConstraints.expand(),
                              //         child: AlertDialog(
                              //           shadowColor: Colors.grey,
                              //           scrollable: true,
                              //           //elevation: 20,
                              //           backgroundColor: Colors.white,
                              //           title: const Center(
                              //             child: Text('More Options',style: TextStyle(
                              //               fontWeight: FontWeight.bold,
                              //               fontSize: 18
                              //             ),),
                              //           ),
                              //           actions: [
                              //             Center(
                              //               child: Column(
                              //                 children: [
                              //                   InkWell(
                              //                      onTap: (){},
                              //                     child:const Text('Edit Wings',style: TextStyle(
                              //                       color: Colors.black,
                              //                       fontSize: 15
                              //                     ),) ,
                              //                   ),
                              //                   InkWell(
                              //                     onTap: (){},
                              //                     child:const Text('\nSee Wings Details',style: TextStyle(
                              //                         color: Colors.black,
                              //                         fontSize: 15
                              //                     ),) ,
                              //                   ),
                              //                   InkWell(
                              //                     onTap: (){
                              //                       debugPrint('$index');
                              //                     },
                              //                     child:const Text('\nDelete Wings',style: TextStyle(
                              //                         color: Colors.red,
                              //                         fontWeight: FontWeight.bold,
                              //                         fontSize: 15
                              //                     ),) ,
                              //                   )
                              //                 ],
                              //               ),
                              //             )
                              //           ],
                              //         ),
                              //       );
                              //     }, );
                              //   },
                              //   child: const Icon(Icons.more_vert,color: Colors.white,),
                              // )
                              //Text('@$username',style: const TextStyle(color: Colors.grey,fontSize: 8,fontWeight: FontWeight.w300),),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(tweetbody[index],style:const TextStyle(color: Colors.white,fontWeight: FontWeight.w300,
                                fontSize: 12
                            ),),
                          ),
                        ),
                        const SizedBox(
                          height:20,
                        ),
                        if(tweetphoto[index]!='placeholder')
                          InkWell(
                            onTap: (){
                              print(index);
                              final imageProvider = Image.network(tweetphoto[index]).image;
                              showImageViewer(context, imageProvider,
                                doubleTapZoomable: true,
                                closeButtonColor: Colors.black,
                                swipeDismissible: true,
                                immersive: true,
                              );
                            },
                            child: Image.network(tweetphoto[index]),
                          ),
                        const SizedBox(
                          height:50,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height:50,
            ),
          ],
        ),
      ),
    );
  }
}
