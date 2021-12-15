import 'package:iBrowser/PoJo/HistoryModel.dart';
import 'package:iBrowser/Service/SQFlite/DatabaseHelper.dart';

class DBQueries {
  final dbHelper = DatabaseHelper.instance;

  insertHistory(String? title, String? url, String? favicon) async {
    // row to insert
    Map<String, dynamic> row = {
      // DatabaseHelper.columnHistoryId: 1,
      DatabaseHelper.columnHistoryTitle: title,
      DatabaseHelper.columnHistoryUrl: url,
      DatabaseHelper.columnHistoryIcon: favicon,
      DatabaseHelper.columnHistoryDate: DateTime.now().toString(),
    };
    try {
      await dbHelper.insert(row);
    } catch (e) {
      print("db error $e}");
    }
  }

  Future<List<HistoryModel>> getHistory() async {
    List<HistoryModel> history = [];
    final allRows = await dbHelper.queryAllRows();
    allRows.forEach((row) {
      HistoryModel model = new HistoryModel(
          id: row[DatabaseHelper.columnHistoryId],
          title: row[DatabaseHelper.columnHistoryTitle],
          url: row[DatabaseHelper.columnHistoryUrl],
          favicon: row[DatabaseHelper.columnHistoryIcon],
          date: row[DatabaseHelper.columnHistoryDate]);
      history.add(model);
    });
    history.sort((a, b) => b.id!.compareTo(a.id!));
    return history;
  }

  Future<void> deleteHistory(String id) async {
    // Assuming that the number of rows is the id for the last row.
    //final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    // print('deleted $rowsDeleted row(s): row $id');
  }
}
