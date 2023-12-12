import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'alert_dialog_settings_shared_preferences.dart';
import 'contact_details_form_screen.dart';
import 'contact_details_model.dart';
import 'database_helper.dart';
import 'edit_contact_details_form_screen.dart';
import 'main.dart';

class ContactDetailsListScreen extends StatefulWidget {
  const ContactDetailsListScreen({Key? key}) : super(key: key);

  @override
  State<ContactDetailsListScreen> createState() =>
      _ContactDetailsListScreenState();
}

class _ContactDetailsListScreenState extends State<ContactDetailsListScreen> {
  late List<ContactDetailsModel> _contactDetailsList;
  late SharedRef _sharedRef;
  bool isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _sharedRef = SharedRef(onNotificationSettingChanged: (value) {
      //handle notification setting changed if needed
    });
    _getAllContactDetails();

    //check for the notifications when the screen is initialized
    _checkAndSendNotifications();

    // Schedule the background task to run daily
    _scheduleBackgroundTask();
  }

  void _getAllContactDetails() async {
    _contactDetailsList = <ContactDetailsModel>[];

    var _contactDetailRecords =
        await dbHelper.queryAllRows(DatabaseHelper.contactDetailsTable);

    _contactDetailRecords.forEach((row) {
      setState(() {
        print(row['_id']);
        print(row['_name']);
        print(row['_mobileNo']);
        print(row['_emailID']);
        print(row['_dob']);

        var contactDetailsModel = ContactDetailsModel(
          row['_id'],
          row['_name'],
          row['_mobileNo'],
          row['_emailID'],
          row['_dob'],
        );

        _contactDetailsList.add(contactDetailsModel);
      });
    });
    // After loading contact details, check and send notifications
    _checkAndSendNotifications();
  }

  _triggerNotification(String contactName, int contactId) async {
    bool isNotificationEnabled = await _sharedRef.getBool();

    if (isNotificationEnabled) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: contactId,
          channelKey: 'high_importance_channel',
          title: 'Birthday Notification',
          body: 'Today is the birthday of $contactName!',
        ),
      );
    }
  }

  _checkAndSendNotifications() async {
    //Retreive the stored setting for sending notifications

    bool isNotificationEnabled = await _sharedRef.getBool();

    print(isNotificationEnabled);

    if (isNotificationEnabled) {
      DateTime currentDate = DateTime.now();

      // Group contacts by birthday date
      //Map<String, List<ContactDetailsModel>> groupedContacts = {};

      print(currentDate);

      //Iterate through contact details and send notifications if the date matches
      for (var contact in _contactDetailsList) {
        DateTime contactDob = DateFormat("dd-MM-yyyy").parse(contact.dob);

        print(contactDob);
        print(contact);

        print(contact.name);
        print(currentDate.month);
        print(currentDate.day);
        print(contactDob.month);
        print(contactDob.day);

        if (contactDob.month == currentDate.month &&
            contactDob.day == currentDate.day) {
          // Trigger notification for this contact
          _triggerNotification(contact.name, contact.id ?? 0);
        }

        //   if (!groupedContacts.containsKey(formattedDob)) {
        //     groupedContacts[formattedDob] = [];
        //   }
        //
        //   groupedContacts[formattedDob]!.add(contact);
        // }
        // // Iterate through groups and send notifications
        // for (var group in groupedContacts.values) {
        //   if (group.isNotEmpty &&
        //       group[0].dob != null && // Check if the first contact has a valid date
        //       group[0].dob!.isNotEmpty &&
        //       group[0].dob!.length >=
        //           5) { // Check if the date has at least MM-dd format
        //     DateTime groupDob = DateFormat("MM-dd").parse(group[0].dob!);
        //
        //     if (groupDob.month == currentDate.month &&
        //         groupDob.day == currentDate.day) {
        //       // Trigger notification for this group of contacts
        //       _triggerGroupNotification(
        //           group.map((contact) => contact.name).toList());
        //     }
        //   }
      }
    }
  }

  _scheduleBackgroundTask() async {
    const duration = Duration(seconds: 5);

    Future.delayed(duration, () {
      // Reload the screen every 5 seconds
      _reloadScreenAndCheckNotifications();
    });
  }

  void _reloadScreenAndCheckNotifications() {
    if (mounted) {
      setState(() {
        // Reload the screen
        _getAllContactDetails();

        // Check and send notifications
        _checkAndSendNotifications();
      });

      // Schedule the next reload
      _scheduleBackgroundTask();
    }
  }

  _triggerGroupNotification(List<String> contactNames) {
    String names = contactNames.join(", ");
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'high_importance_channel',
        title: 'Birthday Notification',
        body: 'Today is the birthday of $names!',
      ),
    );
  }

  void showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SharedRef(onNotificationSettingChanged: (value) {
          setState(() {
            isNotificationEnabled = value;
          });
        });
      },
    );
  }

  void _checkAndSendNotificationsInBackground() async {
    final dbHelper = DatabaseHelper();
    final contactDetailsList = <ContactDetailsModel>[];

    var contactDetailRecords =
        await dbHelper.queryAllRows(DatabaseHelper.contactDetailsTable);

    contactDetailRecords.forEach((row) {
      var contactDetailsModel = ContactDetailsModel(
        row['_id'],
        row['_name'],
        row['_mobileNo'],
        row['_emailID'],
        row['_dob'],
      );

      contactDetailsList.add(contactDetailsModel);
    });

    DateTime currentDate = DateTime.now();

    for (var contact in contactDetailsList) {
      DateTime contactDob = DateFormat("dd-MM-yyyy").parse(contact.dob);

      if (contactDob.month == currentDate.month &&
          contactDob.day == currentDate.day) {
        // Trigger notification for this contact
        _triggerNotification(contact.name, contact.id ?? 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('BirthdayBliss Notifier',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showSettingsDialog(context);
            },
            icon: Icon(Icons.settings,color: Colors.black,),
          )
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: _contactDetailsList.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(color: Colors.blueAccent,
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () {
                    print('---------->Edit or Delete invoked: Send Data');
                    print(_contactDetailsList[index].id);
                    print(_contactDetailsList[index].name);
                    print(_contactDetailsList[index].mobileNo);
                    print(_contactDetailsList[index].emailID);
                    print(_contactDetailsList[index].dob);

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditContactDetailsFormScreen(),
                      settings: RouteSettings(
                        arguments: _contactDetailsList[index],
                      ),
                    ));
                  },
                  child: ListTile(
                      title: Text(_contactDetailsList[index].name +
                          '\n' +
                          _contactDetailsList[index].mobileNo +
                          '\n' +
                          _contactDetailsList[index].emailID +
                          '\n' +
                          _contactDetailsList[index].dob,style: TextStyle(color: Colors.white),),
                      ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        splashColor: Colors.redAccent,
        onPressed: () {
          print('--------------> Launch Contact Details Form Screen');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ContactDetailsFormScreen()));
        },
        child: Icon(Icons.add,color: Colors.redAccent,),
      ),
    );
  }

}

