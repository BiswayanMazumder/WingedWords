import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../api keys/api_keys.dart';
class Music_Page extends StatefulWidget {
  final String videourl;
  final String topic;
  Music_Page({required this.videourl,required this.topic
  });
  @override
  State<Music_Page> createState() => _Music_PageState();
}
class _Music_PageState extends State<Music_Page> {
  late VideoPlayerController _controller;
  final String videoUrl = "https://firebasestorage.googleapis.com/v0/b/wingedwordsadmin.appspot.com/o/Trending%20Videos%2FAlan%20Walker%2C%20Sabrina%20Carpenter%20%26%20Farruko%20%20-%20On%20My%20Way.mp4?alt=media&token=9c3f9b9a-3ba8-48d0-8f66-3ac3d0cc3fd5";
  @override
  void initState() {
    super.initState();
    generatequery();
    _controller = VideoPlayerController.network(widget.videourl);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
    _controller.setLooping(true);
    if(_controller.value.hasError){
      print('Error ${_controller.value.errorDescription}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  final Uri _url = Uri.parse('https://sunburn.in/');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
  String postcontroller ='';
  final String apiKey=Apikeys.geminiapi;
  Future<void> generatequery() async {
    try {
      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final prompt = '${widget.topic} in 500 words with no pictures';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        final newText = _formatText(response.text??'');
        postcontroller = newText;
      });

      print('Story is ${postcontroller}');
    } catch (e) {
      print('gemimi $e');
    }
  }

  String _formatText(String text) {
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    return text.replaceAllMapped(boldRegex, (match) {
      // Wrap matched text with bold style
      return '**${match.group(1)}**';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
        _controller.value.isInitialized
        ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
              : const CircularProgressIndicator(color: Colors.white70,),
            const Divider(color: Colors.grey,thickness: 0.3,),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(postcontroller,style:const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
          ),
        ),
            // Padding(padding: EdgeInsets.all(20.0),
            //   child: InkWell(
            //     onTap: (){
            //       _launchUrl();
            //     },
            //     child: Text('https://sunburn.in/',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w300
            //     ),),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
