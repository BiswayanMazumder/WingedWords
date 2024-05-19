import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wingedwords/Login%20or%20signup/login.dart';
import 'package:wingedwords/Login%20or%20signup/signup.dart';

class Loginsignuplanding extends StatefulWidget {
  const Loginsignuplanding({Key? key}) : super(key: key);

  @override
  State<Loginsignuplanding> createState() => _LoginsignuplandingState();
}

class _LoginsignuplandingState extends State<Loginsignuplanding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loginorsignup.jpg'),
            fit: BoxFit.cover
          ),
        ),
        child: SingleChildScrollView(
          child: Column(

            children: [
              const SizedBox(
                height: 100,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'A platform fostering free expression and open dialogue.',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 30,
                      fontStyle: FontStyle.italic),
                ),
              ),
              const Center(
                child: Image(
                  image: AssetImage('assets/images/wingedwordslogo.png'),
                  height: 300,
                  width: 500,
                ),
              ),
               SizedBox(
                height:MediaQuery.of(context).size.height/3 ,
              ),
              Container(
                height: 60,
                width: 330,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login_Page()),
                    );
                  },
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 60,
                width: 330,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                  child: const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
