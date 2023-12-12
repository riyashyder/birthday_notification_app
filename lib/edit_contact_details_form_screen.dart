import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'contact_details_list_screen.dart';
import 'contact_details_model.dart';
import 'database_helper.dart';
import 'main.dart';


class EditContactDetailsFormScreen extends StatefulWidget {
  const EditContactDetailsFormScreen({super.key});

  @override
  State<EditContactDetailsFormScreen> createState() =>
      _EditContactDetailsFormScreenState();
}

class _EditContactDetailsFormScreenState
    extends State<EditContactDetailsFormScreen> {
  var _nameController = TextEditingController();
  var _mobileNumberController = TextEditingController();
  var _emailIdController = TextEditingController();
  var _dobController = TextEditingController();

  DateTime _dateTime = DateTime.now();
  _selectTodoDate(BuildContext context)async{
    var _pickedDate = await showDatePicker(context: context, initialDate: _dateTime, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if(_pickedDate!=null){
      setState(() {
        _dateTime = _pickedDate;
        _dobController.text = DateFormat("dd-MM-yyyy").format(_dateTime);
      });
    }
  }

  // Edit mode
  bool firstTimeFlag = false;
  int _selectedId = 0;

  _deleteFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  print('--------------> Delete Button Clicked');
                  _delete();
                },
                child: const Text('Delete'),
              )
            ],
            title: const Text('Are you sure you want to delete this?'),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // Edit - Receive Data
    if (firstTimeFlag == false) {
      print('---------->once execute');

      firstTimeFlag = true;

      // get data
      final contactDetails =
      ModalRoute.of(context)!.settings.arguments as ContactDetailsModel;

      print('----------->Received Data');

      print(contactDetails.id);
      print(contactDetails.name);
      print(contactDetails.mobileNo);
      print(contactDetails.emailID);
      print(contactDetails.dob);

      _selectedId = contactDetails.id!;

      _nameController.text = contactDetails.name;
      _mobileNumberController.text = contactDetails.mobileNo;
      _emailIdController.text = contactDetails.emailID;
      _dobController.text = contactDetails.dob;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Details Form'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Record',
            onPressed: () {
              print('--------------> Delete Button Clicked');
              _deleteFormDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      labelText: 'Contact Name',
                      hintText: 'Enter Contact Name'),
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
                      labelText: 'Date of Birth',
                      hintText: 'Enter Your DOB',
                  prefixIcon: InkWell(
                    onTap: (){
                      _selectTodoDate(context);
                    },
                    child: Icon(Icons.calendar_today),
                  )),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    print('--------------> Update Button Clicked');
                    _update();
                  },
                  child: Text('Update'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _update() async {
    print('--------------> _update');
    // edit - id
    print('---------------> Selected ID: $_selectedId');

    print('--------------> Contact Name: ${_nameController.text}');
    print('--------------> Mobile Number: ${_mobileNumberController.text}');
    print('--------------> Email ID: ${_emailIdController.text}');
    print('-------------> Date of Birth ${_dobController.text}');

    Map<String, dynamic> row = {
      // edit - id ***
      DatabaseHelper.columnId: _selectedId,
      DatabaseHelper.colName: _nameController.text,
      DatabaseHelper.colMobileNo: _mobileNumberController.text,
      DatabaseHelper.colEmailID: _emailIdController.text,
      DatabaseHelper.colDob: _dobController.text
    };

    final result = await dbHelper.updateContactDetails(
        row, DatabaseHelper.contactDetailsTable);
    debugPrint('--------> Updated Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated');
      setState(() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ContactDetailsListScreen()));
      });
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void _delete() async {
    print('--------------> _delete');

    final result = await dbHelper.deleteContactDetails(
        _selectedId, DatabaseHelper.contactDetailsTable);

    debugPrint('-----------------> Deleted Row Id: $result');

    if (result > 0) {
      _showSuccessSnackBar(context, 'Deleted.');
      Navigator.pop(context);
      setState(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ContactDetailsListScreen()));
      });
    }
  }
}
