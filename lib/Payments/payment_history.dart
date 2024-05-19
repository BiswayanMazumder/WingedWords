import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wingedwords/api%20keys/api_keys.dart';

class Payment_History extends StatefulWidget {
  const Payment_History({Key? key}) : super(key: key);

  @override
  State<Payment_History> createState() => _Payment_HistoryState();
}

class _Payment_HistoryState extends State<Payment_History> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> paymentIdsList = [];
  List<String> paymentDatesList = []; // Change to store dates as strings
  List<int> pricesList = [];
  bool reverseOrder = false;
  Future<void> fetchPayments() async {
    final user = _auth.currentUser;
    final firestore = FirebaseFirestore.instance;
    // Fetch data
    final querySnapshot =
    await firestore.collection('Payment IDs').doc(user!.uid).get();
    if (querySnapshot.exists) {
      final List<dynamic> paymentIDs = querySnapshot.data()?['IDs'];
      List<String> updatedPaymentIdsList = [];
      List<String> updatedPaymentDatesList = [];
      List<int> updatedPricesList = [];
      for (var paymentData in paymentIDs) {
        // Extract individual attributes
        String paymentId = paymentData['Payment'];
        DateTime paymentDate =
        paymentData['Date Payment'].toDate(); // Convert Timestamp to DateTime
        int price = paymentData['Price'];
        String formattedDate =
        DateFormat('EEEE, dd/MM/yyyy').format(paymentDate);
        updatedPaymentIdsList.add(paymentId);
        updatedPaymentDatesList.add(formattedDate);
        updatedPricesList.add(price);
      }
      // Reverse the lists if required
      if (reverseOrder) {
        updatedPaymentIdsList = updatedPaymentIdsList.reversed.toList();
        updatedPaymentDatesList = updatedPaymentDatesList.reversed.toList();
        updatedPricesList = updatedPricesList.reversed.toList();
      }
      setState(() {
        paymentIdsList = updatedPaymentIdsList;
        paymentDatesList = updatedPaymentDatesList;
        pricesList = updatedPricesList;
      });
      print('Payment IDs: $paymentIdsList');
      print('Payment Dates: $paymentDatesList');
      print('Prices: $pricesList');
    } else {
      print('Document does not exist');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20, right: 20),
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     child: Row(
          //       children: List.generate(
          //         4,
          //             (index) => Padding(
          //           padding: EdgeInsets.only(right: 20), // Add spacing between items
          //           child: Container(
          //             height: 160,
          //             width: MediaQuery.of(context).size.width - 50,
          //             decoration: BoxDecoration(
          //               color: index % 2 == 0 ? Colors.red : Colors.blueAccent.shade100,
          //               borderRadius: const BorderRadius.all(Radius.circular(20)),
          //             ),
          //             child: InkWell(
          //               onTap: () {
          //                 print(index);
          //               },
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 30,
          // ),
          const Row(
            children: [
              Padding(padding: EdgeInsets.only(left: 40)),
              Text(
                'Latest',
                style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.w300),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Padding(padding: EdgeInsets.only(left: 40)),
              const Text(
                'Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  // Toggle reverse order
                  setState(() {
                    reverseOrder = !reverseOrder;
                    fetchPayments(); // Fetch data again to update the lists
                  });
                },
                child:  Icon(
                  reverseOrder?Icons.arrow_upward:Icons.arrow_downward,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: paymentIdsList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.9),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                          color: Colors.white70,
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                        ),
                        child: InkWell(
                          onTap:(){
                            print(index);
                          },
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  const Padding(padding: EdgeInsets.only(left: 20)),
                                  const Text(
                                    'WingedWords AIVA Subscription',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      '-₹${((pricesList[index]) ~/ 100)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Padding(padding: EdgeInsets.only(left: 20)),
                                  Text(
                                    ' ${paymentDatesList[index]}',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
