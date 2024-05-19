import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wingedwords/Others%20Profile/others_profile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searcheduser = TextEditingController();
  bool isShowUser = false;
  List<String>Uids=[];
  Future<List<String>> getUserSearchDetails() async {
    final user=_auth.currentUser;
    if (user!.uid == null) {
      throw Exception('Missing user UID');
    }

    try {
      // Fetch search details
      final userSearchesRef = FirebaseFirestore.instance
          .collection('User Searches')
          .doc(user.uid);

      final searchDetailsSnapshot = await userSearchesRef.get();
      final searchDetails = searchDetailsSnapshot.exists
          ? searchDetailsSnapshot.data()!['Searches']?.cast<Map<String, dynamic>>() ?? []
          : [];

      // Extract UIDs from search details
      final uids = searchDetails.map((search) => search['UIDs'] as String).toList();
      print("Search Results $uids");
      for(String ids in uids){
        final docsnap=await _firestore.collection('User Details').doc(ids).get();
        if(docsnap.exists){
          usernames.add(docsnap.data()?['Name']);
          profilepictures.add(docsnap.data()?['Profile Pic']);
        }
      }
      print('Search $usernames');
      print('Search $profilepictures');
      return uids;
    } on FirebaseException catch (error) {
      debugPrint('Error fetching user search details: ${error.message}');
      rethrow; // Re-throw for handling in calling code
    } catch (error) {
      debugPrint('Error: ${error}');
      rethrow; // Re-throw for handling in calling code
    }
  }
  List<String>usernames=[];
  String Usernames='';
  String DP='';
  List<String>profilepictures=[];
  List<String> searchResults = [];
  Future<void>fetchdetails()async{
    // final uids = await getUserSearchDetails();
    // setState(() {
    //   searchResults = uids;
    // });
    // print('Search $searchResults');
    // for(String ids in uids){
    //   final docsnap=await _firestore.collection('User Details').doc(ids).get();
    //   if(docsnap.exists){
    //     usernames.add(docsnap.data()?['Name']);
    //     profilepictures.add(docsnap.data()?['Profile Pic']);
    //   }
    // }
    // print('DP $profilepictures');
    // print('Names $usernames');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdetails();
    getUserSearchDetails();
  }
  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 80),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 10,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
          ),
          shadowColor: Colors.grey,
          title: Container(
            height: 40,
            child: TextFormField(
              controller: _searcheduser,
              onFieldSubmitted: (_) {
                setState(() {
                  isShowUser = true;
                });
                print(isShowUser);
                print(_searcheduser.text);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  //hintText: 'Search WingedWords',
                  hintStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                  fillColor: Colors.grey.shade800,
                  filled: true,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  )),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: isShowUser
          ? FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('User Details')
            .where('Name', isGreaterThanOrEqualTo: _searcheduser.text)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display circular progress indicator while waiting for data
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            // Display error message if there's an error
            debugPrint('error found');
            return Center(
              child: Text('Error in getting username: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return  Center(
              child: Text('No users found with username ${_searcheduser.text}',style:const TextStyle(color: Colors.white),),
            );
          } else {
            // Display user list when data is available
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var userData = snapshot.data!.docs[index].data();
                String userId = snapshot.data!.docs[index].id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                    NetworkImage(userData['Profile Pic']==null?'Placeholder':userData['Profile Pic']),
                  ),
                  title: Text(
                    userData['Name'],
                    style: const TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w500),
                  ),
                  trailing: InkWell(
                    onTap: ()async{
                      print('User id $userId');
                      await _firestore.collection('User Searches').doc(user!.uid).set(
                          {
                            'Searches':FieldValue.arrayUnion([
                              {'UIDs': userId}
                              ])
                          },SetOptions(merge: true));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => other_profile_page(
                            uid: userId,
                            isOwner: user!.uid==userId?true:false,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                );
              },
            );
          }
        },
      )
          :   SingleChildScrollView(
        child: FutureBuilder<List<String>>(
          future: getUserSearchDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        profilepictures.length,
                            (index) => Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            height: 300,
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey, width: 0.5),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 50),
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(profilepictures[index]),
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Center(
                                    child: Text(
                                      usernames[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        profilepictures.length,
                            (index) => Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            height: 300,
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey, width: 0.5),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 50),
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(profilepictures[index]),
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Center(
                                    child: Text(
                                      usernames[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            }
          },
        ),
      )
    );
  }
}
