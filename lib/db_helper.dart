import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE class_tracker (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        subject TEXT NOT NULL,
        teacher TEXT NOT NULL,
        classDate TIMESTAMP NOT NULL,
        clasStart TIMESTAMP NOT NULL,
        classEnd TIMESTAMP NOT NULL,
        feesType TEXT NOT NULL DEFAULT 'POSTPAID',
        status TEXT NOT NULL DEFAULT 'CURRENT',
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
  static Future<dynamic> alterTable(sql.Database database) async {
    var count = await database.execute("ALTER TABLE class_tracker ADD "
        "COLUMN status TEXT NOT NULL DEFAULT 'ACTIVE';");
    print(await database.query("class_tracker"));
    return count;
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'class_tracker.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createItem(String subject, String teacher, String feesType, String classDate, String clasStart, String classEnd) async {
    final db = await SQLHelper.db();

    final data = {
      'subject': subject,
      'teacher': teacher,
      'classDate': classDate,
      'clasStart': clasStart,
      'classEnd': classEnd,
      'feesType': feesType,
      'createdAt': DateTime.now().toString()};
    final id = await db.insert('class_tracker', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('class_tracker', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItemsByStatus(String status) async {
    final db = await SQLHelper.db();
    return db.query('class_tracker', where: "status = ?", whereArgs: [status], orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('class_tracker', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
      int id, String subject, String teacher, String feesType, String classDate, String clasStart, String classEnd) async {
    final db = await SQLHelper.db();

    final data = {
      'subject': subject,
      'teacher': teacher,
      'classDate': classDate,
      'clasStart': clasStart,
      'classEnd': classEnd,
      'feesType': feesType,
      'createdAt': DateTime.now().toString()
    };

    final result =
    await db.update('class_tracker', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Update an item status by id
  static Future<int> updateItemStatus(int id, String status) async {
    final db = await SQLHelper.db();

    final data = {
      'status': status
    };

    final result =
    await db.update('class_tracker', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Update an item status by id list
  static Future<int> updateItemsStatus(List<int> ids, String status) async {
    final db = await SQLHelper.db();

    final data = {
      'status': status
    };

    final result =
    await db.update('class_tracker', data, where: "id in (${ids.join(', ')})");
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("class_tracker", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  // Delete multiple items
  static Future<void> deleteItems(List<int> ids) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("class_tracker", where: "id in (${List.filled(ids.length, '?').join(',')})", whereArgs: ids);
    } catch (err) {
      debugPrint("Something went wrong when deleting an items: $err");
    }
  }
}
