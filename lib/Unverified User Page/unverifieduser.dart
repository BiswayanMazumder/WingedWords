import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class UnVerified extends StatefulWidget {
  const UnVerified({Key? key}) : super(key: key);

  @override
  State<UnVerified> createState() => _UnVerifiedState();
}

class _UnVerifiedState extends State<UnVerified> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  var temp1=false;
  @override
  Widget build(BuildContext context) {
    final user=_auth.currentUser;
    return  Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(child: Image(image: AssetImage('assets/images/not verified bot.gif'))),
            const Text('\nVERIFICATION',style: TextStyle(
              color: Colors.black,fontWeight: FontWeight.bold,
              fontSize:30,
              letterSpacing: 5
            ),),
            const Text('\nPlease Click "Allow" to verify you are not robot',style: TextStyle(
                color: Colors.black,fontWeight: FontWeight.w500,
                fontSize:20,
                //letterSpacing: 5
            ),
            textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 50,
            ),
            InkWell(
              onTap: ()async{
                await user!.sendEmailVerification();
                setState(() {
                  temp1=true;
                });
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: const Center(
                  child: Text('Allow',style: TextStyle(
                    color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18
                  ),),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 20,right: 20,
            top: 10
            ),
            child:Text('\nRobots and automation are rapidly transforming industries worldwide, reshaping the future of work. From self-driving cars to automated customer service, these advancements offer unparalleled efficiency but also raise concerns about job displacement and the need for workforce adaptation. Understanding the implications of this technological shift is crucial for businesses and policymakers alike.',style: TextStyle(
              color: Colors.grey,fontWeight: FontWeight.w500,
              fontSize:12,
              //letterSpacing: 5
            ),
              textAlign: TextAlign.center,
            ),
            ),

             temp1? Text('\n\nVerification email sent successfully to your email ID ${user!.email}',style:const TextStyle(
              color: Colors.black,fontWeight: FontWeight.w300,
              fontSize:12,
              //letterSpacing: 5
            ),
              textAlign: TextAlign.center,
            ):Container(),
          ],
        ),
      ),
    );
  }
}
