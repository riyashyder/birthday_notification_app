
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contact_details_form_screen.dart';



void main() {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'high_importance_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification Channel For basic tests',
      )
    ],
  );
  runApp(const MyApplication());
}

class MyApplication extends StatelessWidget {
  const MyApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ContactDetailsFormScreen(),
    );
  }
}

class Homepagemain extends StatefulWidget {
  const Homepagemain({super.key});

  @override
  State<Homepagemain> createState() => _HomepagemainState();
}

class _HomepagemainState extends State<Homepagemain> {
  bool isNotificationEnabled = false; //check
  //bool setRemainder = false;

  @override
  void initState(){
    AwesomeNotifications().isNotificationAllowed().then((isAllowed){
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
      //Load the settings when screen is initialized
      _loadSettings();
    });
    super.initState();
  }

  void _loadSettings() async{
    //Load the value of isNotificationEnabled from SharedPreferences
  bool savedValue = await SharedRef.getBool();
  setState(() {
    isNotificationEnabled = savedValue;
  });


  }

  void triggerNotification() {
    if (isNotificationEnabled) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'high_importance_channel',
          title: 'Simple Notification',
          body: 'Today is your Friend Birthday',
        ),
      );
    }
  }
  void showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SharedRef(onNotificationSettingChanged: (value) {
          setState(() {
            isNotificationEnabled = value;
          });
          if(isNotificationEnabled){
            // If the checkbox is checked, trigger the notification
            triggerNotification();
          }
          else{
            AwesomeNotifications().cancelAllSchedules();
          }
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Birthday Remainder'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showSettingsDialog(context);
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed:() {
            if(isNotificationEnabled){
              triggerNotification();
            }else{
              print('Notifications are not enabled');
            }
          },
          child: Text('Trigger Notification'),
        ),
      ),
    );
  }

}

class SharedRef extends StatefulWidget {

  final Function(bool) onNotificationSettingChanged;

  const SharedRef({Key? key,required this.onNotificationSettingChanged})
      : super(key: key);

  @override
  State<SharedRef> createState() => _SharedRefState();

  //getbool method here
  static Future<bool> getBool() async{

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_SharedRefState.key) ?? false;
  }

}

class _SharedRefState extends State<SharedRef> {
  bool setRemainder = false;
  static const String key = "settings_key";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    bool savedValue = await SharedRef.getBool();
    setState(() {
      setRemainder = savedValue;
    });
  }

  //static const SharedPreference = "bool Shared preferences";

  Future setBool(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);

    //only update setRemainder when value is true


  }

  Future<bool>getBool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Birthday Remainder Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Set Remainder'),
              Checkbox(
                  value: setRemainder,
                  onChanged: (value) async {
                    setState(() {
                      //it receives new value from the checkbox, if it null it defaults to false
                      setRemainder = value ?? false;
                      //to update value in shared preferences based on new state of check box
                      //Enable or Disable the Notification trigger button
                    });
                    await setBool(setRemainder);
                    widget.onNotificationSettingChanged(setRemainder);
                  })
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              print('Cancel Button Pressed');
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              print('Ok Button Pressed');
              print('$setRemainder');
            },
            child: Text('OK'))
      ],
    );
  }
}

