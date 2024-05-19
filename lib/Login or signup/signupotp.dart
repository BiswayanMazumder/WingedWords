import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field_v2/otp_text_field_v2.dart';
import 'package:wingedwords/HomePage/HomePage.dart';
import 'package:wingedwords/Navigation%20Button/Nav_Bar.dart';
class SignUp_OTP extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  SignUp_OTP({required this.email,required this.password,
    required this.name
  });
  @override
  State<SignUp_OTP> createState() => _SignUp_OTPState();
}

class _SignUp_OTPState extends State<SignUp_OTP> {
  EmailOTP myauth = EmailOTP();
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  OtpFieldControllerV2 otpController = OtpFieldControllerV2();
  TextEditingController _otpcontroller=TextEditingController();
  bool otpverified=false;
  FirebaseAuth _auth=FirebaseAuth.instance;
  void sendotp()async{
    myauth.setConfig(
        appEmail: "otp-verification@wingedwords.org",
        appName: "WingedWords",
        userEmail: widget.email,
        otpLength: 4,
        otpType: OTPType.digitsOnly
    );
      if (await myauth.sendOTP() == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar( SnackBar(
          backgroundColor: Colors.green,
          content: Text("OTP sent to ${widget.email}"),
        ));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Oops, OTP send failed"),
        ));
      }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sendotp();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading:IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(CupertinoIcons.back,color: Colors.white,)),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Image(image: AssetImage('assets/images/wingedwordslogo.png'),height: 200,width: 500,),
            ),
            const SizedBox(
              height: 50,
            ),
            const Row(
              children: [
                Padding(padding:  EdgeInsets.only(left: 30.0),
                  child:  Text('Check your email',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500
                    ),),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
             Row(
              children: [
                Padding(padding:const  EdgeInsets.only(left: 30.0),
                  child:  Text('Please check email ${widget.email}',
                    style:const TextStyle(
                        fontStyle: FontStyle.normal,
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w300
                    ),),
                ),
              ],
            ),
            const SizedBox(
              height: 70,
            ),
            Padding(
              padding:  const EdgeInsets.only(left: 30.0,right: 30.0),
              child: TextField(
                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15) ,
                controller: _otpcontroller,
                keyboardType: TextInputType.number,
                decoration:  InputDecoration(
                    suffixIcon: IconButton(onPressed: ()async{
                      var res=myauth.verifyOTP(otp: _otpcontroller.text);
                      if(res){
                        setState(() {
                          otpverified=true;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("OTP Verified"),
                        ));
                      }else{
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("OTP verification failed"),
                        ));
                      }
                    }, icon: Icon(
                      Icons.verified,color: Colors.green,
                    )),
                    hintText: 'Your OTP',
                    hintStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),
                    border:const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white,width: 0.3)
                    )
                ),
              ),
            ),
            const  SizedBox(
              height:20 ,
            ),
            Row(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 30.0),
                  child: InkWell(
                    onTap: (){
                      sendotp();
                    },
                    child: Text('Resend OTP',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
            const  SizedBox(
              height:80 ,
            ),
            Container(
              height:60 ,
              width: 330,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue.shade900,
                  border: Border.all(color: Colors.white)
              ),
              child: InkWell(
                onTap: ()async{
                  if(otpverified){
                    await _auth.createUserWithEmailAndPassword(email: widget.email,
                        password: widget.password);
                    final user=_auth.currentUser;
                    await _firestore.collection('User Details').doc(user!.uid).set(
                        {
                          'Email':widget.email,
                          'Bio':'Winger',
                          'Name':widget.name,
                          'Location':'India',
                          'Profile Pic':'https://images.unsplash.com/photo-1713789521123-b67d1066ea5'
                              '1?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1w'
                              'YWdlfHx8fGVufDB8fHx8fA%3D%3D',
                          'Time Of Registration':FieldValue.serverTimestamp()
                        });
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavBarExample()));
                  }
                },
                child:const Center(
                  child: Text('Create Account',style: TextStyle(color: Colors.white,
                      fontSize:20,
                      fontWeight: FontWeight.bold),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
