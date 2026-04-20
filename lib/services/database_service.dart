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
      version: 2, // Incremented version for banners table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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

    await db.execute('''
      CREATE TABLE banners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_url TEXT NOT NULL,
        title TEXT,
        link TEXT,
        status INTEGER DEFAULT 1
      )
    ''');

    // Insert default sliders
    final List<String> defaultSliders = [
      'assets/images/slider/fruit.png',
      'assets/images/slider/fresh.png',
      'assets/images/slider/dairy.png',
      'assets/images/slider/supply_chain_1.png',
      'assets/images/slider/supply_chain_2.png',
    ];

    for (var image in defaultSliders) {
      await db.insert('sliders', {
        'image_url': image,
        'title': 'Local Slider',
        'link': '',
        'status': 1,
      });
    }

    // Insert default banner
    await db.insert('banners', {
      'image_url': 'assets/images/shop_ad.png',
      'title': 'Shop Advertisement',
      'link': '',
      'status': 1,
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE banners (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          image_url TEXT NOT NULL,
          title TEXT,
          link TEXT,
          status INTEGER DEFAULT 1
        )
      ''');
      
      await db.insert('banners', {
        'image_url': 'assets/images/shop_ad.png',
        'title': 'Shop Advertisement',
        'link': '',
        'status': 1,
      });
    }
  }

  // Slider Methods
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
    return List.generate(maps.length, (i) => SliderImage.fromJson(maps[i]));
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
    return await db.delete('sliders', where: 'id = ?', whereArgs: [id]);
  }

  // Banner Methods
  Future<int> insertBanner(SliderImage banner) async {
    final db = await database;
    return await db.insert('banners', {
      'image_url': banner.imageUrl,
      'title': banner.title,
      'link': banner.link,
      'status': banner.status,
    });
  }

  Future<List<SliderImage>> getBanners() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('banners');
    return List.generate(maps.length, (i) => SliderImage.fromJson(maps[i]));
  }

  Future<int> updateBanner(SliderImage banner) async {
    final db = await database;
    return await db.update(
      'banners',
      {
        'image_url': banner.imageUrl,
        'title': banner.title,
        'link': banner.link,
        'status': banner.status,
      },
      where: 'id = ?',
      whereArgs: [banner.id],
    );
  }

  Future<int> deleteBanner(int id) async {
    final db = await database;
    return await db.delete('banners', where: 'id = ?', whereArgs: [id]);
  }
}
