import 'dart:async';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wingedwords/Content%20creation%20page/tweet_page.dart';
import 'package:wingedwords/HomePage/Comment_Page.dart';
import 'package:wingedwords/Landing%20Page/LandingPage.dart';
import 'package:wingedwords/Others%20Profile/others_profile.dart';
import 'package:wingedwords/Profile%20Page/user_profile_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:wingedwords/Trending%20Page/trending_page.dart';
import 'package:wingedwords/Utils/Colors/Colours.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isOwner=false;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  String profilepicture='';
  bool foryou=true;
  bool following=false;
  List<bool>liked=[];
  Future<void>getdp()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
    if(docsnap!=null){
      setState(() {
        profilepicture=docsnap.data()!['Profile Pic'];
      });
    }
    //print('DP link $profilepicture');
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();
  List<String> tweetIDs = [];
  List<String> tweetbody=[];
  List<String> tweetphoto=[];
  List<int> tweetviews=[];
  List<Timestamp>tweetuploaddate=[];
  List<String> wings_uploaded=[];
  List<String> tweetowner=[];
  List<String> ownername=[];
  List<String> ownerphoto=[];
  List<String>likedby=[];
  String _country='NaN';
  final List<String> finalids=[];
  List<String> likes=[];
  List<String> followerIDs = [];
  Future<List<String>>fetchlikes()async{
    final user=_auth.currentUser;
    final List<dynamic>likeuids=[];
    await fetchTweetIDs(user!.uid);
    try{
      for(String ids in finalids){
        final snapshot=await _firestore.collection('Likes Of Tweets').doc(ids).get();
        final likelist=List<Map<String,dynamic>>.from(snapshot.data()?['IDs']??[]);
        print('likes list $likelist');
        setState(() {
          likes=likelist.map((likes) => likes['ID']).cast<String>().toList();
        });
        print('likes $likes');
      }

    }catch(e){
      print('like error $e');
    }
    return [];
  }
  Future<List<String>> fetchTweetIDs(String uid) async {
    final user=_auth.currentUser;
    final List<dynamic> tweetIds=[];
    try {
      final snapshot = await _firestore.collection('Following').doc(user!.uid).get();
      if (snapshot.exists) {
        final user=_auth.currentUser;
        final followerList = List<Map<String, dynamic>>.from(snapshot.data()?['Follower'] ?? []);
        setState(() {
          // Extract user IDs from followerList and store them in followerIDs
          followerIDs = followerList.map((follower) => follower['ID']).cast<String>().toList();
        });
        debugPrint('Tweet ID ${followerIDs}');
        // final snapshot = await _firestore.collection('Global Tweet IDs').doc('TIDs').get();
        // if (snapshot.exists) {
        //   final user=_auth.currentUser;
        //   final List<dynamic> tweetIDs = snapshot.data()?['TIDs'] ?? [];
        for(String Ids in followerIDs){
          final snapshot=await _firestore.collection('User Uploaded Tweet ID').doc(Ids).get();
          if(snapshot.exists){
            tweetIds.add(snapshot.data()?['TIDs'] ?? []);
            debugPrint('tweet ids $tweetIds');
          }
        }

        for(List id in tweetIds){
          for(String idd in id){
            finalids.add(idd);
          }
        }
        print('Final ID $finalids');
        for(String ids in finalids){
          final docsnap=await _firestore.collection('Global Tweets').doc(ids).get();
          if(docsnap.exists ){
            tweetbody.add(docsnap.data()?['Tweet Message']);
            tweetviews.add(docsnap.data()?['Views']);
            tweetuploaddate.add(docsnap.data()?['Uploaded At']);
            tweetowner.add(docsnap.data()?['Uploaded UID']);
            final imageUrl = docsnap.data()?['Image URL'];
              print('Tweet body ${tweetbody.length}');
            for (dynamic timestamp in tweetuploaddate) {
              // Convert the Firestore Timestamp to a DateTime object
              DateTime uploadedAt = (timestamp as Timestamp).toDate();

              // Format the DateTime object to "EEEE, dd MMMM yyyy" format
              String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(uploadedAt);

              // Add the formatted date string to your list
              wings_uploaded.add(formattedDate);
            }
            //print('date time $wings_uploaded');
            liked.add(false);
            if (imageUrl != null && imageUrl is String) {
              tweetphoto.add(imageUrl);
            } else {
              // Insert a placeholder value instead of null
              tweetphoto.add('placeholder');
            }
          }
        }
        for(String dp in tweetowner){
          final docsnaps=await _firestore.collection('User Details').doc(dp).get();
          if(docsnaps.exists){
            ownername.add(docsnaps.data()?['Name']);
            ownerphoto.add(docsnaps.data()?['Profile Pic']);
            setState(() {

            });
          }
        }
        return List<String>.from(followerIDs);

      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching tweet IDs: $e');
      return [];
    }
  }
  @override
  void initState() {
    final user = _auth.currentUser;
    super.initState();
    //fetchlikes();
    print(user!.uid);
    // player = AudioPlayer();
    //
    // // Set the release mode to keep the source after playback has completed.
    // player.setReleaseMode(ReleaseMode.stop);
    //
    // // Start the player as soon as the app is displayed.
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await player.setSource(AssetSource('images/welcome_sound.m4a'));
    //   await player.resume();
    // });
    getdp();
    fetchTweetIDs(user!.uid).then((ids) {
      setState(() {
        tweetIDs = ids;
       // print('Tweet IDs: $tweetIDs');
      });
    });
    //startFetching();
  }
  late AudioPlayer player = AudioPlayer();
  final TextEditingController _commentController = TextEditingController();
  List<String> _comments = [];
  @override
  Widget build(BuildContext context) {
    final user=_auth.currentUser;
    return  Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          InkWell(
            onTap: (){
              //_googleSignIn.signOut();
              //_auth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Trending_Page(),));
            },
            child:const Icon(Icons.search,color: Colors.white,),
          ),
          const SizedBox(
            width: 20,
          ),
          InkWell(
            onTap: (){
               showDialog(context: context, builder: (context) {
                 return  AlertDialog(
                   title:const Text('Are you sure you want to logout',style: TextStyle(
                     color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                   ),
                   textAlign: TextAlign.center,
                   ),
                   actions: [
                     Column(
                       children: [
                         const SizedBox(
                           height: 10,
                         ),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             ElevatedButton(onPressed: (){
                               _googleSignIn.signOut();
                               _auth.signOut();
                               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>const LandingPage(),));
                             },
                                 child:  Text('Logout',style: TextStyle(
                                     color: Colors.black
                                 ),),
                             style:const ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.deepOrange)),
                             ),
                             ElevatedButton(onPressed: (){
                               // _googleSignIn.signOut();
                               // _auth.signOut();
                               // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage(),));
                             },
                               child: Text('Cancel',style: TextStyle(
                                 color: Colors.black
                               ),),
                               style:const ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.green)),
                             ),
                           ],
                         )
                       ],
                     )
                   ],
                 );
               },);
            },
            child:const Icon(Icons.logout,color: Colors.white,),
          ),
         const SizedBox(
            width: 20,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => User_ProfilePage(),));
                },
              ),
            ),
          ],
        ),
          title:const Image(image: AssetImage('assets/images/wingedwordslogo.png'),height: 80,width: 80,),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     InkWell(
          //       onTap: (){
          //         setState(() {
          //           foryou=true;
          //           following=false;
          //         });
          //       },
          //       child: Text('For You',style: TextStyle(color: foryou?Colors.blue:Colors.white,
          //           fontWeight:foryou? FontWeight.bold:FontWeight.normal,
          //           fontSize:15),),
          //     ),
          //     InkWell(
          //       onTap: (){
          //         setState(() {
          //           following=true;
          //           foryou=false;
          //         });
          //       },
          //       child: Text('Following',style: TextStyle(color: following?Colors.blue:Colors.white,
          //           fontWeight:following? FontWeight.bold:FontWeight.normal,
          //           fontSize:15),),
          //     )
          //   ],
          // ),
          const SizedBox(
            height: 20,
          ),
        foryou?tweetbody.isNotEmpty
            &&
            tweetowner.isNotEmpty
            &&
            tweetphoto.isNotEmpty
            &&
            tweetuploaddate.isNotEmpty
            &&tweetviews.isNotEmpty
            ? Container(
            height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
            child: ListView.builder(
              itemCount: finalids.length,
              itemBuilder: (context, index) {
                return  Column(
                  children: [
                    Padding(
                      padding:const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          InkWell(
                            onTap:(){
                              //print('Tweet ID clicked${tweetowner[index]}');
                              if(tweetowner[index]==user!.uid){
                                setState(() {
                                  isOwner=true;
                                });
                              }else{
                                setState(() {
                                  isOwner=false;
                                });
                              }
                              Navigator.push(context, MaterialPageRoute(builder: (context) => other_profile_page(
                              uid: tweetowner[index],
                                isOwner: isOwner,
                              )));
                              },
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(ownerphoto[index]),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                              onTap: (){
                               // print('tweet clicked ${tweetowner[index]}');
                                if(tweetowner[index]==user!.uid){
                                  setState(() {
                                    isOwner=true;
                                  });
                                }else{
                                  setState(() {
                                    isOwner=false;
                                  });
                                }
                                //print('iss owner $isOwner');
                                Navigator.push(context, MaterialPageRoute(builder: (context) => other_profile_page(
                                  uid: tweetowner[index],
                                  isOwner: isOwner,
                                )));
                              },
                              child: Text(ownername[index],style:const TextStyle(color: Colors.white,fontSize:15 ,fontWeight: FontWeight.bold),)),
                          const  SizedBox(
                            width: 10,
                          ),
                          //Text('@${ownername[index]}',style: const TextStyle(color: Colors.grey,fontSize: 8,fontWeight: FontWeight.w300),),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0,right: 20),
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
                      height:20,
                    ),
                    Row(
                      children: [
                      const Padding(padding: EdgeInsets.only(left: 20.0)),
                        InkWell(
                          onTap:()async{
                            debugPrint('wings id ${finalids[index]}');
                            final user=_auth.currentUser;
                            setState(() {
                              liked[index]=!liked[index];
                            });
                            if(liked[index])
                              {
                                player = AudioPlayer();

                                // Set the release mode to keep the source after playback has completed.
                                player.setReleaseMode(ReleaseMode.stop);

                                // Start the player as soon as the app is displayed.
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  await player.setSource(AssetSource('images/like_audio.mp3'));
                                  await player.resume();
                                });
                                await _firestore.collection('Likes Of Tweets').doc(finalids[index]).set(
                                    {
                                      'IDs':FieldValue.arrayUnion([
                                        {'ID': user!.uid}
                                      ])
                                    },SetOptions(merge: true));

                              }

                            if(!liked[index])
                            {
                              await _firestore.collection('Likes Of Tweets').doc(finalids[index]).update(
                                  {
                                    'IDs':FieldValue.arrayRemove([
                                      {'ID': user!.uid}
                                    ])
                                  });
                              player = AudioPlayer();

                              // Set the release mode to keep the source after playback has completed.
                              player.setReleaseMode(ReleaseMode.stop);

                              // Start the player as soon as the app is displayed.
                              WidgetsBinding.instance.addPostFrameCallback((_) async {
                                await player.setSource(AssetSource('images/dislike_audio.mp3'));
                                await player.resume();
                              });
                            }

                          },
                          child: Icon(liked[index]?CupertinoIcons.heart_fill:CupertinoIcons.heart,color:liked[index]?
                              Colors.red
                              :
                          Colors.white),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        InkWell(
                          onTap:(){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Comment_Page(
                                owner: ownername[index],
                                uid: tweetowner[index],
                                wings_date: wings_uploaded[0],
                                wings_body: tweetbody[index],
                                wings_id: finalids[index],
                                owner_photo: ownerphoto[index],
                                image_link: tweetphoto[index]),));
                          },
                          child: const Icon(Icons.info_outline,color: Colors.white,),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height:50,
                    ),
                  ],
                );
              },
            ),
          ):const Center(
          child: Text('No one is followed yet\n'
              'Follow someone to see their wings',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),)
        ):const Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
              child: Text('Nothing To Show...',style: TextStyle(color: Colors.white,
              fontSize: 20,fontWeight: FontWeight.w400
              ),),
              ),
               SizedBox(
                height: 40,
              ),
               Center(
                child: Image(image: AssetImage('assets/images/wingedwordslogo.png'),height: 300,width: 500,),
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),),
    );
  }

}
