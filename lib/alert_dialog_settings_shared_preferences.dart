import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedRef extends StatefulWidget {

  final Function(bool) onNotificationSettingChanged;

  const SharedRef({Key? key,required this.onNotificationSettingChanged})
  : super(key: key);

  @override
  State<SharedRef> createState() => _SharedRefState();

  //getbool method here
  Future<bool> getBool() async{

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
    bool savedValue = await widget.getBool();
    setState(() {
      setRemainder = savedValue;
    });
  }

  //static const SharedPreference = "bool Shared preferences";

  Future setBool(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<bool> getBool() async{

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  // static Future<bool> getBool() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool(key) ?? false;
  // }

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
                  onChanged: (value) {
                    setState(() {
                      //it receives new value from the checkbox, if it null it defaults to false
                      setRemainder = value ?? false;
                      setBool(setRemainder);
                      //to update value in shared preferences based on new state of check box

                      widget.onNotificationSettingChanged(setRemainder);
                      //Enable or Disable the Notification trigger button
                    });
                  })
            ],
          ),
        ],
      ),
      // actions: [
      //   TextButton(
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //         print('Cancel Button Pressed');
      //       },
      //       child: Text('Cancel')),
      //   TextButton(
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //         print('Ok Button Pressed');
      //         print('$setRemainder');
      //       },
      //       child: Text('OK'))
      // ],
    );
  }
}
