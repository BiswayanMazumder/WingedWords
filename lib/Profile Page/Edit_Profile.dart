import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Edit_Profile extends StatefulWidget {
  const Edit_Profile({Key? key}) : super(key: key);

  @override
  State<Edit_Profile> createState() => _Edit_ProfileState();
}

class _Edit_ProfileState extends State<Edit_Profile> {
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  String dropdownValue = 'UI/UX';
  String profilepicture='';
  String username='';
  Future<void>getdp()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('User Details').doc(user!.uid).get();
    if(docsnap!=null){
      setState(() {
        profilepicture=docsnap.data()!['Profile Pic'];
        username=docsnap.data()!['Name'];
      });
    }
    debugPrint('DP link $profilepicture, $username');
  }
  late TextEditingController _nameController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdp();
    _nameController = TextEditingController(text: username);
  }
  @override
  Widget build(BuildContext context) {
    final user=_auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(profilepicture),
              ),
            ),
            const SizedBox(
              height: 70,
            ),
           const Padding(padding: EdgeInsets.only(left: 20.0),
           child: Row(
             children: [
               Text('Username',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
             ],
           ),
           ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20.0),
              child: TextField(
                style:const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15) ,
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: username,
                  hintStyle:const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 12),
                  border:const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 0.3)
                  )
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Padding(padding: EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  Text('Username Email',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20.0),
              child: TextField(
                //controller: _nameController,
                readOnly: true,
                decoration: InputDecoration(
                    hintText:user!.email,
                    hintStyle:const TextStyle(color: Colors.white,fontWeight: FontWeight.w300,fontSize: 12),
                    border:const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white,width: 0.3)
                    )
                ),
              ),
            ),
            // const SizedBox(
            //   height: 50,
            // ),
            // const Padding(padding: EdgeInsets.only(left: 20.0),
            //   child: Row(
            //     children: [
            //       Text('Username Bio',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
            //     ],
            //   ),
            // ),
            // const SizedBox(
            //   height: 20,
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 20.0,right: 20.0),
            //   child: Container(
            //     height: 60,
            //     width: 380,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.white,width: 0.3),
            //     ),
            //     child: Center(
            //       child: DropdownButton<String>(
            //         onTap: () {
            //           print(dropdownValue);
            //         },
            //         value: dropdownValue,
            //         onChanged: (String? newValue) {
            //           setState(() {
            //             dropdownValue = newValue!;
            //           });
            //         },
            //         items: <String>['UI/UX', 'Web Developer', 'Frontend Developer', 'Full Stack Developer',
            //         'Flutter Developer','Politician','Engineer','Driver','CEO','Businessman'
            //         ]
            //             .map<DropdownMenuItem<String>>((String value) {
            //           return DropdownMenuItem<String>(
            //             value: value,
            //             child: Center(child: Text(value,style: TextStyle(color: Colors.blue),)),
            //           );
            //         }).toList(),
            //       ),
            //     ),
            //   )
            // ),
            const  SizedBox(
              height:50 ,
            ),
            Container(
              height:60 ,
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.orange.shade900,
              ),
              child: InkWell(
                onTap: ()async{

                    if(_nameController.text.isNotEmpty){
                     try{
                       await _firestore.collection('User Details').doc(user!.uid).update(
                           {
                             'Name':_nameController.text,

                           });
                       ScaffoldMessenger.of(context)
                           .showSnackBar( SnackBar(
                         backgroundColor: Colors.green,
                         content: Text("Username changed to ${_nameController.text}"),
                       ));
                       Navigator.pop(context);
                     }catch(e){
                       ScaffoldMessenger.of(context)
                           .showSnackBar( SnackBar(
                         backgroundColor: Colors.red,
                         content: Text("Couldnot change username to ${_nameController.text}"),
                       ));
                     }
                    }


                },
                child:const Center(
                  child: Text('Update Changes',style: TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            const  SizedBox(
              height:50 ,
            ),
            Container(
              height:60 ,
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue.shade900,
              ),
              child: InkWell(
                onTap: ()async{
                  try{
                    await _auth.sendPasswordResetEmail(email: user.email!);
                    ScaffoldMessenger.of(context)
                        .showSnackBar( const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text("Successfully sent password reset email"),
                    ));

                    Navigator.pop(context);
                  }catch(e){
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const  SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Couldnot send password reset email"),
                    ));
                  }
                },
                child:const Center(
                  child: Text('Change Password',style: TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.bold),),
                ),
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
