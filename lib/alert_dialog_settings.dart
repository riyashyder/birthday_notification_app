import 'package:flutter/material.dart';


class AlertDialogSettings extends StatefulWidget {
  const AlertDialogSettings({super.key});

  @override
  State<AlertDialogSettings> createState() => _AlertDialogSettingsState();
}

class _AlertDialogSettingsState extends State<AlertDialogSettings> {
  bool setRemainder = false;
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
              Checkbox(value: setRemainder, onChanged: (value){
                setState(() {
                  setRemainder = value ?? false;
                });
              })
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();
          print('Cancel Button Pressed');
        }, child: Text('Cancel')),
        TextButton(onPressed: (){
          Navigator.of(context).pop();
          print('Ok Button Pressed');
          print('$setRemainder');
        }, child: Text('OK'))
      ],
    ) ;
  }
}
