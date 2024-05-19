import 'package:flutter/material.dart';
import 'package:wingedwords/Utils/Colors/Colours.dart';

class FAQ_Page extends StatefulWidget {
  const FAQ_Page({Key? key}) : super(key: key);

  @override
  State<FAQ_Page> createState() => _FAQ_PageState();
}

class _FAQ_PageState extends State<FAQ_Page> {
  final List<String> faqs = [
    'What is WingedWords?',
    'Do I need anything special?',
    'What is a post?',
    // 'What is a Repost?',
    // 'How do I post a picture?',
    // 'Who reads my updates?',
    // 'Can I put my updates on my blog?'
  ];
  final List<String>faqanswers=[
    'WingsWords is a service for friends, family, and coworkers to communicate and stay connected through the exchange of quick, '
        'frequent messages. People post posts, which may contain photos, videos, links, and text. These messages are posted '
        'to your profile, sent to your followers, and are searchable on WingsWords search. ',
    'All you need to use WingsWords is an internet connection or a mobile phone. Join us here! Once you are in, begin '
        'finding and following accounts whose posts interest you. We will recommend great accounts once you are signed up.',
    'A post is any message posted to WingsWords which may contain photos, videos, links, and text. Click or tap the post button to post'
        ' the update to your profile. Read our Posting a post article for more information.'
  ];
  late List<bool> isOpen; // Track the dropdown state for each item

  @override
  void initState() {
    isOpen = List.generate(faqs.length, (index) => false); // Initialize all dropdowns as closed
    super.initState();
  }

  void toggleDropdown(int index) {
    setState(() {
      isOpen[index] = !isOpen[index]; // Toggle the dropdown state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      child: TextFormField(
                        // You can keep your filterFaqs function here if you want to filter FAQs
                        decoration: const InputDecoration(
                          focusColor: AppColors.creamColor,
                          hoverColor: AppColors.creamColor,
                          hintText: '  Search...',
                          suffixIcon: Icon(Icons.search, color: Colors.grey),
                          hintStyle: TextStyle(
                              fontWeight: FontWeight.w300, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 0.3),
                              borderRadius: BorderRadius.all(Radius.circular(30))),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Column(
              children: List.generate(
                faqs.length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
                  child: Container(
                    height: isOpen[index]?230:80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 0.3, color: Colors.white),
                    ),
                    child: InkWell(
                      onTap: () => toggleDropdown(index), // Toggle dropdown on tap
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 20.0)),
                              Text(
                                faqs[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                isOpen[index] ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                color: Colors.black,
                                size: 35,
                              ),
                              const Padding(padding: EdgeInsets.only(right: 20.0)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0,right: 20.0),
                            child: isOpen[index]?Text(faqanswers[index]):Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
