import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  // Hàm createTables:
  // Hàm này được sử dụng để tạo bảng data trong cơ sở dữ liệu. Bảng data chứa các cột như id, title, desc, và createdAt.
  // id là một số nguyên tự tăng, là khóa chính của bảng.
  // title và desc là các cột dữ liệu văn bản.
  // createdAt là một cột thời gian, nó sẽ tự động lưu thời gian tạo bản ghi.
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE data(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    desc TEXT,
    createdAt TIMESTAMP NOT  NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  // Hàm db:
  // Hàm này sử dụng để mở hoặc tạo một cơ sở dữ liệu với tên "database_name.db" và phiên bản 1.
  // Nếu cơ sở dữ liệu chưa tồn tại, hàm onCreate sẽ được gọi để tạo bảng data sử dụng hàm createTables.
  static Future<sql.Database> db() async {
    return sql.openDatabase("database_name.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  // Hàm createData:
  // Hàm này sử dụng để thêm một bản ghi mới vào bảng data.
  // Nó nhận các thông tin title và desc, và sau đó thêm chúng vào bảng. Nếu bản ghi có cùng id đã tồn tại, nó sẽ thay thế bản ghi đó.
  static Future<int> createData(String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {"title": title, "desc": desc};
    final id = await db.insert("data", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Hàm getData:
  // Hàm này sử dụng để truy vấn tất cả các bản ghi trong bảng data và trả về một danh sách các dòng dữ liệu dưới dạng List<Map<String, dynamic>>.
  static Future<List<Map<String, dynamic>>> getData() async {
    final db = await SQLHelper.db();
    return db.query("data", orderBy: "id");
  }

  // Hàm getSingleData:
  // Hàm này được sử dụng để truy vấn một bản ghi cụ thể với id cho trước và trả về một danh sách với một bản ghi duy nhất.
  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await SQLHelper.db();
    return db.query("data", where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Hàm updateData:
  // Hàm này sử dụng để cập nhật thông tin của một bản ghi cụ thể trong bảng data.
  // Nó nhận id, title, và desc mới, sau đó cập nhật bản ghi tương ứng. Thời gian createdAt cũng được cập nhật thành thời gian hiện tại.
  static Future<int> updateData(int id, String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {
      "title": title,
      "desc": desc,
      "createdAt": DateTime.now().toString()
    };
    final result =
        await db.update("data", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Hàm deleteData:
  // Hàm này sử dụng để xóa một bản ghi cụ thể với id cho trước khỏi bảng data.
  // Nếu xảy ra lỗi trong quá trình xóa, nó sẽ in ra thông báo lỗi.
  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("data", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("catch $e");
    }
  }
}
