import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:birthday_notification_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'contact_details_list_screen.dart';
import 'contact_details_model.dart';
import 'database_helper.dart';

// final DatabaseHelper dbHelper = new DatabaseHelper();
final dbHelper = DatabaseHelper();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.initialization();

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

  if (!await AwesomeNotifications().isNotificationAllowed()) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
  //main code for duration
  // Schedule the background task
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(
    const Duration(seconds: 5), // Schedule the task every day
    0, // ID for the alarm
    _checkAndSendNotifications,
    wakeup: true,
    rescheduleOnReboot: true,
  );


}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}):super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

void _checkAndSendNotifications() async {
  try {
    DateTime currentDate = DateTime.now();

    // Fetch your contact details from the database
    List<ContactDetailsModel> contactDetailsList = await dbHelper.getAllContactDetails();

    for (var contact in contactDetailsList) {
      DateTime contactDob = DateTime.parse(contact.dob);

      if (contactDob.month == currentDate.month &&
          contactDob.day == currentDate.day) {
        // Trigger notification for this contact
        _triggerNotification(contact.name);
      }
    }
  } catch(e){
    print('Error during background task: $e');
  }
}

  void _triggerNotification(String contactName) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'high_importance_channel',
        title: 'Birthday Notification',
        body: 'Today is the birthday of $contactName!',
      ),
    );
  }




