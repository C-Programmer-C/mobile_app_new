import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'electronics_shop.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS suppliers');
      await db.execute('DROP TABLE IF EXISTS reviews');
      
      await db.execute('''
        CREATE TABLE suppliers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          phone TEXT,
          email TEXT,
          address TEXT,
          rating REAL DEFAULT 0,
          total_products INTEGER DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE reviews(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          user_name TEXT NOT NULL,
          rating REAL NOT NULL,
          comment TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (product_id) REFERENCES products(id),
          FOREIGN KEY (user_id) REFERENCES users(id)
        )
      ''');

      await db.execute('ALTER TABLE products ADD COLUMN supplier_id INTEGER');
      await db.execute('ALTER TABLE products ADD COLUMN original_price REAL');
      await db.execute('ALTER TABLE products ADD COLUMN review_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE products ADD COLUMN brand TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN warranty TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN color TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN dimensions TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN weight TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN is_new INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE products ADD COLUMN is_popular INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE products ADD COLUMN discount REAL');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица пользователей
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT,
        phone TEXT,
        address TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Таблица категорий
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT
      )
    ''');

    // Таблица поставщиков
    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        rating REAL DEFAULT 0,
        total_products INTEGER DEFAULT 0
      )
    ''');

    // Таблица товаров
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        supplier_id INTEGER,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        original_price REAL,
        rating REAL DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        image_url TEXT,
        stock_quantity INTEGER DEFAULT 0,
        specifications TEXT,
        brand TEXT,
        warranty TEXT,
        color TEXT,
        dimensions TEXT,
        weight TEXT,
        is_new INTEGER DEFAULT 0,
        is_popular INTEGER DEFAULT 0,
        discount REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
      )
    ''');

    // Таблица отзывов
    await db.execute('''
      CREATE TABLE reviews(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        user_name TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Таблица корзины
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id),
        UNIQUE(user_id, product_id)
      )
    ''');

    // Таблица заказов
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        shipping_address TEXT,
        phone TEXT,
        order_date TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Таблица элементов заказа
    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Добавляем начальные данные
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Добавляем категории
    await db.insert('categories', {'name': 'Смартфоны', 'icon': '📱'});
    await db.insert('categories', {'name': 'Ноутбуки', 'icon': '💻'});
    await db.insert('categories', {'name': 'Наушники', 'icon': '🎧'});
    await db.insert('categories', {'name': 'Планшеты', 'icon': '📱'});
    await db.insert('categories', {'name': 'Аксессуары', 'icon': '⌚'});

    // Добавляем поставщиков
    final suppliers = [
      {
        'name': 'Apple Store',
        'description': 'Официальный поставщик техники Apple в России',
        'phone': '+7 (800) 555-0001',
        'email': 'info@apple-store.ru',
        'address': 'Москва, ул. Тверская, 1',
        'rating': 4.9,
        'total_products': 15,
      },
      {
        'name': 'Samsung Electronics',
        'description': 'Официальный дистрибьютор Samsung в РФ',
        'phone': '+7 (800) 555-0002',
        'email': 'info@samsung-russia.ru',
        'address': 'Санкт-Петербург, Невский пр., 28',
        'rating': 4.8,
        'total_products': 12,
      },
      {
        'name': 'TechWorld',
        'description': 'Крупный поставщик электроники и аксессуаров',
        'phone': '+7 (800) 555-0003',
        'email': 'sales@techworld.ru',
        'address': 'Москва, ул. Ленинградская, 15',
        'rating': 4.7,
        'total_products': 25,
      },
    ];

    final supplierIds = <int>[];
    for (var supplier in suppliers) {
      final id = await db.insert('suppliers', supplier);
      supplierIds.add(id);
    }

    // Добавляем товары с подробными характеристиками
    final products = [
      // Смартфоны
      {
        'category_id': 1,
        'supplier_id': supplierIds[0],
        'name': 'iPhone 15 Pro',
        'description': 'Смартфон Apple с процессором A17 Pro. Новейший флагман с титановым корпусом, улучшенной камерой и поддержкой USB-C.',
        'price': 99999.0,
        'original_price': 109999.0,
        'rating': 4.8,
        'review_count': 127,
        'image_url': 'assets/images/iphone.jpg',
        'stock_quantity': 10,
        'specifications': 'Экран: 6.1" Super Retina XDR OLED, 2556x1179, 460 ppi\nПроцессор: Apple A17 Pro\nПамять: 256GB\nОЗУ: 8GB\nКамера: 48MP основная, 12MP ультраширокоугольная, 12MP телефото\nБатарея: 3274 mAh\nЦвет: Титан\nВес: 187 г',
        'brand': 'Apple',
        'warranty': '12 месяцев',
        'color': 'Титан',
        'dimensions': '159.9 x 76.7 x 8.25 мм',
        'weight': '187 г',
        'is_new': 1,
        'is_popular': 1,
        'discount': 9.09,
      },
      {
        'category_id': 1,
        'supplier_id': supplierIds[1],
        'name': 'Samsung Galaxy S24 Ultra',
        'description': 'Флагманский смартфон Samsung с S Pen, камерой 200MP и процессором Snapdragon 8 Gen 3. Максимальная производительность и функциональность.',
        'price': 89999.0,
        'original_price': 99999.0,
        'rating': 4.7,
        'review_count': 89,
        'image_url': 'assets/images/ultra.jpg',
        'stock_quantity': 15,
        'specifications': 'Экран: 6.8" Dynamic AMOLED 2X, 3120x1440, 501 ppi\nПроцессор: Snapdragon 8 Gen 3\nПамять: 256GB\nОЗУ: 12GB\nКамера: 200MP основная, 50MP телефото, 12MP ультраширокоугольная, 10MP перископ\nБатарея: 5000 mAh\nЦвет: Титан\nВес: 232 г',
        'brand': 'Samsung',
        'warranty': '12 месяцев',
        'color': 'Титан',
        'dimensions': '162.3 x 79.0 x 8.6 мм',
        'weight': '232 г',
        'is_new': 0,
        'is_popular': 1,
        'discount': 10.0,
      },
      {
        'category_id': 1,
        'supplier_id': supplierIds[1],
        'name': 'Samsung Galaxy S24',
        'description': 'Компактный флагман Samsung с отличной камерой и производительностью. Идеальный баланс размера и функциональности.',
        'price': 69999.0,
        'rating': 4.6,
        'review_count': 156,
        'image_url': 'assets/images/samsung.jpg',
        'stock_quantity': 20,
        'specifications': 'Экран: 6.2" Dynamic AMOLED 2X, 2340x1080, 416 ppi\nПроцессор: Snapdragon 8 Gen 3\nПамять: 128GB\nОЗУ: 8GB\nКамера: 50MP основная, 12MP ультраширокоугольная, 10MP телефото\nБатарея: 4000 mAh\nЦвет: Оникс\nВес: 167 г',
        'brand': 'Samsung',
        'warranty': '12 месяцев',
        'color': 'Оникс',
        'dimensions': '147.0 x 70.6 x 7.6 мм',
        'weight': '167 г',
        'is_new': 0,
        'is_popular': 0,
        'discount': null,
      },
      {
        'category_id': 1,
        'supplier_id': supplierIds[0],
        'name': 'iPhone 14',
        'description': 'Проверенный смартфон Apple с процессором A15 Bionic. Отличное соотношение цена-качество.',
        'price': 69999.0,
        'original_price': 79999.0,
        'rating': 4.5,
        'review_count': 234,
        'image_url': 'assets/images/iphone14.jpg',
        'stock_quantity': 8,
        'specifications': 'Экран: 6.1" Super Retina XDR OLED, 2532x1170, 460 ppi\nПроцессор: Apple A15 Bionic\nПамять: 128GB\nОЗУ: 6GB\nКамера: 12MP основная, 12MP ультраширокоугольная\nБатарея: 3279 mAh\nЦвет: Синий\nВес: 172 г',
        'brand': 'Apple',
        'warranty': '12 месяцев',
        'color': 'Синий',
        'dimensions': '146.7 x 71.5 x 7.80 мм',
        'weight': '172 г',
        'is_new': 0,
        'is_popular': 1,
        'discount': 12.5,
      },
      // Ноутбуки
      {
        'category_id': 2,
        'supplier_id': supplierIds[0],
        'name': 'MacBook Pro M3 14"',
        'description': 'Ноутбук Apple для профессионалов с чипом M3. Максимальная производительность для работы и творчества.',
        'price': 199999.0,
        'rating': 4.9,
        'review_count': 67,
        'image_url': 'assets/images/macbook.jpg',
        'stock_quantity': 5,
        'specifications': 'Экран: 14.2" Liquid Retina XDR, 3024x1964\nПроцессор: Apple M3\nПамять: 16GB\nSSD: 512GB\nГрафика: 10-core GPU\nБатарея: до 18 часов\nВес: 1.6 кг',
        'brand': 'Apple',
        'warranty': '12 месяцев',
        'color': 'Серебристый',
        'dimensions': '312.6 x 221.2 x 15.5 мм',
        'weight': '1.6 кг',
        'is_new': 1,
        'is_popular': 1,
        'discount': null,
      },
      {
        'category_id': 2,
        'supplier_id': supplierIds[1],
        'name': 'Samsung Galaxy Book3 Pro',
        'description': 'Ультратонкий ноутбук Samsung с AMOLED экраном. Идеален для работы и развлечений.',
        'price': 129999.0,
        'original_price': 149999.0,
        'rating': 4.7,
        'review_count': 43,
        'image_url': 'assets/images/book.jpg',
        'stock_quantity': 7,
        'specifications': 'Экран: 16" AMOLED, 2880x1800\nПроцессор: Intel Core i7-1360P\nПамять: 16GB\nSSD: 512GB\nГрафика: Intel Iris Xe\nБатарея: до 12 часов\nВес: 1.56 кг',
        'brand': 'Samsung',
        'warranty': '12 месяцев',
        'color': 'Графит',
        'dimensions': '355.4 x 250.4 x 12.5 мм',
        'weight': '1.56 кг',
        'is_new': 0,
        'is_popular': 0,
        'discount': 13.33,
      },
      // Наушники
      {
        'category_id': 3,
        'supplier_id': supplierIds[2],
        'name': 'Sony WH-1000XM5',
        'description': 'Беспроводные наушники с активным шумоподавлением. Лучшее качество звука и комфорт.',
        'price': 29999.0,
        'original_price': 34999.0,
        'rating': 4.8,
        'review_count': 312,
        'image_url': 'assets/images/sony_headphones.jpg',
        'stock_quantity': 20,
        'specifications': 'Тип: Накладные, беспроводные\nШумоподавление: Активное (ANC)\nАвтономность: до 30 часов\nBluetooth: 5.2\nКодек: LDAC, AAC, SBC\nМикрофон: Да\nВес: 250 г',
        'brand': 'Sony',
        'warranty': '12 месяцев',
        'color': 'Черный',
        'dimensions': 'Складывающиеся',
        'weight': '250 г',
        'is_new': 0,
        'is_popular': 1,
        'discount': 14.29,
      },
      {
        'category_id': 3,
        'supplier_id': supplierIds[0],
        'name': 'AirPods Pro 2',
        'description': 'Беспроводные наушники Apple с активным шумоподавлением и пространственным звуком.',
        'price': 24999.0,
        'rating': 4.7,
        'review_count': 445,
        'image_url': 'assets/images/airpods.jpg',
        'stock_quantity': 30,
        'specifications': 'Тип: Внутриканальные, беспроводные\nШумоподавление: Активное (ANC)\nАвтономность: до 6 часов (с кейсом до 30 часов)\nBluetooth: 5.3\nКодек: AAC\nМикрофон: Да\nВес: 5.4 г (каждый)',
        'brand': 'Apple',
        'warranty': '12 месяцев',
        'color': 'Белый',
        'dimensions': 'Компактные',
        'weight': '5.4 г',
        'is_new': 0,
        'is_popular': 1,
        'discount': null,
      },
      // Планшеты
      {
        'category_id': 4,
        'supplier_id': supplierIds[0],
        'name': 'iPad Pro 12.9" M2',
        'description': 'Профессиональный планшет Apple с чипом M2. Мощность компьютера в планшете.',
        'price': 119999.0,
        'rating': 4.9,
        'review_count': 78,
        'image_url': 'assets/images/ipad.jpg',
        'stock_quantity': 6,
        'specifications': 'Экран: 12.9" Liquid Retina XDR, 2732x2048\nПроцессор: Apple M2\nПамять: 256GB\nОЗУ: 8GB\nКамера: 12MP основная, 10MP ультраширокоугольная\nБатарея: до 10 часов\nВес: 682 г',
        'brand': 'Apple',
        'warranty': '12 месяцев',
        'color': 'Серебристый',
        'dimensions': '280.6 x 214.9 x 6.4 мм',
        'weight': '682 г',
        'is_new': 0,
        'is_popular': 1,
        'discount': null,
      },
      // Аксессуары
      {
        'category_id': 5,
        'supplier_id': supplierIds[2],
        'name': 'Чехол для iPhone 15 Pro',
        'description': 'Защитный чехол из силикона с усиленной защитой углов.',
        'price': 2999.0,
        'rating': 4.5,
        'review_count': 89,
        'image_url': 'assets/images/case.jpg',
        'stock_quantity': 50,
        'specifications': 'Материал: Силикон\nЗащита: Усиленная по углам\nЦвет: Прозрачный\nСовместимость: iPhone 15 Pro',
        'brand': 'TechWorld',
        'warranty': '6 месяцев',
        'color': 'Прозрачный',
        'dimensions': 'Под iPhone 15 Pro',
        'weight': '25 г',
        'is_new': 0,
        'is_popular': 0,
        'discount': null,
      },
    ];

    for (var product in products) {
      await db.insert('products', product);
    }

    // Добавляем тестовые отзывы
    final reviews = [
      {
        'product_id': 1,
        'user_id': 1,
        'user_name': 'Иван Петров',
        'rating': 5.0,
        'comment': 'Отличный телефон! Быстрый, камера супер, батарея держит долго. Рекомендую!',
        'created_at': '2024-01-15',
      },
      {
        'product_id': 1,
        'user_id': 2,
        'user_name': 'Мария Сидорова',
        'rating': 4.5,
        'comment': 'Хороший телефон, но цена завышена. Качество на высоте.',
        'created_at': '2024-01-20',
      },
      {
        'product_id': 2,
        'user_id': 1,
        'user_name': 'Иван Петров',
        'rating': 4.8,
        'comment': 'Отличный флагман от Samsung. S Pen очень удобен для заметок.',
        'created_at': '2024-02-01',
      },
    ];

    for (var review in reviews) {
      await db.insert('reviews', review);
    }
  }
}
