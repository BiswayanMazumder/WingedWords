import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wingedwords/Others%20Profile/others_profile.dart';
class Comment_Page extends StatefulWidget {
  final String owner;
  final String owner_photo;
  final String uid;
  final String image_link;
  final String wings_body;
  final String wings_id;
  final String wings_date;
  Comment_Page({required this.owner,required this.image_link,required this.owner_photo,required this.uid,
  required this.wings_body,required this.wings_id,required this.wings_date
  });

  @override
  State<Comment_Page> createState() => _Comment_PageState();
}

class _Comment_PageState extends State<Comment_Page> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  bool isOwner=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.image_link);
  }
  @override
  Widget build(BuildContext context) {
    final user=_auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon:const Icon(CupertinoIcons.back,color: Colors.white,)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:const EdgeInsets.only(left: 20,top: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap:(){
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(widget.owner_photo),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  InkWell(
                      onTap: (){

                      },
                      child: Text(widget.owner,style:const TextStyle(color: Colors.white,fontSize:15 ,fontWeight: FontWeight.bold),)),
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
            Padding(
              padding:const EdgeInsets.only(top: 20.0,left: 10.0,right: 10.0),
              child: Text(widget.wings_body,style: TextStyle(color: Colors.white),
              //textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding:const EdgeInsets.only(top: 20.0,left: 10.0,right: 10.0),
            child:
              widget.image_link!='placeholder'?Image.network(widget.image_link):Container()

            ),
            const SizedBox(
              height: 20,
            ),
            Padding(padding:const EdgeInsets.only(left: 20.0),
            child: Row(
              children: [
                Text(widget.wings_date,style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
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
