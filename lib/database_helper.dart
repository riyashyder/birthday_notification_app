import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'contact_details_model.dart';

class DatabaseHelper {
  static const _databaseName = "ContactDetailsDB.db";
  static const _databaseVersion = 1; // _onUpgrade

  // Contact Details table
  static const contactDetailsTable = 'contact_details_table';

  static const columnId = '_id';

  // Contact Details table column
  static const colName = '_name';
  static const colMobileNo = '_mobileNo';
  static const colEmailID = '_emailID';
  static const colDob = '_dob';

  late Database _db;

  Future<void> initialization() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    // d:/flutterdb - path
    // d:/flutterdb/ContactDetailsDB.db
    final path = join(documentsDirectory.path, _databaseName);

    print(documentsDirectory);
    print(path);

    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<List<ContactDetailsModel>> getAllContactDetails() async {
    List<Map<String, dynamic>> result = await queryAllRows(contactDetailsTable);

    return result.map((row) {
      return ContactDetailsModel(
        row[columnId],
        row[colName],
        row[colMobileNo],
        row[colEmailID],
        row[colDob],
      );
    }).toList();
  }

  Future _onCreate(Database database, int version) async {

    // create table contact_details_table(_id integer primary key, _name text, _mobileNo text, _emailID text)
    await database.execute('''
          CREATE TABLE $contactDetailsTable (
            $columnId INTEGER PRIMARY KEY,
            $colName TEXT,
            $colMobileNo TEXT,
            $colEmailID TEXT,
            $colDob TEXT
          )
          ''');
  }

  _onUpgrade(Database database, int oldVersion, int newVersion) async{
    await database.execute('drop table $contactDetailsTable');
    _onCreate(database, newVersion);
  }

  Future<int> insertContactDetails(Map<String, dynamic> row, String tableName) async {
    return await _db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    // select * from contact_details_table;
    return await _db.query(tableName);
  }

  Future<int> updateContactDetails(Map<String, dynamic> row, String tableName) async {
    int id = row[columnId];
    return await _db.update(
      tableName,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteContactDetails(int id, String tableName) async {
    return await _db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}