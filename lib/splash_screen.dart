import 'dart:async';

import 'package:birthday_notification_app/contact_details_list_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    print('------->initState');

    Timer(
        Duration(seconds: 7),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => ContactDetailsListScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('images/splash_screen_birthday.png'),
                fit: BoxFit.cover,
              ),
            ),
            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //
            //     CircleAvatar(
            //       radius: 150,
            //       backgroundImage: AssetImage(
            //         'images/authorimage.jpeg',
            //       ),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.all(10),
            //       child: Text(
            //         'Success is a lousy teacher',
            //         style: TextStyle(
            //             fontSize: 20,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black),
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }
}
