import 'dart:io';
import 'package:flutter/services.dart';
import '../models/word_model.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

class DictionaryDatabase {
  //Đại diện cho database gồm tên cơ sở dữ liệu, tên bảng, tên cột;
  final String DB_NAME = "en_vi_dict.db";
  final String DB_TABLE = "en_vi_dict";
  final String ID = "word_id";
  final String WORD = "word";
  final String PRONOUNCE = "pronounce";
  final String MEANING = "meaning";

  //Khi database đã được dùng rồi và khi mở lại thì chỉ lấy sẵn và dùng
  static final DictionaryDatabase _instance = DictionaryDatabase._();
  DictionaryDatabase._();

  factory DictionaryDatabase() {
    return _instance;
  }

  //Dùng biến static để database khi bị huỷ khi chuyển qua màn hình khác và tồn tại cho đến khi tắt ứng dụng
  static Database? _database;

  //Gọi database khi thực hiện 1 chức năng nào đó
  Future<Database?> get db async {
    if(_database != null)
      return _database;
    _database = await init();
    return _database;
  }

  //Có database sẵn
  Future<Database?> init() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, DB_NAME);

    //Kiểm tra nếu database tồn tại
    var exists = await databaseExists(path);
    if(!exists) {
      //Sẽ xảy ra duy nhất khi khởi chạy ứng dụng lần đầu
      print("Creating new copy from asset");
      //Đảm bảo rằng thư mục cha đã tồn tại
      try {
        await Directory(dirname(path)).create(recursive: true);
      }
      catch(_) {}
      //Sao chép từ asset
      ByteData data = await rootBundle.load(join("assets/databases", DB_NAME));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes);
      //Ghi và xoá các bytes đã ghi
      await File(path).writeAsBytes(bytes, flush: true);
    }
    else
      print("Opening existing database");

    //Mở database
    var db = await openDatabase(path, readOnly: true);
    return db;
  }

  //CRUD: Create, Read, Update, Delete
  //Thêm từ vào
  Future<int> addWord(WordModel wordModel) async {
    var client = await db;
    return client!.insert(DB_TABLE, wordModel.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //Lấy từ theo id
  Future<WordModel?> fetchWordId(int id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps = client!.query(DB_TABLE, where: '$ID = ?', whereArgs: [id]);
    var maps = await futureMaps;
    if (maps.length != 0)
      return WordModel.fromJson(maps.first);
    return null;
  }

  //Lấy từ theo từ
  Future<WordModel?> fetchWordByWord(String word) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
    client!.query(DB_TABLE, where: '$WORD = ?', whereArgs: [word]);
    var maps = await futureMaps;
    if (maps.length != 0)
      return WordModel.fromJson(maps.first);
    return null;
  }

  //Lấy hết tất cả các từ
  Future<List<WordModel>> fetchAll() async {
    var client = await db;
    var res = await client!.query(DB_TABLE);
    if (res.isNotEmpty) {
      var words = res.map((wordMap) => WordModel.fromJson(wordMap)).toList();
      return words;
    }
    return [];
  }

  //Cập nhật lại từ
  Future<int> updateWord(WordModel newWord) async {
    var client = await db;
    return client!.update(DB_TABLE, newWord.toJson(), where: '$ID = ?', whereArgs: [newWord.word_id], conflictAlgorithm: ConflictAlgorithm.replace);
  }
  //Xoá từ
  Future<int> removeWord(int id) async {
    var client = await db;
    return client!.delete(DB_TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  //Tìm kiếm từ
  Future<List<WordModel>> searchEnglishResults(String searchWord) async {
    var client = await db;
    var response = await client!.query(DB_TABLE, where: '$WORD like ?', whereArgs: ['$searchWord%%'], limit: 14);
    List<WordModel> list = response.map((c) => WordModel.fromJson(c)).toList();
    return list;
  }

  //Đóng database
  Future closeDb() async {
    var client = await db;
    client!.close();
  }
}