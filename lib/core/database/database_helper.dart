import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/question.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      print('🗄️ Database başlatılıyor...');
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'agsapp.db');

      print('📁 Database path: $path');

      final database = await openDatabase(
        path,
        version: 39,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      print('✅ Database açıldı');

      print('✅ Database başlatma tamamlandı');
      return database;
    } catch (e, stackTrace) {
      print('❌ Database başlatma hatası: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 35) {
      // Eski soruları temizle (sadece questions tablosunu)
      try {
        await db.execute('DELETE FROM questions');
      } catch (e) {
        print('⚠️ Questions tablosu henüz yok, atlanıyor: $e');
      }

      // Coğrafya dersi ve konularını ekle
      await _insertDefaultData(db);
    }

    // v39: Eğitim ve Mevzuat dersleri, konular ve testleri ekle (idempotent)
    if (oldVersion < 39) {
      await _insertEducationAndLawData(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print('🏗️ Database tabloları oluşturuluyor...');

      // Users tablosu
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      print('✅ Users tablosu oluşturuldu');

      // Subjects tablosu
      await db.execute('''
        CREATE TABLE subjects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT
        )
      ''');
      print('✅ Subjects tablosu oluşturuldu');

      // Topics tablosu
      await db.execute('''
        CREATE TABLE topics (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          icon TEXT,
          FOREIGN KEY (subject_id) REFERENCES subjects (id)
        )
      ''');
      print('✅ Topics tablosu oluşturuldu');

      // Tests tablosu
      await db.execute('''
        CREATE TABLE tests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          topic_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          question_count INTEGER DEFAULT 0,
          FOREIGN KEY (topic_id) REFERENCES topics (id)
        )
      ''');
      print('✅ Tests tablosu oluşturuldu');

      // Questions tablosu
      await db.execute('''
        CREATE TABLE questions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          test_id INTEGER NOT NULL,
          question_text TEXT NOT NULL,
          option_a TEXT NOT NULL,
          option_b TEXT NOT NULL,
          option_c TEXT NOT NULL,
          correct_answer TEXT NOT NULL,
          explanation TEXT,
          FOREIGN KEY (test_id) REFERENCES tests (id)
        )
      ''');
      print('✅ Questions tablosu oluşturuldu');

      // User results tablosu
      await db.execute('''
        CREATE TABLE user_results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          test_id INTEGER NOT NULL,
          score INTEGER NOT NULL,
          total_questions INTEGER NOT NULL,
          correct_answers INTEGER NOT NULL,
          wrong_answers INTEGER NOT NULL,
          time_taken INTEGER,
          completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (test_id) REFERENCES tests (id)
        )
      ''');
      print('✅ User results tablosu oluşturuldu');

      // Varsayılan verileri ekle
      print('📝 Varsayılan veriler ekleniyor...');
      await _insertDefaultData(db);
      print('✅ Varsayılan veriler eklendi');
    } catch (e, stackTrace) {
      print('❌ Database tablo oluşturma hatası: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    // Dersler
    final subjects = [
      {'id': 1, 'name': 'Tarih', 'icon': 'history'},
      {'id': 2, 'name': 'Coğrafya', 'icon': 'map'},
      {'id': 3, 'name': 'Eğitim', 'icon': 'school'},
      {'id': 4, 'name': 'Mevzuat', 'icon': 'gavel'},
    ];

    for (final subject in subjects) {
      await db.insert('subjects', subject);
    }

    // Konular
    final topics = [
      // Tarih konuları
      {
        'id': 1,
        'subject_id': 1,
        'name': 'İslamiyet Öncesi Türk Tarihi',
        'icon': 'flag'
      },
      {
        'id': 2,
        'subject_id': 1,
        'name': 'İlk Türk İslam Devletleri',
        'icon': 'mosque'
      },
      {'id': 3, 'subject_id': 1, 'name': 'Anadolu Selçuklu', 'icon': 'castle'},
      {'id': 4, 'subject_id': 1, 'name': 'Kuruluş Dönemi', 'icon': 'crown'},
      {
        'id': 5,
        'subject_id': 1,
        'name': 'Osmanlı Devleti Yükselme Dönemi',
        'icon': 'trending_up'
      },
      {'id': 6, 'subject_id': 1, 'name': 'Osmanlı Kültürü', 'icon': 'culture'},
      {'id': 7, 'subject_id': 1, 'name': 'Duraklama Dönemi', 'icon': 'pause'},
      {
        'id': 8,
        'subject_id': 1,
        'name': 'Dağılma Dönemi 1. Dünya Savaşı',
        'icon': 'world_war'
      },
      {'id': 9, 'subject_id': 1, 'name': 'Dağılma Dönemi', 'icon': 'break'},
      {
        'id': 10,
        'subject_id': 1,
        'name': 'Çağdaş Türk ve Dünya Tarihi',
        'icon': 'modern_history'
      },
      {
        'id': 11,
        'subject_id': 1,
        'name': 'Milli Mücadele Hazırlık',
        'icon': 'preparation'
      },
      {'id': 12, 'subject_id': 1, 'name': 'Milli Mücadele', 'icon': 'struggle'},
      {'id': 13, 'subject_id': 1, 'name': 'Atatürk Dönemi', 'icon': 'ataturk'},

      // Coğrafya konuları
      {'id': 14, 'subject_id': 2, 'name': 'Sanayi', 'icon': 'factory'},
      {'id': 15, 'subject_id': 2, 'name': 'Nüfus', 'icon': 'people'},
      {'id': 16, 'subject_id': 2, 'name': 'Yer Şekilleri', 'icon': 'terrain'},
      {'id': 17, 'subject_id': 2, 'name': 'Coğrafi Konum', 'icon': 'location'},
      {'id': 18, 'subject_id': 2, 'name': 'İklim', 'icon': 'weather'},
      {'id': 19, 'subject_id': 2, 'name': 'Dağlar', 'icon': 'mountain'},
      {'id': 20, 'subject_id': 2, 'name': 'Tarım', 'icon': 'agriculture'},
      {'id': 21, 'subject_id': 2, 'name': 'Projeler', 'icon': 'project'},
      {
        'id': 22,
        'subject_id': 2,
        'name': 'Turizm-Ticaret-Ulaşım',
        'icon': 'tourism'
      },
      {'id': 23, 'subject_id': 2, 'name': 'Madencilik', 'icon': 'mining'},

      // Eğitim konuları
      {
        'id': 24,
        'subject_id': 3,
        'name': 'Eğitim ve Öğretim Teknolojileri',
        'icon': 'tech'
      },
      {
        'id': 25,
        'subject_id': 3,
        'name': 'Eğitimin Temel Kavramları',
        'icon': 'concepts'
      },
      {
        'id': 26,
        'subject_id': 3,
        'name': 'Eğitimin Temelleri ve Kuramlar',
        'icon': 'theories'
      },
      {'id': 27, 'subject_id': 3, 'name': 'Maarif Modeli', 'icon': 'model'},
      {
        'id': 28,
        'subject_id': 3,
        'name': 'Türk Milli Eğitim Sistemi',
        'icon': 'system'
      },

      // Mevzuat konuları
      {
        'id': 29,
        'subject_id': 4,
        'name': '1739 Sayılı Milli Eğitim Temel Kanunu',
        'icon': 'law'
      },
      {
        'id': 30,
        'subject_id': 4,
        'name': '1982 Anayasası: Genel Esaslar ve Devletin Nitelikleri',
        'icon': 'constitution'
      },
      {
        'id': 31,
        'subject_id': 4,
        'name': '222 Sayılı İlköğretim ve Eğitim Kanunu',
        'icon': 'education_law'
      },
      {
        'id': 32,
        'subject_id': 4,
        'name': '7528 Sayılı Öğretmenlik Meslek Kanunu Özellikleri',
        'icon': 'teacher_law'
      },
      {'id': 33, 'subject_id': 4, 'name': 'İdare', 'icon': 'administration'},
      {
        'id': 34,
        'subject_id': 4,
        'name': 'Temel Hak ve Hürriyetler',
        'icon': 'rights'
      },
      {'id': 35, 'subject_id': 4, 'name': 'Yargı', 'icon': 'judiciary'},
      {'id': 36, 'subject_id': 4, 'name': 'Yasama', 'icon': 'legislation'},
      {'id': 37, 'subject_id': 4, 'name': 'Yürütme', 'icon': 'executive'},
    ];

    for (final topic in topics) {
      await db.insert('topics', topic);
    }

    // Testler - GÜNCEL MAPPING'E GÖRE
    final tests = <Map<String, Object?>>[
      // İslamiyet Öncesi Türk Tarihi (1) - 5 test (1-5)
      for (int i = 0; i < 5; i++)
        {
          'id': 1 + i,
          'topic_id': 1,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // İlk Türk İslam Devletleri (2) - 7 test (6-12)
      for (int i = 0; i < 7; i++)
        {
          'id': 6 + i,
          'topic_id': 2,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Anadolu Selçuklu (3) - 3 test (13-15)
      for (int i = 0; i < 3; i++)
        {
          'id': 13 + i,
          'topic_id': 3,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Kuruluş Dönemi (4) - 2 test (16-17)
      for (int i = 0; i < 2; i++)
        {
          'id': 16 + i,
          'topic_id': 4,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Osmanlı Devleti Yükselme Dönemi (5) - 5 test (18-22)
      for (int i = 0; i < 5; i++)
        {
          'id': 18 + i,
          'topic_id': 5,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Osmanlı Kültürü (6) - 6 test (23-28)
      for (int i = 0; i < 6; i++)
        {
          'id': 23 + i,
          'topic_id': 6,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Duraklama Dönemi (7) - 4 test (29-32)
      for (int i = 0; i < 4; i++)
        {
          'id': 29 + i,
          'topic_id': 7,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Dağılma Dönemi 1. Dünya Savaşı (8) - 12 test (33-44)
      for (int i = 0; i < 12; i++)
        {
          'id': 33 + i,
          'topic_id': 8,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Dağılma Dönemi (9) - 8 test (45-52)
      for (int i = 0; i < 8; i++)
        {
          'id': 45 + i,
          'topic_id': 9,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Çağdaş Türk ve Dünya Tarihi (10) - 12 test (53-64)
      for (int i = 0; i < 12; i++)
        {
          'id': 53 + i,
          'topic_id': 10,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Milli Mücadele Hazırlık (11) - 5 test (65-69)
      for (int i = 0; i < 5; i++)
        {
          'id': 65 + i,
          'topic_id': 11,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Milli Mücadele (12) - 4 test (70-73)
      for (int i = 0; i < 4; i++)
        {
          'id': 70 + i,
          'topic_id': 12,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Atatürk Dönemi (13) - 9 test (74-82)
      for (int i = 0; i < 9; i++)
        {
          'id': 74 + i,
          'topic_id': 13,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Sanayi (14) - 4 test (83-86)
      for (int i = 0; i < 4; i++)
        {
          'id': 83 + i,
          'topic_id': 14,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Nüfus (15) - 6 test (87-92)
      for (int i = 0; i < 6; i++)
        {
          'id': 87 + i,
          'topic_id': 15,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Yer Şekilleri (16) - 4 test (93-96)
      for (int i = 0; i < 4; i++)
        {
          'id': 93 + i,
          'topic_id': 16,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Coğrafi Konum (17) - 4 test (97-100)
      for (int i = 0; i < 4; i++)
        {
          'id': 97 + i,
          'topic_id': 17,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - İklim (18) - 4 test (101-104)
      for (int i = 0; i < 4; i++)
        {
          'id': 101 + i,
          'topic_id': 18,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Dağlar (19) - 3 test (105-107)
      for (int i = 0; i < 3; i++)
        {
          'id': 105 + i,
          'topic_id': 19,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Tarım (20) - 3 test (108-110)
      for (int i = 0; i < 3; i++)
        {
          'id': 108 + i,
          'topic_id': 20,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Projeler (21) - 2 test (111-112)
      for (int i = 0; i < 2; i++)
        {
          'id': 111 + i,
          'topic_id': 21,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Turizm-Ticaret-Ulaşım (22) - 5 test (113-117)
      for (int i = 0; i < 5; i++)
        {
          'id': 113 + i,
          'topic_id': 22,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Coğrafya - Madencilik (23) - 4 test (118-121)
      for (int i = 0; i < 4; i++)
        {
          'id': 118 + i,
          'topic_id': 23,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Eğitim ve Öğretim Teknolojileri (24) - 7 test (122-128)
      for (int i = 0; i < 7; i++)
        {
          'id': 122 + i,
          'topic_id': 24,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Eğitimin Temel Kavramları (25) - 16 test (129-144)
      for (int i = 0; i < 16; i++)
        {
          'id': 129 + i,
          'topic_id': 25,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Eğitimin Temelleri ve Kuramlar (26) - 16 test (145-160)
      for (int i = 0; i < 16; i++)
        {
          'id': 145 + i,
          'topic_id': 26,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Maarif Modeli (27) - 8 test (161-168)
      for (int i = 0; i < 8; i++)
        {
          'id': 161 + i,
          'topic_id': 27,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Türk Milli Eğitim Sistemi (28) - 6 test (169-174)
      for (int i = 0; i < 6; i++)
        {
          'id': 169 + i,
          'topic_id': 28,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // 1739 ... (29) - 7 test (175-181)
      for (int i = 0; i < 7; i++)
        {
          'id': 175 + i,
          'topic_id': 29,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // 1982 ... (30) - 1 test (182)
      {'id': 182, 'topic_id': 30, 'name': 'Test 1', 'question_count': 20},

      // 222 ... (31) - 2 test (183-184)
      {'id': 183, 'topic_id': 31, 'name': 'Test 1', 'question_count': 20},
      {'id': 184, 'topic_id': 31, 'name': 'Test 2', 'question_count': 20},

      // 7528 ... (32) - 8 test (185-192)
      for (int i = 0; i < 8; i++)
        {
          'id': 185 + i,
          'topic_id': 32,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // İdare (33) - 4 test (193-196)
      for (int i = 0; i < 4; i++)
        {
          'id': 193 + i,
          'topic_id': 33,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Temel Hak ve Hürriyetler (34) - 4 test (197-200)
      for (int i = 0; i < 4; i++)
        {
          'id': 197 + i,
          'topic_id': 34,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Yargı (35) - 7 test (201-207)
      for (int i = 0; i < 7; i++)
        {
          'id': 201 + i,
          'topic_id': 35,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Yasama (36) - 6 test (208-213)
      for (int i = 0; i < 6; i++)
        {
          'id': 208 + i,
          'topic_id': 36,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Yürütme (37) - 6 test (214-219)
      for (int i = 0; i < 6; i++)
        {
          'id': 214 + i,
          'topic_id': 37,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },
    ];

    for (final test in tests) {
      await db.insert('tests', test);
    }
  }

  // v39 ile gelen Eğitim (subject_id: 3) ve Mevzuat (subject_id: 4) verileri
  Future<void> _insertEducationAndLawData(Database db) async {
    print('📚 Eğitim ve Mevzuat verileri ekleniyor (upgrade)...');

    // Dersler
    await db.insert(
      'subjects',
      {'id': 3, 'name': 'Eğitim', 'icon': 'school'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.insert(
      'subjects',
      {'id': 4, 'name': 'Mevzuat', 'icon': 'gavel'},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Eğitim konuları (topics 24-28)
    final educationTopics = [
      {
        'id': 24,
        'subject_id': 3,
        'name': 'Eğitim ve Öğretim Teknolojileri',
        'icon': 'devices'
      },
      {
        'id': 25,
        'subject_id': 3,
        'name': 'Eğitimin Temel Kavramları',
        'icon': 'menu_book'
      },
      {
        'id': 26,
        'subject_id': 3,
        'name': 'Eğitimin Temelleri ve Kuramlar',
        'icon': 'psychology'
      },
      {'id': 27, 'subject_id': 3, 'name': 'Maarif Modeli', 'icon': 'lightbulb'},
      {
        'id': 28,
        'subject_id': 3,
        'name': 'Türk Milli Eğitim Sistemi',
        'icon': 'account_tree'
      },
    ];
    for (final t in educationTopics) {
      await db.insert('topics', t, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Mevzuat konuları (topics 29-37)
    final lawTopics = [
      {
        'id': 29,
        'subject_id': 4,
        'name': '1739 Sayılı Milli Eğitim Temel Kanunu',
        'icon': 'article'
      },
      {
        'id': 30,
        'subject_id': 4,
        'name': '1982 Anayasası: Genel Esaslar ve Devletin Nitelikleri',
        'icon': 'balance'
      },
      {
        'id': 31,
        'subject_id': 4,
        'name': '222 Sayılı İlköğretim ve Eğitim Kanunu',
        'icon': 'school'
      },
      {
        'id': 32,
        'subject_id': 4,
        'name': '7528 Sayılı Öğretmenlik Meslek Kanunu',
        'icon': 'badge'
      },
      {
        'id': 33,
        'subject_id': 4,
        'name': 'İdare',
        'icon': 'admin_panel_settings'
      },
      {
        'id': 34,
        'subject_id': 4,
        'name': 'Temel Hak ve Hürriyetler',
        'icon': 'lock_open'
      },
      {'id': 35, 'subject_id': 4, 'name': 'Yargı', 'icon': 'scale'},
      {'id': 36, 'subject_id': 4, 'name': 'Yasama', 'icon': 'gavel'},
      {'id': 37, 'subject_id': 4, 'name': 'Yürütme', 'icon': 'settings'},
    ];
    for (final t in lawTopics) {
      await db.insert('topics', t, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Testler (IDs 114-211)
    final tests = <Map<String, Object?>>[
      // Eğitim ve Öğretim Teknolojileri (24) - 7 test (114-120)
      for (int i = 0; i < 7; i++)
        {
          'id': 114 + i,
          'topic_id': 24,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Eğitimin Temel Kavramları (25) - 16 test (121-136)
      for (int i = 0; i < 16; i++)
        {
          'id': 121 + i,
          'topic_id': 25,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Eğitimin Temelleri ve Kuramlar (26) - 16 test (137-152)
      for (int i = 0; i < 16; i++)
        {
          'id': 137 + i,
          'topic_id': 26,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Maarif Modeli (27) - 8 test (153-160)
      for (int i = 0; i < 8; i++)
        {
          'id': 153 + i,
          'topic_id': 27,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Türk Milli Eğitim Sistemi (28) - 6 test (161-166)
      for (int i = 0; i < 6; i++)
        {
          'id': 161 + i,
          'topic_id': 28,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // 1739 ... (29) - 7 test (167-173)
      for (int i = 0; i < 7; i++)
        {
          'id': 167 + i,
          'topic_id': 29,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // 1982 ... (30) - 1 test (174)
      {'id': 174, 'topic_id': 30, 'name': 'Test 1', 'question_count': 20},

      // 222 ... (31) - 2 test (175-176)
      {'id': 175, 'topic_id': 31, 'name': 'Test 1', 'question_count': 20},
      {'id': 176, 'topic_id': 31, 'name': 'Test 2', 'question_count': 20},

      // 7528 ... (32) - 8 test (177-184)
      for (int i = 0; i < 8; i++)
        {
          'id': 177 + i,
          'topic_id': 32,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // İdare (33) - 4 test (185-188)
      for (int i = 0; i < 4; i++)
        {
          'id': 185 + i,
          'topic_id': 33,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Temel Hak ve Hürriyetler (34) - 4 test (189-192)
      for (int i = 0; i < 4; i++)
        {
          'id': 189 + i,
          'topic_id': 34,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Yargı (35) - 7 test (193-199)
      for (int i = 0; i < 7; i++)
        {
          'id': 193 + i,
          'topic_id': 35,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Yasama (36) - 6 test (200-205)
      for (int i = 0; i < 6; i++)
        {
          'id': 200 + i,
          'topic_id': 36,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },

      // Yürütme (37) - 6 test (206-211)
      for (int i = 0; i < 6; i++)
        {
          'id': 206 + i,
          'topic_id': 37,
          'name': 'Test ${i + 1}',
          'question_count': 20,
        },
    ];

    for (final test in tests) {
      await db.insert('tests', test,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    print('✅ Eğitim ve Mevzuat verileri eklendi (upgrade)');
  }

  Future<void> _insertTests(Database db) async {
    // İslamiyet Öncesi Türk Tarihi testleri (ID: 1-4)
    final islamiyetOncesiTests = [
      {'id': 1, 'topic_id': 1, 'name': 'Test 1', 'question_count': 20},
      {'id': 2, 'topic_id': 1, 'name': 'Test 2', 'question_count': 20},
      {'id': 3, 'topic_id': 1, 'name': 'Test 3', 'question_count': 20},
      {'id': 4, 'topic_id': 1, 'name': 'Test 4', 'question_count': 20},
    ];

    for (final test in islamiyetOncesiTests) {
      await db.insert('tests', test);
    }

    // İlk Türk İslam Devletleri testleri (ID: 5-8)
    final ilkTurkIslamTests = [
      {'id': 5, 'topic_id': 2, 'name': 'Test 1', 'question_count': 20},
      {'id': 6, 'topic_id': 2, 'name': 'Test 2', 'question_count': 20},
      {'id': 7, 'topic_id': 2, 'name': 'Test 3', 'question_count': 20},
      {'id': 8, 'topic_id': 2, 'name': 'Test 4', 'question_count': 10},
    ];

    for (final test in ilkTurkIslamTests) {
      await db.insert('tests', test);
    }

    // Anadolu Türkiye Selçuklu Devleti testleri (ID: 9-11)
    final anadoluSelcukluTests = [
      {'id': 9, 'topic_id': 3, 'name': 'Test 1', 'question_count': 20},
      {'id': 10, 'topic_id': 3, 'name': 'Test 2', 'question_count': 20},
      {'id': 11, 'topic_id': 3, 'name': 'Test 3', 'question_count': 4},
    ];

    for (final test in anadoluSelcukluTests) {
      await db.insert('tests', test);
    }

    // Kuruluş Dönemi testleri (ID: 12-14)
    final kurulusTests = [
      {'id': 12, 'topic_id': 4, 'name': 'Test 1', 'question_count': 20},
      {'id': 13, 'topic_id': 4, 'name': 'Test 2', 'question_count': 20},
      {'id': 14, 'topic_id': 4, 'name': 'Test 3', 'question_count': 14},
    ];

    for (final test in kurulusTests) {
      await db.insert('tests', test);
    }

    // Osmanlı Devleti Yükselme Dönemi testleri (ID: 17-21)
    final osmanliYukselmeTests = [
      {'id': 17, 'topic_id': 5, 'name': 'Test 1', 'question_count': 20},
      {'id': 18, 'topic_id': 5, 'name': 'Test 2', 'question_count': 20},
      {'id': 19, 'topic_id': 5, 'name': 'Test 3', 'question_count': 20},
      {'id': 20, 'topic_id': 5, 'name': 'Test 4', 'question_count': 20},
      {'id': 21, 'topic_id': 5, 'name': 'Test 5', 'question_count': 3},
    ];

    for (final test in osmanliYukselmeTests) {
      await db.insert('tests', test);
    }

    // Osmanlı Kültürü testleri (ID: 22-26)
    final osmanliKulturuTests = [
      {'id': 22, 'topic_id': 6, 'name': 'Test 1', 'question_count': 20},
      {'id': 23, 'topic_id': 6, 'name': 'Test 2', 'question_count': 20},
      {'id': 24, 'topic_id': 6, 'name': 'Test 3', 'question_count': 20},
      {'id': 25, 'topic_id': 6, 'name': 'Test 4', 'question_count': 20},
      {'id': 26, 'topic_id': 6, 'name': 'Test 5', 'question_count': 13},
    ];

    for (final test in osmanliKulturuTests) {
      await db.insert('tests', test);
    }

    // Duraklama Dönemi testleri (ID: 27-29)
    final duraklamaTests = [
      {'id': 27, 'topic_id': 7, 'name': 'Test 1', 'question_count': 20},
      {'id': 28, 'topic_id': 7, 'name': 'Test 2', 'question_count': 20},
      {'id': 29, 'topic_id': 7, 'name': 'Test 3', 'question_count': 20},
    ];

    for (final test in duraklamaTests) {
      await db.insert('tests', test);
    }

    // Dağılma Dönemi 1. Dünya Savaşı testleri (ID: 31-34)
    final dagilma1DunyaSavasiTests = [
      {'id': 31, 'topic_id': 8, 'name': 'Test 1', 'question_count': 20},
      {'id': 32, 'topic_id': 8, 'name': 'Test 2', 'question_count': 20},
      {'id': 33, 'topic_id': 8, 'name': 'Test 3', 'question_count': 20},
      {'id': 34, 'topic_id': 8, 'name': 'Test 4', 'question_count': 18},
    ];

    for (final test in dagilma1DunyaSavasiTests) {
      await db.insert('tests', test);
    }

    // Dağılma Dönemi testleri (ID: 35-42)
    final dagilmaTests = [
      {'id': 35, 'topic_id': 9, 'name': 'Test 1', 'question_count': 20},
      {'id': 36, 'topic_id': 9, 'name': 'Test 2', 'question_count': 20},
      {'id': 37, 'topic_id': 9, 'name': 'Test 3', 'question_count': 20},
      {'id': 38, 'topic_id': 9, 'name': 'Test 4', 'question_count': 20},
      {'id': 39, 'topic_id': 9, 'name': 'Test 5', 'question_count': 20},
      {'id': 40, 'topic_id': 9, 'name': 'Test 6', 'question_count': 20},
      {'id': 41, 'topic_id': 9, 'name': 'Test 7', 'question_count': 20},
      {'id': 42, 'topic_id': 9, 'name': 'Test 8', 'question_count': 20},
    ];

    for (final test in dagilmaTests) {
      await db.insert('tests', test);
    }

    // Çağdaş Türk Ve Dünya Tarihi testleri (ID: 43-54)
    final cagdasTurkTests = [
      {'id': 43, 'topic_id': 10, 'name': 'Test 1', 'question_count': 20},
      {'id': 44, 'topic_id': 10, 'name': 'Test 2', 'question_count': 20},
      {'id': 45, 'topic_id': 10, 'name': 'Test 3', 'question_count': 20},
      {'id': 46, 'topic_id': 10, 'name': 'Test 4', 'question_count': 20},
      {'id': 47, 'topic_id': 10, 'name': 'Test 5', 'question_count': 20},
      {'id': 48, 'topic_id': 10, 'name': 'Test 6', 'question_count': 20},
      {'id': 49, 'topic_id': 10, 'name': 'Test 7', 'question_count': 20},
      {'id': 50, 'topic_id': 10, 'name': 'Test 8', 'question_count': 20},
      {'id': 51, 'topic_id': 10, 'name': 'Test 9', 'question_count': 20},
      {'id': 52, 'topic_id': 10, 'name': 'Test 10', 'question_count': 20},
      {'id': 53, 'topic_id': 10, 'name': 'Test 11', 'question_count': 20},
      {'id': 54, 'topic_id': 10, 'name': 'Test 12', 'question_count': 20},
    ];

    for (final test in cagdasTurkTests) {
      await db.insert('tests', test);
    }

    // Milli Mücadele Hazırlık testleri (ID: 55-58)
    final milliMucadeleHazirlikTests = [
      {'id': 55, 'topic_id': 11, 'name': 'Test 1', 'question_count': 20},
      {'id': 56, 'topic_id': 11, 'name': 'Test 2', 'question_count': 20},
      {'id': 57, 'topic_id': 11, 'name': 'Test 3', 'question_count': 20},
      {'id': 58, 'topic_id': 11, 'name': 'Test 4', 'question_count': 20},
      {'id': 59, 'topic_id': 11, 'name': 'Test 5', 'question_count': 20},
    ];

    for (final test in milliMucadeleHazirlikTests) {
      await db.insert('tests', test);
    }

    // Milli Mücadele testleri (ID: 60-63)
    final milliMucadeleTests = [
      {'id': 60, 'topic_id': 12, 'name': 'Test 1', 'question_count': 20},
      {'id': 61, 'topic_id': 12, 'name': 'Test 2', 'question_count': 20},
      {'id': 62, 'topic_id': 12, 'name': 'Test 3', 'question_count': 20},
      {'id': 63, 'topic_id': 12, 'name': 'Test 4', 'question_count': 20},
    ];

    for (final test in milliMucadeleTests) {
      await db.insert('tests', test);
    }

    // Atatürk Dönemi testleri (ID: 65-73)
    final ataturkDonemiTests = [
      {'id': 65, 'topic_id': 13, 'name': 'Test 1', 'question_count': 20},
      {'id': 66, 'topic_id': 13, 'name': 'Test 2', 'question_count': 20},
      {'id': 67, 'topic_id': 13, 'name': 'Test 3', 'question_count': 20},
      {'id': 68, 'topic_id': 13, 'name': 'Test 4', 'question_count': 20},
      {'id': 69, 'topic_id': 13, 'name': 'Test 5', 'question_count': 20},
      {'id': 70, 'topic_id': 13, 'name': 'Test 6', 'question_count': 20},
      {'id': 71, 'topic_id': 13, 'name': 'Test 7', 'question_count': 20},
      {'id': 72, 'topic_id': 13, 'name': 'Test 8', 'question_count': 20},
      {'id': 73, 'topic_id': 13, 'name': 'Test 9', 'question_count': 20},
    ];

    for (final test in ataturkDonemiTests) {
      await db.insert('tests', test);
    }

    // Coğrafya testleri ekle
    // Sanayi testleri (ID: 74-77)
    final sanayiTests = [
      {'id': 74, 'topic_id': 14, 'name': 'Test 1', 'question_count': 20},
      {'id': 75, 'topic_id': 14, 'name': 'Test 2', 'question_count': 20},
      {'id': 76, 'topic_id': 14, 'name': 'Test 3', 'question_count': 20},
      {'id': 77, 'topic_id': 14, 'name': 'Test 4', 'question_count': 20},
    ];

    for (final test in sanayiTests) {
      await db.insert('tests', test);
    }

    // Nüfus testleri (ID: 78-83)
    final nufusTests = [
      {'id': 78, 'topic_id': 15, 'name': 'Test 1', 'question_count': 20},
      {'id': 79, 'topic_id': 15, 'name': 'Test 2', 'question_count': 20},
      {'id': 80, 'topic_id': 15, 'name': 'Test 3', 'question_count': 20},
      {'id': 81, 'topic_id': 15, 'name': 'Test 4', 'question_count': 20},
      {'id': 82, 'topic_id': 15, 'name': 'Test 5', 'question_count': 20},
      {'id': 83, 'topic_id': 15, 'name': 'Test 6', 'question_count': 20},
    ];

    for (final test in nufusTests) {
      await db.insert('tests', test);
    }

    // Yer Şekilleri testleri (ID: 84-87)
    final yerSekilleriTests = [
      {'id': 84, 'topic_id': 16, 'name': 'Test 1', 'question_count': 20},
      {'id': 85, 'topic_id': 16, 'name': 'Test 2', 'question_count': 20},
      {'id': 86, 'topic_id': 16, 'name': 'Test 3', 'question_count': 20},
      {'id': 87, 'topic_id': 16, 'name': 'Test 4', 'question_count': 20},
    ];

    for (final test in yerSekilleriTests) {
      await db.insert('tests', test);
    }

    // Coğrafi Konum testleri (ID: 88-91)
    final cografiKonumTests = [
      {'id': 88, 'topic_id': 17, 'name': 'Test 1', 'question_count': 20},
      {'id': 89, 'topic_id': 17, 'name': 'Test 2', 'question_count': 20},
      {'id': 90, 'topic_id': 17, 'name': 'Test 3', 'question_count': 20},
      {'id': 91, 'topic_id': 17, 'name': 'Test 4', 'question_count': 20},
    ];

    for (final test in cografiKonumTests) {
      await db.insert('tests', test);
    }

    // İklim testleri (ID: 92-95)
    final iklimTests = [
      {'id': 92, 'topic_id': 18, 'name': 'Test 1', 'question_count': 20},
      {'id': 93, 'topic_id': 18, 'name': 'Test 2', 'question_count': 20},
      {'id': 94, 'topic_id': 18, 'name': 'Test 3', 'question_count': 20},
      {'id': 95, 'topic_id': 18, 'name': 'Test 4', 'question_count': 20},
    ];

    for (final test in iklimTests) {
      await db.insert('tests', test);
    }

    // Dağlar testleri (ID: 96-98)
    final daglarTests = [
      {'id': 96, 'topic_id': 19, 'name': 'Test 1', 'question_count': 20},
      {'id': 97, 'topic_id': 19, 'name': 'Test 2', 'question_count': 20},
      {'id': 98, 'topic_id': 19, 'name': 'Test 3', 'question_count': 20},
    ];

    for (final test in daglarTests) {
      await db.insert('tests', test);
    }

    // Tarım testleri (ID: 99-101)
    final tarimTests = [
      {'id': 99, 'topic_id': 20, 'name': 'Test 1', 'question_count': 20},
      {'id': 100, 'topic_id': 20, 'name': 'Test 2', 'question_count': 20},
      {'id': 101, 'topic_id': 20, 'name': 'Test 3', 'question_count': 20},
    ];

    for (final test in tarimTests) {
      await db.insert('tests', test);
    }

    // Projeler testleri (ID: 102-103)
    final projelerTests = [
      {'id': 102, 'topic_id': 21, 'name': 'Test 1', 'question_count': 20},
      {'id': 103, 'topic_id': 21, 'name': 'Test 2', 'question_count': 20},
    ];

    for (final test in projelerTests) {
      await db.insert('tests', test);
    }

    // Turizm-Ticaret-Ulaşım testleri (ID: 104-107)
    final turizmTicaretUlasimTests = [
      {'id': 104, 'topic_id': 22, 'name': 'Test 1', 'question_count': 20},
      {'id': 105, 'topic_id': 22, 'name': 'Test 2', 'question_count': 20},
      {'id': 106, 'topic_id': 22, 'name': 'Test 3', 'question_count': 20},
      {'id': 107, 'topic_id': 22, 'name': 'Test 4', 'question_count': 20},
    ];

    for (final test in turizmTicaretUlasimTests) {
      await db.insert('tests', test);
    }

    // Madencilik testleri (ID: 108-113)
    final madencilikTests = [
      {'id': 108, 'topic_id': 23, 'name': 'Test 1', 'question_count': 20},
      {'id': 109, 'topic_id': 23, 'name': 'Test 2', 'question_count': 20},
      {'id': 110, 'topic_id': 23, 'name': 'Test 3', 'question_count': 20},
      {'id': 111, 'topic_id': 23, 'name': 'Test 4', 'question_count': 20},
      {'id': 112, 'topic_id': 23, 'name': 'Test 5', 'question_count': 20},
      {'id': 113, 'topic_id': 23, 'name': 'Test 6', 'question_count': 20},
    ];

    for (final test in madencilikTests) {
      await db.insert('tests', test);
    }
  }

  Future<void> _insertTestQuestions(Database db) async {
    // Test soruları JSON sisteminden yüklenecek
  }

  // Temel CRUD işlemleri
  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    return await db.query('subjects');
  }

  Future<List<Map<String, dynamic>>> getTopicsBySubjectId(int subjectId) async {
    final db = await database;
    return await db.query(
      'topics',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
  }

  Future<List<Map<String, dynamic>>> getTestsByTopicId(int topicId) async {
    final db = await database;
    return await db.query(
      'tests',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
  }

  // User işlemleri
  Future<int> createUser(String name) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
    });
  }

  Future<List<Map<String, dynamic>>> getAllSubjects() async {
    return await getSubjects();
  }

  Future<List<Map<String, dynamic>>> getTopicsBySubject(int subjectId) async {
    return await getTopicsBySubjectId(subjectId);
  }

  Future<List<Map<String, dynamic>>> getTestsByTopic(int topicId) async {
    return await getTestsByTopicId(topicId);
  }

  // Test sonuçlarını kaydet
  Future<int> saveTestResult({
    required int testId,
    required int userId,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
    int? timeTaken,
  }) async {
    final db = await database;
    return await db.insert('user_results', {
      'user_id': userId,
      'test_id': testId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'time_taken': timeTaken,
    });
  }

  // Kullanıcı istatistiklerini getir
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalTests,
        SUM(total_questions) as totalQuestions,
        SUM(correct_answers) as totalCorrect,
        SUM(wrong_answers) as totalWrong,
        MAX(score) as highestScore
      FROM user_results 
      WHERE user_id = ?
    ''', [userId]);

    // Toplam test sayısını al
    final totalTestsInDB = await db.rawQuery('''
      SELECT COUNT(*) as allTests
      FROM tests
    ''');

    final result = results.first;
    final totalTestsResult = totalTestsInDB.first;

    return {
      'total_tests': result['totalTests'] ?? 0,
      'total_questions': result['totalQuestions'] ?? 0,
      'total_correct': result['totalCorrect'] ?? 0,
      'total_wrong': result['totalWrong'] ?? 0,
      'highest_score': result['highestScore'] ?? 0,
      'all_tests_in_db': totalTestsResult['allTests'] ?? 0,
    };
  }

  // Kategori ilerlemelerini getir (test sayısına göre)
  Future<List<Map<String, dynamic>>> getCategoryProgress(int userId) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT 
        s.name as subject_name,
        s.icon as subject_icon,
        COUNT(DISTINCT t.id) as total_tests,
        COUNT(DISTINCT ur.test_id) as completed_tests,
        CASE 
          WHEN COUNT(DISTINCT t.id) > 0 THEN 
            CAST(COUNT(DISTINCT ur.test_id) AS REAL) / COUNT(DISTINCT t.id)
          ELSE 0 
        END as progress
      FROM subjects s
      LEFT JOIN topics tp ON s.id = tp.subject_id
      LEFT JOIN tests t ON tp.id = t.topic_id
      LEFT JOIN user_results ur ON t.id = ur.test_id AND ur.user_id = ?
      GROUP BY s.id, s.name, s.icon
      ORDER BY s.name
    ''', [userId]);

    return results;
  }

  // Kullanıcının çözdüğü testleri kontrol et
  Future<Set<int>> getCompletedTestIds(int userId) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT DISTINCT test_id
      FROM user_results
      WHERE user_id = ?
    ''', [userId]);

    return results.map((row) => row['test_id'] as int).toSet();
  }

  // Kullanıcının test çözme sayılarını getir
  Future<Map<int, int>> getTestCompletionCounts(int userId) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT test_id, COUNT(*) as completion_count
      FROM user_results
      WHERE user_id = ?
      GROUP BY test_id
    ''', [userId]);

    Map<int, int> counts = {};
    for (var row in results) {
      counts[row['test_id'] as int] = row['completion_count'] as int;
    }

    return counts;
  }

  // Kullanıcının son aktivitelerini getir
  Future<List<Map<String, dynamic>>> getRecentActivities(int userId,
      {int limit = 5}) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT 
        ur.id,
        ur.score,
        ur.total_questions,
        ur.correct_answers,
        ur.wrong_answers,
        ur.completed_at,
        t.id as test_id,
        t.name as test_name,
        tp.name as topic_name,
        s.name as subject_name,
        (
          SELECT COUNT(*) + 1
          FROM tests t2 
          WHERE t2.topic_id = t.topic_id 
          AND t2.id < t.id
        ) as test_order
      FROM user_results ur
      INNER JOIN tests t ON ur.test_id = t.id
      INNER JOIN topics tp ON t.topic_id = tp.id
      INNER JOIN subjects s ON tp.subject_id = s.id
      WHERE ur.user_id = ?
      ORDER BY ur.completed_at DESC
      LIMIT ?
    ''', [userId, limit]);

    return results;
  }

  // JSON Question Service için yeni methodlar
  Future<int> insertQuestion(Question question) async {
    final db = await database;
    return await db.insert('questions', question.toMap());
  }

  // Batch insert - çok daha hızlı
  Future<void> insertQuestionsBatch(List<Question> questions) async {
    if (questions.isEmpty) return;

    final db = await database;

    // Transaction kullanarak daha hızlı
    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final question in questions) {
        batch.insert('questions', question.toMap());
      }

      await batch.commit(noResult: true);
    });
  }

  Future<void> clearQuestionsByTestId(int testId) async {
    final db = await database;
    await db.delete('questions', where: 'test_id = ?', whereArgs: [testId]);
  }

  // Mevcut getQuestionsByTestId'yi Question model ile uyumlu yap
  Future<List<Question>> getQuestionsByTestId(int testId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'test_id = ?',
      whereArgs: [testId],
      orderBy: 'id ASC',
    );

    return List.generate(maps.length, (i) {
      return Question.fromMap(maps[i]);
    });
  }

  // Testin soru sayısını güncelle (JSON yükleme sonrası gerçek sayıyla)
  Future<void> updateTestQuestionCount(int testId, int questionCount) async {
    final db = await database;
    await db.update(
      'tests',
      {'question_count': questionCount},
      where: 'id = ?',
      whereArgs: [testId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
