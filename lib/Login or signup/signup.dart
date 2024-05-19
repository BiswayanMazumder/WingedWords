import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wingedwords/Login%20or%20signup/signupotp.dart';
class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _emailController=TextEditingController();
  TextEditingController _nameController=TextEditingController();
  TextEditingController _passwordController=TextEditingController();
  bool showpw=false;
  EmailOTP myauth = EmailOTP();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading:IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(CupertinoIcons.back,color: Colors.white,)),
      ),
      body: SingleChildScrollView(
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
                  child:  Text('SignUp To WingedWords',
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
                decoration:  const InputDecoration(
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
            const Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 30.0),
                  child:  Text('Name',
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
                controller: _nameController,
                decoration:const InputDecoration(

                    hintText: 'Your Name',
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
            const  SizedBox(
              height:20 ,
            ),
            Container(
              height:60 ,
              width: 330,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.orange.shade900,
                  border: Border.all(color: Colors.white)
              ),
              child: InkWell(
                onTap: ()async{
                  if(_nameController.text.isNotEmpty 
                      && _passwordController.text.isNotEmpty 
                      && _emailController.text.isNotEmpty){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp_OTP(
                      name: _nameController.text,
                      password: _passwordController.text,
                      email: _emailController.text,
                    )));
                  }else{
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Some of the fields are still unfilled"),
                    ));
                  }
                },
                child:const Center(
                  child: Text('Send OTP',style: TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            const  SizedBox(
              height:50 ,
            ),
          ],
        ),
      ),
    );
  }
}
