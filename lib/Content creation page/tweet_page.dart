import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wingedwords/HomePage/HomePage.dart';
import 'package:wingedwords/Navigation%20Button/Nav_Bar.dart';
import 'package:wingedwords/api%20keys/api_keys.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
class Tweet_Creation extends StatefulWidget {
  const Tweet_Creation({Key? key}) : super(key: key);

  @override
  State<Tweet_Creation> createState() => _Tweet_CreationState();
}
class _Tweet_CreationState extends State<Tweet_Creation> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String profilepicture = '';
  bool foryou = true;
  bool following = false;
  File? _pickedImage;
  FocusNode _focusNode = FocusNode();
  final String apiKey="${Apikeys.geminiapi}";
  Future<void> generatequery() async {
    try {
      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final prompt = _postcontroller.text;
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        final newText = _formatText(response.text??'');
        _postcontroller.text = newText; // Update text in the text field
      });

      print('Story is ${response.text}');
    } catch (e) {
      print('gemimi $e');
    }
  }
  Future<void> _openGifPicker(BuildContext context) async {
    const apiKey = Apikeys.giphyapi; // Your Giphy API Key
    const url =
        'https://api.giphy.com/v1/gifs/trending?api_key=$apiKey&limit=20';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Get a random GIF from the response
      final List<dynamic> gifs = data['data'];
      if (gifs.isNotEmpty) {
        final randomGif = gifs[0]['images']['original']['url'];
        // Do something with the random GIF URL, like display it in an Image
        print('Random GIF URL: $randomGif');
      }
    } else {
      // Handle API request error
      print('Failed to fetch GIFs: ${response.statusCode}');
    }
  }
  String _formatText(String text) {
    // Use regular expression to find text enclosed between '**'
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    return text.replaceAllMapped(boldRegex, (match) {
      // Wrap matched text with bold style
      return '**${match.group(1)}**';
    });
  }

  Future<void> getdp() async {
    final user = _auth.currentUser;
    final docsnap =
    await _firestore.collection('User Details').doc(user!.uid).get();
    if (docsnap != null) {
      setState(() {
        profilepicture = docsnap.data()!['Profile Pic'];
      });
    }
    print('DP link $profilepicture');
  }

  TextEditingController _postcontroller = TextEditingController();
  String responseData = '';
  bool isPostButtonEnabled = false;
  late AudioPlayer player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    getdp();
    _focusNode.requestFocus();
    // Listen to changes in the text field controller
    _postcontroller.addListener(_updatePostButtonState);

  }

  // Update the state to enable/disable the post button
  void _updatePostButtonState() {
    setState(() {
      isPostButtonEnabled = _postcontroller.text.isNotEmpty;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: Row(
      //   children: [
      //     SizedBox(
      //       width: 30,
      //     ),
      //     InkWell(
      //       onTap: (){
      //         pickImage();
      //       },
      //       child:const Icon(Icons.photo_size_select_actual_outlined,color: Colors.blue,),
      //     ),
      //     SizedBox(
      //       width: 30,
      //     ),
      //     InkWell(
      //       onTap: (){},
      //       child:const Icon(Icons.gif_box_outlined,color: Colors.blue,),
      //     ),
      //     SizedBox(
      //       width: 30,
      //     ),
      //     InkWell(
      //       onTap: (){},
      //       child:const Icon(Icons.location_on_rounded,color: Colors.blue,),
      //     ),
      //     SizedBox(
      //       width: 30,
      //     ),
      //     InkWell(
      //       onTap: ()async{
      //         isPostButtonEnabled?generatequery():();
      //       },
      //       child:Icon(Icons.person,color: isPostButtonEnabled?Colors.blue:Colors.grey,),
      //     )
      //   ],
      // ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: isPostButtonEnabled ? () async {
                    setState(() {
                      isPostButtonEnabled = false; // Disable the button
                    });
                    await generateUniqueRandomNumber();
                    player = AudioPlayer();

                    // Set the release mode to keep the source after playback has completed.
                    player.setReleaseMode(ReleaseMode.stop);

                    // Start the player as soon as the app is displayed.
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await player.setSource(AssetSource('images/post_sound.mp3'));
                      await player.resume();
                    });
                    _showNotification();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavBarExample(),));
                  } : null, // Disable the button if isPostButtonEnabled is false
                  child:  Text(
                    'Post',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      isPostButtonEnabled ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: TextField(
                enabled: true,
                autocorrect: true,
                controller: _postcontroller,
                maxLines: 20,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    hintText: '   What is happening?',
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: (){
                    pickImage();
                    //_showNotification();
                  },
                  child:const Icon(Icons.photo_size_select_actual_outlined,color: Colors.blue,),
                ),
                const SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: (){
                    //_openGifPicker(context);
                  },
                  child:const Icon(Icons.gif_box_outlined,color: Colors.blue,),
                ),
                SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: (){},
                  child:const Icon(Icons.location_on_rounded,color: Colors.blue,),
                ),
                SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: ()async{
                    isPostButtonEnabled?generatequery():();
                  },
                  child:Icon(Icons.person,color: isPostButtonEnabled?Colors.blue:Colors.grey,),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            _pickedImage != null
                ? Image.file(_pickedImage!,width: 150,height: 150,)
                : SizedBox(),
            const SizedBox(
              height: 20,
            ),

          ],
        ),
      ),
    );
  }

  Future<String> generateUniqueRandomNumber() async {
    String randomCombination = ''; // Initialize with an empty string
    bool unique = false;

    // Keep generating until a unique combination is found
    try{
      while (!unique) {
        randomCombination = _generateRandomCombination();
        unique = await _checkUniqueCombination(randomCombination);
      }
    }catch(e){
      print(e);
    }

    // Store the random combination as a document name in Firestore
    await _storeRandomCombination(randomCombination);

    return randomCombination;
  }

  Future<bool> _checkUniqueCombination(String combination) async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection('Global Tweet IDs').get();
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        List<dynamic> numbers = document['TIDs'];
        if (numbers.contains(combination)) {
          return false; // Combination already exists, not unique
        }
      }
      return true; // Combination is unique
    } catch (e) {
      print(e);
      return false; // Return false in case of any error
    }
  }


  String _generateRandomCombination() {
    // Generate a random combination of numbers (e.g., 6 digits)
    Random random = Random();
    String combination = '';
    for (int i = 0; i < 10; i++) {
      //earlier i=6
      combination += random.nextInt(10).toString();
    }
    return combination;
  }

  Future<void> _storeRandomCombination(String combination) async {
    try {
      final user = _auth.currentUser;

      // Upload image to Firebase Storage
      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('tweet_images').child(combination);
        await storageRef.putFile(_pickedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // Store data in Firestore
        await _firestore.collection('Global Tweets').doc(combination).set({
          'Uploaded At': DateTime.now(),
          'Tweet Message': _postcontroller.text,
          'User DP Link': profilepicture,
          'Uploaded UID': user!.uid,
          'Views': 0,
          'Image URL': imageUrl,
        });

        await _firestore.collection('Global Tweet IDs').doc('TIDs').set(
          {
            'TIDs': FieldValue.arrayUnion([combination]),
          },
          SetOptions(merge: true),
        );

        await _firestore.collection('User Uploaded Tweet ID').doc(user.uid).set(
          {
            'TIDs': FieldValue.arrayUnion([combination]),
          },
          SetOptions(merge: true),
        );
      } else {
        // Handle case where no image is picked
        await _firestore.collection('Global Tweets').doc(combination).set({
          'Uploaded At': DateTime.now(),
          'Tweet Message': _postcontroller.text,
          'User DP Link': profilepicture,
          'Uploaded UID': user!.uid,
          'Views': 0,
        });
        await _firestore.collection('Global Tweet IDs').doc('TIDs').set(
          {
            'TIDs': FieldValue.arrayUnion([combination]),
          },
          SetOptions(merge: true),
        );
        await _firestore.collection('User Uploaded Tweet ID').doc(user.uid).set(
          {
            'TIDs': FieldValue.arrayUnion([combination]),
          },
          SetOptions(merge: true),
        );
        print('No image picked');
      }
    } catch (e) {
      print('Error storing data: $e');
    }
  }
  void _showNotification() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
      ],
    );

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'alerts',
        title: 'Posted',
        //customSound: ,
        body: 'Your Wings are posted',
        actionType: ActionType.KeepOnTop,

      ),
    );
  }
}
