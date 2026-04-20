import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sungoods/models/slider_image.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sungoods.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sliders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_url TEXT NOT NULL,
        title TEXT,
        link TEXT,
        status INTEGER DEFAULT 1
      )
    ''');

    // Insert default sliders if needed
    final List<String> defaultImages = [
      'assets/images/slider/fruit.png',
      'assets/images/slider/fresh.png',
      'assets/images/slider/dairy.png',
      'assets/images/slider/supply_chain_1.png',
      'assets/images/slider/supply_chain_2.png',
    ];

    for (var image in defaultImages) {
      await db.insert('sliders', {
        'image_url': image,
        'title': 'Local Slider',
        'link': '',
        'status': 1,
      });
    }
  }

  Future<int> insertSlider(SliderImage slider) async {
    final db = await database;
    return await db.insert('sliders', {
      'image_url': slider.imageUrl,
      'title': slider.title,
      'link': slider.link,
      'status': slider.status,
    });
  }

  Future<List<SliderImage>> getSliders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sliders');

    return List.generate(maps.length, (i) {
      return SliderImage.fromJson(maps[i]);
    });
  }

  Future<int> updateSlider(SliderImage slider) async {
    final db = await database;
    return await db.update(
      'sliders',
      {
        'image_url': slider.imageUrl,
        'title': slider.title,
        'link': slider.link,
        'status': slider.status,
      },
      where: 'id = ?',
      whereArgs: [slider.id],
    );
  }

  Future<int> deleteSlider(int id) async {
    final db = await database;
    return await db.delete(
      'sliders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
