import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:typing_text/typing_text.dart';
import 'package:wingedwords/AI%20integration/AIVA_HomePage.dart';
import 'package:wingedwords/Navigation%20Button/Nav_Bar.dart';
import 'package:wingedwords/api%20keys/api_keys.dart';
class AIVA_landing extends StatefulWidget {
  const AIVA_landing({Key? key}) : super(key: key);
  @override
  State<AIVA_landing> createState() => _AIVA_landingState();
}
class _AIVA_landingState extends State<AIVA_landing> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  String Orderid='';
  Future<void> createOrder() async {
    String keyId = Apikeys.razorpaykeyid;
    String keySecret = Apikeys.razorpaykeysecret;

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$keyId:$keySecret'));

    final response = await http.post(
      Uri.parse('https://api.razorpay.com/v1/orders'),
      headers: <String, String>{
        'Authorization': basicAuth,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        "amount": 1800000,
        "currency": "INR",
        "receipt": "receipt#1",
        "notes": {
          "key1": "Payment For AIVA",
          "key2": "Payment Date ${DateTime.now()}"
        }
      }),
    );

    if (response.statusCode == 200) {
      Map<String,dynamic> data=jsonDecode(response.body);
      setState(() {
        Orderid=data["id"];
      });
      print("order id $Orderid");
      print('Order created successfully: ${response.body}');
    } else {
      print('Failed to create order. Status code: ${response.statusCode}');
    }
  }
  bool isSubscribed=false;
  Future<void>getpremiumstatus()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Premium Subscribers').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        isSubscribed=docsnap.data()?['Premium'];
      });
    }
    print('Subscribed $isSubscribed');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getpremiumstatus();
  }
  @override
  Widget build(BuildContext context) {
    final user=_auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title:const Image(image: AssetImage('assets/images/wingedwordslogo.png'),height: 80,width: 80,),
        centerTitle: true,
      ),
      body:  SingleChildScrollView(
        child: Padding(
          padding:const EdgeInsets.only(left: 20.0,right: 20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              const Center(
                child: const Image(image: AssetImage('assets/images/AIVA.gif')),
              ),
              const SizedBox(
                height: 50,
              ),
               Padding(
                 padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/4),
                 child: TypingText(
                  words: const ['Say Hello', 'To AIVA'],
                  letterSpeed: const Duration(milliseconds: 100),
                  wordSpeed: const Duration(milliseconds: 1000),
                  style: TextStyle(fontSize: 30,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold),),
               ),
              const SizedBox(
                height: 80,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Emphatic',style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),),
                  Text(' Artificial Intelligence',style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 18
                  ),),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
                Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/4.8),
                  child: const TypingText(
                    words:  ['Virtual Assistant','Chatbot assistant','Intelligent assistant','Digital assistant',],
                   letterSpeed:  Duration(milliseconds: 100),
                   wordSpeed:  Duration(milliseconds: 1000),
                   style: TextStyle(fontSize: 18,
                       color: Colors.green,
                       fontWeight: FontWeight.bold),),
                ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height:55 ,
                    width: 330,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                    child: InkWell(
                      onTap: ()async{
                        getpremiumstatus();
                        isSubscribed?Navigator.push(context, MaterialPageRoute(builder: (context) =>const AIVA_Homepage(),)):
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Subscribe',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 180, // Adjust height according to your needs
                                      width: 330,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Stack(
                                        children: [
                                          Image(
                                            image: AssetImage('assets/images/AIVA_premium.jpg'),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                          Positioned.fill(
                                            child: Center(
                                              child: Text(
                                                'Premium+',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Container(
                                      height: 200, // Adjust height according to your needs
                                      width: 330,
                                      decoration: BoxDecoration(color: Colors.grey.shade300),
                                      child: const SingleChildScrollView(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(padding: EdgeInsets.only(left:0.0)),
                                                  Text(
                                                    '\nEnhanced Features',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Text('Edit Posts',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500
                                                  ),),
                                                  Spacer(),
                                                  Icon(Icons.check,color: Colors.green,),
                                                  Padding(padding:EdgeInsets.only(right: 10.0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Text('Longer Posts',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500
                                                  ),),
                                                  Spacer(),
                                                  Icon(Icons.check,color: Colors.green,),
                                                  Padding(padding:EdgeInsets.only(right: 10.0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Text('Undo Posts',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500
                                                  ),),
                                                  Spacer(),
                                                  Icon(Icons.check,color: Colors.green,),
                                                  Padding(padding:EdgeInsets.only(right: 10.0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Text('Post Longer Videos',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500
                                                  ),),
                                                  Spacer(),
                                                  Icon(Icons.check,color: Colors.green,),
                                                  Padding(padding:EdgeInsets.only(right: 10.0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Text('Top Articles',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500
                                                  ),),
                                                  Spacer(),
                                                  Icon(Icons.check,color: Colors.green,),
                                                  Padding(padding:EdgeInsets.only(right: 10.0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Text('Background Video Playback',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500
                                                  ),),
                                                  Spacer(),
                                                  Icon(Icons.check,color: Colors.green,),
                                                  Padding(padding:EdgeInsets.only(right: 10.0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Text('Reader',style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500
                                                  ),),
                                                   Spacer(),
                                                  Icon(Icons.check,color: Colors.green,),
                                                  Padding(padding:EdgeInsets.only(right: 10.0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 100,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue,width: 2)
                                      ),
                                      child: const Column(
                                        children: [
                                          Row(
                                            children: [
                                              Padding(padding: EdgeInsets.only(left: 20.0)),
                                              Text('\nAnnual Plan',style: TextStyle(
                                                color: Colors.black,fontWeight: FontWeight.w300
                                              ),),
                                              Spacer(),
                                              Text('\nSAVE 12%',style: TextStyle(
                                                  color: Colors.green,fontWeight: FontWeight.w500
                                              ),),
                                              Padding(padding: EdgeInsets.only(right: 20.0))
                                            ],
                                          ),
                                          Text('\n18000 INR/year',style: TextStyle(
                                              color: Colors.black,fontWeight: FontWeight.bold
                                          ),),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height:40 ,
                                      width: 330,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black,
                                      ),
                                      child: InkWell(
                                        onTap: ()async{
                                          await createOrder();
                                          Razorpay razorpay = Razorpay();
                                          var options = {
                                            'key': Apikeys.razorpaykeyid,
                                            'amount': 1000000, // amount in the smallest currency unit
                                            'timeout': 300,
                                            'name': 'WingedWords',
                                            'order_id':Orderid,
                                            'description': 'Payment for AIVA',
                                            'theme': {
                                              'color': '#FF0000',
                                            },
                                          };

                                          razorpay.open(options);
                                          razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response)async{
                                            print('paid');
                                            await _firestore.collection('Payment IDs').doc(user!.uid).set({
                                              'IDs': FieldValue.arrayUnion([
                                                {
                                                  'Payment': response.paymentId,
                                                  'Date Payment':DateTime.now(),
                                                  'Price':1800000
                                                } // corrected syntax
                                              ])
                                            },SetOptions(merge: true));
                                            await _firestore.collection('Premium Subscribers').doc(user!.uid).set(
                                                {
                                                  'Premium':true,
                                                  'Date Of Purchase':FieldValue.serverTimestamp(),
                                                  'Purchase ID':response.paymentId,
                                                  'Order ID':Orderid
                                                });
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => AIVA_Homepage()));
                                          });
                                        },
                                        child:const Center(
                                          child: Text('Upgrade & Pay',style: TextStyle(color: Colors.white,fontSize:15,fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child:const Center(
                        child: Text('Start Conversation',style: TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
