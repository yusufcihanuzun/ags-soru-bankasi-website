import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:agsapp/core/database/database_helper.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  try {
    print('🔧 Dependency injection başlatılıyor...');

    // Core services - Only register SQLite on mobile platforms
    if (!kIsWeb) {
      print('📱 Mobil platform tespit edildi, SQLite başlatılıyor...');

      getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

      // Initialize database
      final dbHelper = getIt<DatabaseHelper>();
      await dbHelper.database;
      print('✅ Database başarıyla başlatıldı');
    } else {
      print('🌐 Web platform tespit edildi, SQLite atlanıyor...');
    }

    print('✅ Dependency injection tamamlandı');
  } catch (e, stackTrace) {
    print('❌ Dependency injection hatası: $e');
    print('❌ Stack trace: $stackTrace');
    rethrow;
  }
}
