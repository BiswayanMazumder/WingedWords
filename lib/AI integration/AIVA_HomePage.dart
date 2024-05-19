import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:typing_text/typing_text.dart';
import 'package:wingedwords/Navigation%20Button/Nav_Bar.dart';
import 'package:google_gemini/google_gemini.dart';
import 'dart:ui';
import 'package:wingedwords/api%20keys/api_keys.dart';
import 'package:typing_animation/typing_animation.dart';
class AIVA_Homepage extends StatefulWidget {
  const AIVA_Homepage({Key? key}) : super(key: key);

  @override
  State<AIVA_Homepage> createState() => _AIVA_HomepageState();
}

class _AIVA_HomepageState extends State<AIVA_Homepage> {
  bool loading = false;
  List textChat = [];
  TextEditingController? _lastTextController;

  List textWithImageChat = [];
  String username='';
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  Future<void>getdp()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
    if(docsnap!=null){
      setState(() {
        username=docsnap.data()!['Name'];
      });
    }
  }
  final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();
  final gemini = GoogleGemini(
    apiKey: Apikeys.geminiapi,
  );
  void fromText({required String query})async {
    await getdp();
    setState(() {
      loading = true;
      textChat.add({
        "role": username,
        "text": query,
      });
      _textController.clear();
    });
    scrollToTheEnd();
    gemini.generateFromText(query).then((value) {
      setState(() {
        loading = false;
        textChat.add({
          "role": "AIVA",
          "text": value.text,
        });
      });
      scrollToTheEnd();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        textChat.add({
          "role": "AIVA",
          "text": error.toString(),
        });
      });
      scrollToTheEnd();
    });
  }

  void scrollToTheEnd() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdp();
    //speak();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flutterTts.stop();
  }
  final FlutterTts flutterTts=FlutterTts();
 void speak(String text)async{
    try{
      await flutterTts.setLanguage('en-GB');
      await flutterTts.setPitch(1);
      await flutterTts.speak(text);
      print('speaked');
    }catch(e){
      print('Error in speaking $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final TextEditingController _textController = _lastTextController ?? TextEditingController();
    void _updateLastTextController(TextEditingController controller) {
      _lastTextController = controller;
      print('last controller ${_lastTextController!.text}');
    }
    @override
    void dispose() {
      _lastTextController?.dispose();
      super.dispose();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 70),
        child: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BottomNavBarExample()),
              );
            },
            icon: const Icon(CupertinoIcons.back, color: Colors.grey),
          ),
          backgroundColor: Colors.grey.shade900,
          actions: [
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    debugPrint('clicked');
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.history, color: Colors.white),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(right: 10))
          ],
          title: const TypingText(
            words: ['  WingedWords Presents', '  AI Virtual Assistant'],
            letterSpeed: Duration(milliseconds: 100),
            wordSpeed: Duration(milliseconds: 1000),
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
           Expanded(
            child:Stack(
              children: [
                ListView.builder(
                  controller: _controller,
                  itemCount: textChat.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    final role = textChat[index]["role"];
                    final isUser = role == username;
                    return Container(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: ListTile(
                        isThreeLine: true,
                        title: Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: isUser
                              ? ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [Colors.yellowAccent, Colors.white],
                                stops: [0.0, 1.0],
                              ).createShader(bounds);
                            },
                            child: Text(role, style: TextStyle(color: Colors.blue.shade300)),
                          )
                              : ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [Colors.yellowAccent, Colors.grey],
                                stops: [0.0, 1.0],
                              ).createShader(bounds);
                            },
                            child: Text(role, style: TextStyle(color: Colors.green.shade300)),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              textChat[index]["text"],
                              style: TextStyle(color: isUser ? Colors.white : Colors.blue, fontSize: 15),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (!isUser)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () => speak(textChat[index]["text"]),
                                    child: const Icon(CupertinoIcons.mic, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: (){
                                      fromText(query: _textController.text);
                                    },
                                    child: const Icon(CupertinoIcons.refresh_thick, color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                if (textChat.isEmpty)
                  Center(
                    child: ShaderMask(shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.red, Colors.blue],
                        stops: [0.0, 1.0],
                      ).createShader(bounds);
                    },
                      child: Text(
                        'Hello $username ',
                        style:const TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Color of the text before the gradient is applied
                        ),
                      ),
                    )
                  ),
              ],
            )
           ),
          Padding(
            padding: EdgeInsets.zero,
            child:Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20)
                ),
                //color: Colors.grey.shade900,
                height: 110,
                width: double.infinity,
                child: Column(
                  children: [
                   const SizedBox(
                      height: 10,
                    ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                          ),
                         child:TextField(
                           controller: _textController,
                          style: const TextStyle(color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                              onTap: (){
                                if(_textController.text.isNotEmpty){
                                  fromText(query: _textController.text);
                                }
                              },
                              child: const Icon(Icons.send,color: Colors.white,),
                            ),
                            hintText: 'Type To Start Chatting...',
                            hintStyle:const TextStyle(color: Colors.white,fontWeight:FontWeight.w300,fontSize: 15),
                            prefixIcon: const Icon(Icons.gamepad,color: Colors.white,),
                          ),
                         ),
                        ),
                      ),
                  ],
                ),
              ),

          ),
        ],
      ),
    );
  }
}
