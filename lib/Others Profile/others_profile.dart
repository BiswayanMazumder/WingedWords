import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class other_profile_page extends StatefulWidget {
  final String uid;
  bool isOwner;
  other_profile_page({required this.uid, required this.isOwner});

  @override
  State<other_profile_page> createState() => _other_profile_pageState();
}

class _other_profile_pageState extends State<other_profile_page> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String profilepicture = '';
  String username = '';
  bool isfollowed = false;
  List<String> tweetIDs = [];
  List<String> tweetbody = [];
  List<String> tweetphoto = [];
  List<int> tweetviews = [];
  List<Timestamp> tweetuploaddate = [];
  String bio = '';
  String email = '';
  late Timestamp timestamp;
  String formattedDate = '';
  String _country='NaN';
  List<Map<String, dynamic>> followinglist = [];

  Future<List<String>> fetchTweetIDs(String uid) async {
    try {
      final snapshot = await _firestore.collection('User Uploaded Tweet ID').doc(uid).get();
      if (snapshot.exists) {
        final List<dynamic> tweetIDs = snapshot.data()?['TIDs'] ?? [];
        debugPrint('Tweet ID ${tweetIDs}');
        for (String ids in tweetIDs) {
          final docsnap = await _firestore.collection('Global Tweets').doc(ids).get();
          if (docsnap.exists) {
            tweetbody.add(docsnap.data()?['Tweet Message']);
            tweetviews.add(docsnap.data()?['Views']);
            tweetuploaddate.add(docsnap.data()?['Uploaded At']);
            final imageUrl = docsnap.data()?['Image URL'];

            if (imageUrl != null && imageUrl is String) {
              tweetphoto.add(imageUrl);
            } else {
              // Insert a placeholder value instead of null
              tweetphoto.add('placeholder');
            }
          }
        }
        debugPrint('body $tweetbody');
        debugPrint('views $tweetviews');
        debugPrint('photos $tweetphoto');
        return List<String>.from(tweetIDs);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching tweet IDs: $e');
      return [];
    }
  }
  List<String> followingIDs = [];
  List<String> followerIDs = [];
  Future<void> fetchfollowinglist() async {
    final user=_auth.currentUser;
    try {
      final snapshot = await _firestore.collection('Following').doc(user!.uid).get();
      if (snapshot.exists) {
        final followerList = List<Map<String, dynamic>>.from(snapshot.data()?['Follower'] ?? []);
        setState(() {
          // Extract user IDs from followerList and store them in followerIDs
          followingIDs = followerList.map((follower) => follower['ID']).cast<String>().toList();
        });
        for(String ids in followingIDs){
          final user=_auth.currentUser;
          if(followingIDs.contains(widget.uid)){
            setState(() {
              isfollowed=true;
            });
          }else{
            setState(() {
              isfollowed=false;
            });
          }
        }
        print('followers $followingIDs , follower $isfollowed');
      } else {
        setState(() {
          followingIDs = []; // Clear follower IDs if document doesn't exist
        });
      }
    } catch (e) {
      print('Error fetching follower list: $e');
    }
  }
  Future<void> fetchfollowerlist() async {
    final user=_auth.currentUser;
    try {
      final snapshot = await _firestore.collection('Followers').doc(widget.uid).get();
      if (snapshot.exists) {
        final followerList = List<Map<String, dynamic>>.from(snapshot.data()?['Follower'] ?? []);
        setState(() {
          // Extract user IDs from followerList and store them in followerIDs
          followerIDs = followerList.map((follower) => follower['ID']).cast<String>().toList();
        });
        print('following list $followerIDs');
      } else {
        setState(() {
          followerIDs = []; // Clear follower IDs if document doesn't exist
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
      fetchfollowinglist();
      fetchcoverpic();
      fetchverification();
      getpublicstatus();
      //getdp();
    });
  }
  bool isverified=false;
  Future<void>fetchverification()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Verifications').doc(widget.uid).get();
    if(docsnap.exists){
      setState(() {
        isverified=docsnap.data()?['verified'];
      });
    }
  }
  Future<void> getdp() async {
    final user = _auth.currentUser;
    final docsnap = await _firestore.collection('User Details').doc(widget.uid).get();
    if (docsnap != null) {
      setState(() {
        _country=docsnap.data()?['Location'];
        email = docsnap.data()?['Email'];
        profilepicture = docsnap.data()!['Profile Pic'];
        username = docsnap.data()!['Name'];
        timestamp = (docsnap.data()!['Time Of Registration']);
        //bio=docsnap.data()?['Bio'];
      });
      DateTime dateTime = timestamp.toDate();

      // Format DateTime to desired format
      formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    }
    debugPrint('DP link $profilepicture, $username');
  }
  String? coverpiclink;
  Future<void> fetchcoverpic()async{
    //final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Cover Picture').doc(widget.uid).get();
    if(docsnap.exists){
      setState(() {
        coverpiclink=docsnap.data()?['Cover Picture'];
      });
    }
  }
  bool ispublic=true;
  Future<void>getpublicstatus()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Account Status').doc(widget.uid).get();
    if(docsnap.exists){
      setState(() {
        ispublic=docsnap.data()?['Public Account'];
      });
    }
  }
  @override
  void initState() {
    super.initState();
    getpublicstatus();
    fetchfollowerlist();
    fetchcoverpic();
    fetchverification();
    startFetching();
    getdp();
    print('UID ${widget.uid}');
    fetchTweetIDs(widget.uid).then((ids) {
      setState(() {
        tweetIDs = ids;
        print('Tweet IDs: $tweetIDs');
      });
    });
    fetchfollowinglist(); // Fetch follower list when the page loads
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: '8335856470',
      queryParameters: <String, String>{
        'body': Uri.encodeComponent('Example Subject & Symbols are allowed!'),
      },
    );
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu, color: Colors.white)),
        ],
        title: const Image(
          image: NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/wingedwordsadmin.appspot.com/o/Logo%2Fwingedwords-removebg-preview.png?alt=media&token=0dedd044-cffa-40fa-8dd0-0168bb478b39'),
          height: 80,
          width: 80,
        ),
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
                    child:coverpiclink!=null? Image.network(coverpiclink!,fit: BoxFit.cover,): Image.network('https://images.unsplash.com/photo-1510777554755-dd3dad598'
                        '0ab?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8f'
                        'GVufDB8fHx8fA%3D%3D',fit: BoxFit.cover,),
                  )
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  width: 30,
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(profilepicture),
                ),
                const SizedBox(
                  width: 20, // Adjust the width to create space between CircleAvatar and text
                ),const SizedBox(
                  width: 20, // Adjust the width to create space between "Stars" and "From"
                ),
                Expanded( // Use Expanded to allow the text to take up remaining space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stars',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 15),
                      ),
                      Text(
                        '${followerIDs.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10, // Adjust the width to create space between "Stars" and "From"
                ),
                Expanded( // Use Expanded to allow the text to take up remaining space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 15),
                      ),
                      Text(
                        _country,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
              ],
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
                  Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500,fontSize: 12)),
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
            const Spacer(),
            widget.isOwner
                ? Container()
                : Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: isfollowed
                  ? InkWell(
                onTap: () async {
                  await _firestore.collection('Followers').doc(widget.uid).update({
                    'Follower': FieldValue.arrayRemove([
                      {'ID': user!.uid}
                    ])
                  });
                  await _firestore.collection('Following').doc(user!.uid).update({
                    'Follower': FieldValue.arrayRemove([
                      {'ID': widget.uid}
                    ])
                  });
                  setState(() {
                    isfollowed = !isfollowed;
                  });
                },
                child: Container(
                  height: 35,
                  width: 115,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    border: Border.all(color: Colors.grey, width: 0.3),
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: () async {
                        await _firestore.collection('Followers').doc(widget.uid).update({
                          'Follower': FieldValue.arrayRemove([
                            {'ID': user!.uid}
                          ])
                        });
                        await _firestore.collection('Following').doc(user!.uid).update({
                          'Follower': FieldValue.arrayRemove([
                            {'ID': widget.uid}
                          ])
                        });
                        setState(() {
                          isfollowed = !isfollowed;
                        });
                      },
                      child: const Text('Starred', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              )
                  : InkWell(
                onTap: () async {
                  await _firestore.collection('Followers').doc(widget.uid).set({
                    'Follower': FieldValue.arrayUnion([
                      {'ID': user!.uid}
                    ])
                  }, SetOptions(merge: true));
                  await _firestore.collection('Following').doc(user!.uid).set({
                    'Follower': FieldValue.arrayUnion([
                      {'ID': widget.uid}
                    ])
                  }, SetOptions(merge: true));
                  await _firestore.collection('Following').doc(user!.uid).set({
                    'Follower': FieldValue.arrayUnion([
                      {'ID': widget.uid}
                    ])
                  }, SetOptions(merge: true));
                  setState(() {
                    isfollowed = !isfollowed;
                  });
                },
                child: Container(
                  height: 35,
                  width: 110,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: () async {
                        await _firestore.collection('Followers').doc(widget.uid).set({
                          'Follower': FieldValue.arrayUnion([
                            {'ID': user!.uid}
                          ])
                        }, SetOptions(merge: true));
                        await _firestore.collection('Following').doc(user!.uid).set({
                          'Follower': FieldValue.arrayUnion([
                            {'ID': widget.uid}
                          ])
                        }, SetOptions(merge: true));
                        setState(() {
                          isfollowed = !isfollowed;
                        });
                      },
                      child: const Text('+ Star', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            )],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Text(
                    bio,
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 12),
                  ),
                ),
                const SizedBox(
                  width: 40,
                ),
                InkWell(
                  onTap: () {
                    launchUrl(emailLaunchUri);
                  },
                  child: const Icon(Icons.email_outlined, color: Colors.white, size: 18),
                ),
                SizedBox(
                  width: 40,
                ),
                // InkWell(
                //   onTap: () {
                //     launchUrl(smsLaunchUri);
                //   },
                //   child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 18),
                // )
              ],
            ),
            const SizedBox(
              height: 50,
            ),
           ispublic? Container(
              height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
              child: ListView.builder(
                itemCount: tweetIDs.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(profilepicture),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              username,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
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
                          child: Text(
                            tweetbody[index],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (tweetphoto[index] != 'placeholder')
                        InkWell(
                          onTap: () {
                            print(index);
                            final imageProvider = Image.network(tweetphoto[index]).image;
                            showImageViewer(
                              context,
                              imageProvider,
                              doubleTapZoomable: true,
                              closeButtonColor: Colors.black,
                              swipeDismissible: true,
                              immersive: true,
                            );
                          },
                          child: Image.network(tweetphoto[index]),
                        ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  );
                },
              ),
            ):Container(
             child:isfollowed?
             Container(
               height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
               child: ListView.builder(
                 itemCount: tweetIDs.length,
                 itemBuilder: (context, index) {
                   return Column(
                     children: [
                       Padding(
                         padding: const EdgeInsets.only(left: 20),
                         child: Row(
                           children: [
                             CircleAvatar(
                               radius: 10,
                               backgroundImage: NetworkImage(profilepicture),
                             ),
                             const SizedBox(
                               width: 10,
                             ),
                             Text(
                               username,
                               style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                             ),
                             const SizedBox(
                               width: 10,
                             ),
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
                           child: Text(
                             tweetbody[index],
                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 12),
                           ),
                         ),
                       ),
                       const SizedBox(
                         height: 20,
                       ),
                       if (tweetphoto[index] != 'placeholder')
                         InkWell(
                           onTap: () {
                             print(index);
                             final imageProvider = Image.network(tweetphoto[index]).image;
                             showImageViewer(
                               context,
                               imageProvider,
                               doubleTapZoomable: true,
                               closeButtonColor: Colors.black,
                               swipeDismissible: true,
                               immersive: true,
                             );
                           },
                           child: Image.network(tweetphoto[index]),
                         ),
                       const SizedBox(
                         height: 50,
                       ),
                     ],
                   );
                 },
               ),
             )
                 :
             Column(
               children: [
                 const Padding(
                   padding:  EdgeInsets.all(10.0),
                   child:  Text("This account's Wings are protected",style: TextStyle(
                       color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 20
                   ),),
                 ),
                 Padding(
                   padding: const EdgeInsets.only(left: 20,right: 20,top: 10),
                   child: Text('Only followers of @$username have access to Wings',
                     textAlign: TextAlign.center,
                     style: const TextStyle(
                         color: Colors.grey,fontWeight: FontWeight.w300,fontSize: 15
                     ),),
                 )
               ],
             ),
           ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
