import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:birthday_notification_app/contact_details_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'contact_details_list_screen.dart';
import 'database_helper.dart';
import 'main.dart';

class ContactDetailsFormScreen extends StatefulWidget {
  //final VoidCallback checkAndSendNotifications;
  //const ContactDetailsFormScreen({Key? key, required this.checkAndSendNotifications}) : super(key: key);
  const ContactDetailsFormScreen({Key? key}) : super(key: key);

  @override
  State<ContactDetailsFormScreen> createState() =>
      _ContactDetailsFormScreenState();
}

class _ContactDetailsFormScreenState extends State<ContactDetailsFormScreen> {
  final _formField = GlobalKey<FormState>();
  var _nameController = TextEditingController();
  var _mobileNumberController = TextEditingController();
  var _emailIdController = TextEditingController();
  var _dobController = TextEditingController();

  DateTime _dateTime = DateTime.now();
  final stt.SpeechToText _speech = stt.SpeechToText();

  _selectTodoDate(BuildContext context) async {
    var _pickedDate = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (_pickedDate != null) {
      setState(() {
        _dateTime = _pickedDate;
        _dobController.text = DateFormat("dd-MM-yyyy").format(_dateTime);
      });
    }
  }

  _startSpeechToText() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
      },
      onError: (error) {
        print('Speech recognition error: $error');
      },
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _nameController.text = result.recognizedWords;
            });
          }
        },
      );
    } else {
      print('Speech recognition not available');
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contact Details Form'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formField,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          labelText: 'Contact Name',
                          hintText: 'Enter Contact Name',
                          suffixIcon: IconButton(
                            onPressed: () {
                              _startSpeechToText();
                            },
                            icon: Icon(Icons.mic),
                          )),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Name';
                        }
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          labelText: 'Mobile Number',
                          hintText: 'Enter Mobile Number'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Mobile Number';
                        }
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _emailIdController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          labelText: 'Email ID',
                          hintText: 'Enter Email ID'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Email ID';
                        }
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                          labelText: 'date of birth',
                          hintText: 'select DOB',
                          prefixIcon: InkWell(
                            onTap: () {
                              _selectTodoDate(context);
                            },
                            child: Icon(Icons.calendar_today),
                          )),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter DOB';
                        }
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('--------------> Save Button Clicked');
                        _save();
                      },
                      child: Text('Save'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _save() async {
    if (_formField.currentState!.validate()) {
      print('--------------> _save');
      print('--------------> Contact Name: ${_nameController.text}');
      print('--------------> Mobile Number: ${_mobileNumberController.text}');
      print('--------------> Email ID: ${_emailIdController.text}');
      print('-------------> Date of Birth ${_dobController.text}');

      Map<String, dynamic> row = {
        DatabaseHelper.colName: _nameController.text,
        DatabaseHelper.colMobileNo: _mobileNumberController.text,
        DatabaseHelper.colEmailID: _emailIdController.text,
        DatabaseHelper.colDob: _dobController.text,
      };

      final result = await dbHelper.insertContactDetails(
          row, DatabaseHelper.contactDetailsTable);
      debugPrint('--------> Inserted Row Id: $result');

      if (result > 0) {
        Navigator.pop(context, ContactDetailsModel);
        _showSuccessSnackBar(context, 'Saved');

        // Removed the date condition for sending notifications
        setState(() {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ContactDetailsListScreen()));
        });
        //_checkAndSendNotifications();
      }
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void _triggerNotification(String contactName) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10,
          channelKey: 'high_importance_channel',
          title: 'Birthday Notification',
          body: 'Today is the birthday of $contactName!'),
    );
  }
}
