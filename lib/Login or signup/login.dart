import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wingedwords/HomePage/HomePage.dart';
import 'package:wingedwords/Navigation%20Button/Nav_Bar.dart';
class Login_Page extends StatefulWidget {
  const Login_Page({Key? key}) : super(key: key);

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  TextEditingController _emailController=TextEditingController();
  TextEditingController _passwordController=TextEditingController();
  TextEditingController _otpController=TextEditingController();
  final FirebaseAuth _auth=FirebaseAuth.instance;
  bool showpw=false;
  EmailOTP myauth = EmailOTP();
  void sendotp()async{
    myauth.setConfig(
        appEmail: "biswayanmazumder77@gmail.com",
        appName: "Email OTP",
        userEmail: 'biswayanmazumder27@gmail.com',
        otpLength: 6,
        otpType: OTPType.digitsOnly
    );
    if(_emailController.text.isEmpty){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
      content: Text("Please Enter Email"),
      ));
    }else{
      if (await myauth.sendOTP() == true) {
        print(_emailController.text);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
          content: Text("OTP has been sent"),
        ));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
          content: Text("Oops, OTP send failed"),
        ));
      }
    }
  }
  bool otpsent=false;
  bool otpverified=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(CupertinoIcons.back,color: Colors.white,)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body:  SingleChildScrollView(
        child: Column(

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
                child:  Text('Login To WingedWords',
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
            const Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 30.0),
                  child:  Text('Email',
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ),),
                ),
              ],
            ),
           const SizedBox(
              height: 30,
            ),
            Padding(
              padding:  const EdgeInsets.only(left: 30.0,right: 30.0),
              child: TextField(
                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15) ,
                controller: _emailController,
                decoration:  InputDecoration(
                  suffixIcon: IconButton(onPressed: ()async{
                    myauth.setConfig(
                        appEmail: "biswayanmazumder77@gmail.com",
                        appName: "WingedWords",
                        userEmail: _emailController.text,
                        otpLength: 4,
                        otpType: OTPType.digitsOnly
                    );
                    if(_emailController.text.isEmpty){
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("Please Enter Email"),
                      ));
                    }else{
                      if (await myauth.sendOTP() == true) {
                        print(_emailController.text);
                        setState(() {
                          otpsent=!otpsent;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("OTP sent to ${_emailController.text}"),
                        ));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Oops, OTP send failed"),
                        ));

                      }
                    }

                  },
                      icon: const Icon(Icons.verified_user_rounded,color: Colors.white,)),
                    hintText: 'hello@company.com',
                    hintStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white,width: 0.3)
                    )
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 30.0),
                  child:  Text('Password',
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ),),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding:  const EdgeInsets.only(left: 30.0,right: 30.0),
              child: TextField(
                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15) ,
                controller: _passwordController,
                obscureText: showpw?false:true,
                decoration:  InputDecoration(
                  suffixIcon: IconButton(onPressed: (){
                    setState(() {
                      showpw=!showpw;
                    });
                  }, icon:Icon(showpw?CupertinoIcons.eye:CupertinoIcons.eye_slash),
                    color: Colors.white,),
                    hintText: 'Your Password',
                    hintStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white,width: 0.3)
                    )
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
           otpsent? Column(
              children: [
                const Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 30.0),
                      child:  Text('OTP',
                        style: TextStyle(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                        ),),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding:  const EdgeInsets.only(left: 30.0,right: 30.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15) ,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration:  InputDecoration(
                      suffixIcon: IconButton(onPressed: ()async{
                        var res=myauth.verifyOTP(otp: _otpController.text);
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
              ],
            ):Container(),
            const SizedBox(
              height: 50,
            ),
            Container(
              height:60 ,
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color:otpverified? Colors.blue:Colors.grey,
              ),
              child: InkWell(
                onTap: ()async{
                  if(otpverified){
                    if(otpverified){
                      await _auth.signInWithEmailAndPassword(email: _emailController.text,
                          password: _passwordController.text);
                      // UserCredential usercredentials=await _auth.signInWithEmailAndPassword(email: _emailController.text,
                      //     password: _passwordController.text);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavBarExample()));
                    }
                  }else{
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Something Went Wrong"),
                    ));
                  }
                },
                child: Center(
                  child: Text('Login',style: TextStyle(color: otpverified?Colors.black:Colors.white,
                      fontSize:20,
                      fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            const  SizedBox(
              height:20 ,
            ),
          ],
        ),
      ),
    );
  }
}
