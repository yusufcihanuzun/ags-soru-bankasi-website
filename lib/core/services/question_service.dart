import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/question.dart';

/// Yükleme sonucu için data class
class LoadResult {
  final bool success;
  final int questionCount;
  final String? error;

  const LoadResult({
    required this.success,
    required this.questionCount,
    this.error,
  });
}

class QuestionService {
  static const String _dataLoadedKey = 'questions_loaded_v39';
  static const String _versionKey = 'question_version';
  static const int _currentVersion = 39;

  // Test ID mapping - MEVCUT DOSYALARLA UYUMLU! 📁
  static const Map<String, int> _testMapping = {
    // İslamiyet Öncesi Türk Tarihi ✅
    'tarih/islamiyet_oncesi_turk_tarihi/islamiyet_oncesi_test1': 1,
    'tarih/islamiyet_oncesi_turk_tarihi/islamiyet_oncesi_test2': 2,
    'tarih/islamiyet_oncesi_turk_tarihi/islamiyet_oncesi_test3': 3,
    'tarih/islamiyet_oncesi_turk_tarihi/islamiyet_oncesi_test4': 4,
    'tarih/islamiyet_oncesi_turk_tarihi/islamiyet_oncesi_test5': 5,

    // İlk Türk İslam Devletleri ✅
    'tarih/ilk_turk_islam_devletleri/ilk_turk_islam_test1': 6,
    'tarih/ilk_turk_islam_devletleri/ilk_turk_islam_test2': 7,
    'tarih/ilk_turk_islam_devletleri/ilk_turk_islam_test3': 8,
    'tarih/ilk_turk_islam_devletleri/ilk_turk_islam_test4': 9,
    'tarih/ilk_turk_islam_devletleri/ilk_turk_islam_test5': 10,
    'tarih/ilk_turk_islam_devletleri/ilk_turk_islam_test6': 11,
    'tarih/ilk_turk_islam_devletleri/ilk_turk_islam_test7': 12,

    // Anadolu Selçuklu ✅
    'tarih/anadolu_selcuklu/selcuklu_test1': 13,
    'tarih/anadolu_selcuklu/selcuklu_test2': 14,
    'tarih/anadolu_selcuklu/selcuklu_test3': 15,

    // Kuruluş Dönemi ✅
    'tarih/kurulus_donemi/kurulus_test1': 16,
    'tarih/kurulus_donemi/kurulus_test2': 17,

    // Osmanlı Devleti Yükselme Dönemi ✅
    'tarih/osmanli_yukselme_donemi/osmanli_yukselme_test1': 18,
    'tarih/osmanli_yukselme_donemi/osmanli_yukselme_test2': 19,
    'tarih/osmanli_yukselme_donemi/osmanli_yukselme_test3': 20,
    'tarih/osmanli_yukselme_donemi/osmanli_yukselme_test4': 21,
    'tarih/osmanli_yukselme_donemi/osmanli_yukselme_test5': 22,

    // Osmanlı Kültürü ✅
    'tarih/osmanli_kulturu/osmanli_kultur_test1': 23,
    'tarih/osmanli_kulturu/osmanli_kultur_test2': 24,
    'tarih/osmanli_kulturu/osmanli_kultur_test3': 25,
    'tarih/osmanli_kulturu/osmanli_kultur_test4': 26,
    'tarih/osmanli_kulturu/osmanli_kultur_test5': 27,
    'tarih/osmanli_kulturu/osmanli_kultur_test6': 28,

    // Duraklama Dönemi ✅
    'tarih/duraklama_donemi/duraklama_test1': 29,
    'tarih/duraklama_donemi/duraklama_test2': 30,
    'tarih/duraklama_donemi/duraklama_test3': 31,
    'tarih/duraklama_donemi/duraklama_test4': 32,

    // Dağılma Dönemi 1. Dünya Savaşı ✅
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test1': 33,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test2': 34,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test3': 35,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test4': 36,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test5': 37,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test6': 38,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test7': 39,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test8': 40,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test9': 41,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test10': 42,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test11': 43,
    'tarih/dagilma_1_dunya_savasi/dagilma_1_dunya_savasi_test12': 44,

    // Dağılma Dönemi ✅
    'tarih/dagilma_donemi/dagilma_test1': 45,
    'tarih/dagilma_donemi/dagilma_test2': 46,
    'tarih/dagilma_donemi/dagilma_test3': 47,
    'tarih/dagilma_donemi/dagilma_test4': 48,
    'tarih/dagilma_donemi/dagilma_test5': 49,
    'tarih/dagilma_donemi/dagilma_test6': 50,
    'tarih/dagilma_donemi/dagilma_test7': 51,
    'tarih/dagilma_donemi/dagilma_test8': 52,

    // Çağdaş Türk ve Dünya Tarihi ✅
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test1': 53,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test2': 54,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test3': 55,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test4': 56,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test5': 57,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test6': 58,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test7': 59,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test8': 60,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test9': 61,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test10': 62,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test11': 63,
    'tarih/cagdas_turk_ve_dunya_tarihi/cagdas_turk_test12': 64,

    // Milli Mücadele Hazırlık ✅
    'tarih/milli_mucadele_hazirlik/milli_mucadele_hazirlik_test1': 65,
    'tarih/milli_mucadele_hazirlik/milli_mucadele_hazirlik_test2': 66,
    'tarih/milli_mucadele_hazirlik/milli_mucadele_hazirlik_test3': 67,
    'tarih/milli_mucadele_hazirlik/milli_mucadele_hazirlik_test4': 68,
    'tarih/milli_mucadele_hazirlik/milli_mucadele_hazirlik_test5': 69,

    // Milli Mücadele ✅
    'tarih/milli_mucadele/milli_mucadele_test1': 70,
    'tarih/milli_mucadele/milli_mucadele_test2': 71,
    'tarih/milli_mucadele/milli_mucadele_test3': 72,
    'tarih/milli_mucadele/milli_mucadele_test4': 73,

    // Atatürk Dönemi ✅
    'tarih/ataturk_donemi/ataturk_test1': 74,
    'tarih/ataturk_donemi/ataturk_test2': 75,
    'tarih/ataturk_donemi/ataturk_test3': 76,
    'tarih/ataturk_donemi/ataturk_test4': 77,
    'tarih/ataturk_donemi/ataturk_test5': 78,
    'tarih/ataturk_donemi/ataturk_test6': 79,
    'tarih/ataturk_donemi/ataturk_test7': 80,
    'tarih/ataturk_donemi/ataturk_test8': 81,
    'tarih/ataturk_donemi/ataturk_test9': 82,

    // Coğrafya - Sanayi ✅
    'cografya/sanayi/sanayi_test1': 83,
    'cografya/sanayi/sanayi_test2': 84,
    'cografya/sanayi/sanayi_test3': 85,
    'cografya/sanayi/sanayi_test4': 86,

    // Coğrafya - Nüfus ✅
    'cografya/nufus/nufus_test1': 87,
    'cografya/nufus/nufus_test2': 88,
    'cografya/nufus/nufus_test3': 89,
    'cografya/nufus/nufus_test4': 90,
    'cografya/nufus/nufus_test5': 91,
    'cografya/nufus/nufus_test6': 92,

    // Coğrafya - Yer Şekilleri ✅
    'cografya/yer_sekilleri/yer_sekilleri_test1': 93,
    'cografya/yer_sekilleri/yer_sekilleri_test2': 94,
    'cografya/yer_sekilleri/yer_sekilleri_test3': 95,
    'cografya/yer_sekilleri/yer_sekilleri_test4': 96,

    // Coğrafya - Coğrafi Konum ✅
    'cografya/cografi_konum/cografi_konum_test1': 97,
    'cografya/cografi_konum/cografi_konum_test2': 98,
    'cografya/cografi_konum/cografi_konum_test3': 99,
    'cografya/cografi_konum/cografi_konum_test4': 100,

    // Coğrafya - İklim ✅
    'cografya/iklim/iklim_test1': 101,
    'cografya/iklim/iklim_test2': 102,
    'cografya/iklim/iklim_test3': 103,
    'cografya/iklim/iklim_test4': 104,

    // Coğrafya - Dağlar ✅
    'cografya/daglar/daglar_test1': 105,
    'cografya/daglar/daglar_test2': 106,
    'cografya/daglar/daglar_test3': 107,

    // Coğrafya - Tarım ✅
    'cografya/tarim/tarim_test1': 108,
    'cografya/tarim/tarim_test2': 109,
    'cografya/tarim/tarim_test3': 110,

    // Coğrafya - Projeler ✅
    'cografya/projeler/projeler_test1': 111,
    'cografya/projeler/projeler_test2': 112,

    // Coğrafya - Turizm-Ticaret-Ulaşım ✅
    'cografya/turizm_ticaret_ulasim/turizm_ticaret_ulasim_test1': 113,
    'cografya/turizm_ticaret_ulasim/turizm_ticaret_ulasim_test2': 114,
    'cografya/turizm_ticaret_ulasim/turizm_ticaret_ulasim_test3': 115,
    'cografya/turizm_ticaret_ulasim/turizm_ticaret_ulasim_test4': 116,
    'cografya/turizm_ticaret_ulasim/turizm_ticaret_ulasim_test5': 117,

    // Coğrafya - Madencilik ✅
    'cografya/madencilik/madencilik_test1': 118,
    'cografya/madencilik/madencilik_test2': 119,
    'cografya/madencilik/madencilik_test3': 120,
    'cografya/madencilik/madencilik_test4': 121,

    // Eğitim ✅
    // Eğitim ve Öğretim Teknolojileri (ID: 122-128)
    'egitim/egitim_ve_ogretim_teknolojileri/egitim_ve_ogretim_teknolojileri_test1':
        122,
    'egitim/egitim_ve_ogretim_teknolojileri/egitim_ve_ogretim_teknolojileri_test2':
        123,
    'egitim/egitim_ve_ogretim_teknolojileri/egitim_ve_ogretim_teknolojileri_test3':
        124,
    'egitim/egitim_ve_ogretim_teknolojileri/egitim_ve_ogretim_teknolojileri_test4':
        125,
    'egitim/egitim_ve_ogretim_teknolojileri/egitim_ve_ogretim_teknolojileri_test5':
        126,
    'egitim/egitim_ve_ogretim_teknolojileri/egitim_ve_ogretim_teknolojileri_test6':
        127,
    'egitim/egitim_ve_ogretim_teknolojileri/egitim_ve_ogretim_teknolojileri_test7':
        128,

    // Eğitimin Temel Kavramları (ID: 129-144)
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test1': 129,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test2': 130,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test3': 131,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test4': 132,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test5': 133,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test6': 134,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test7': 135,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test8': 136,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test9': 137,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test10': 138,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test11': 139,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test12': 140,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test13': 141,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test14': 142,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test15': 143,
    'egitim/egitimin_temel_kavramlari/egitimin_temel_kavramlari_test16': 144,

    // Eğitimin Temelleri ve Kuramlar (ID: 145-160)
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test1':
        145,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test2':
        146,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test3':
        147,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test4':
        148,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test5':
        149,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test6':
        150,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test7':
        151,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test8':
        152,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test9':
        153,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test10':
        154,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test11':
        155,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test12':
        156,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test13':
        157,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test14':
        158,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test15':
        159,
    'egitim/egitimin_temelleri_ve_kuramlar/egitimin_temelleri_ve_kuramlar_test16':
        160,

    // Maarif Modeli (ID: 161-168)
    'egitim/maarif_modeli/maarif_modeli_test1': 161,
    'egitim/maarif_modeli/maarif_modeli_test2': 162,
    'egitim/maarif_modeli/maarif_modeli_test3': 163,
    'egitim/maarif_modeli/maarif_modeli_test4': 164,
    'egitim/maarif_modeli/maarif_modeli_test5': 165,
    'egitim/maarif_modeli/maarif_modeli_test6': 166,
    'egitim/maarif_modeli/maarif_modeli_test7': 167,
    'egitim/maarif_modeli/maarif_modeli_test8': 168,

    // Türk Milli Eğitim Sistemi (ID: 169-174)
    'egitim/turk_milli_egitim_sistemi/turk_milli_egitim_sistemi_test1': 169,
    'egitim/turk_milli_egitim_sistemi/turk_milli_egitim_sistemi_test2': 170,
    'egitim/turk_milli_egitim_sistemi/turk_milli_egitim_sistemi_test3': 171,
    'egitim/turk_milli_egitim_sistemi/turk_milli_egitim_sistemi_test4': 172,
    'egitim/turk_milli_egitim_sistemi/turk_milli_egitim_sistemi_test5': 173,
    'egitim/turk_milli_egitim_sistemi/turk_milli_egitim_sistemi_test6': 174,

    // Mevzuat ✅
    // 1739 Sayılı Milli Eğitim Temel Kanunu (ID: 175-181)
    'mevzuat/1739_sayili_milli_egitim_temel_kanunu/1739_sayili_milli_egitim_temel_kanunu_test1':
        175,
    'mevzuat/1739_sayili_milli_egitim_temel_kanunu/1739_sayili_milli_egitim_temel_kanunu_test2':
        176,
    'mevzuat/1739_sayili_milli_egitim_temel_kanunu/1739_sayili_milli_egitim_temel_kanunu_test3':
        177,
    'mevzuat/1739_sayili_milli_egitim_temel_kanunu/1739_sayili_milli_egitim_temel_kanunu_test4':
        178,
    'mevzuat/1739_sayili_milli_egitim_temel_kanunu/1739_sayili_milli_egitim_temel_kanunu_test5':
        179,
    'mevzuat/1739_sayili_milli_egitim_temel_kanunu/1739_sayili_milli_egitim_temel_kanunu_test6':
        180,
    'mevzuat/1739_sayili_milli_egitim_temel_kanunu/1739_sayili_milli_egitim_temel_kanunu_test7':
        181,

    // 1982 Anayasası: Genel Esaslar ve Devletin Nitelikleri (ID: 182)
    'mevzuat/1982_anayasasi_genel_esaslar_ve_devletin_nitelikleri/1982_anayasasi_genel_esaslar_ve_devletin_nitelikleri_test1':
        182,

    // 222 Sayılı İlköğretim ve Eğitim Kanunu (ID: 183-184)
    'mevzuat/222_sayili_ilkogretim_ve_egitim_kanunu/222_sayili_ilkogretim_ve_egitim_kanunu_test1':
        183,
    'mevzuat/222_sayili_ilkogretim_ve_egitim_kanunu/222_sayili_ilkogretim_ve_egitim_kanunu_test2':
        184,

    // 7528 Sayılı Öğretmenlik Meslek Kanunu Özellikleri (ID: 185-192)
    'mevzuat/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri_test1':
        185,
    'mevzuat/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri_test2':
        186,
    'mevzuat/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri_test3':
        187,
    'mevzuat/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri_test4':
        188,
    'mevzuat/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri_test5':
        189,
    'mevzuat/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri_test6':
        190,
    'mevzuat/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri_test7':
        191,
    'mevzuat/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri/7528_sayili_ogretmenlik_meslek_kanunu_ozellikleri_test8':
        192,

    // İdare (ID: 193-196)
    'mevzuat/idare/idare_test1': 193,
    'mevzuat/idare/idare_test2': 194,
    'mevzuat/idare/idare_test3': 195,
    'mevzuat/idare/idare_test4': 196,

    // Temel Hak ve Hürriyetler (ID: 197-200)
    'mevzuat/temel_hak_ve_hurriyetler/temel_hak_ve_hurriyetler_test1': 197,
    'mevzuat/temel_hak_ve_hurriyetler/temel_hak_ve_hurriyetler_test2': 198,
    'mevzuat/temel_hak_ve_hurriyetler/temel_hak_ve_hurriyetler_test3': 199,
    'mevzuat/temel_hak_ve_hurriyetler/temel_hak_ve_hurriyetler_test4': 200,

    // Yargı (ID: 201-207)
    'mevzuat/yargi/yargi_test1': 201,
    'mevzuat/yargi/yargi_test2': 202,
    'mevzuat/yargi/yargi_test3': 203,
    'mevzuat/yargi/yargi_test4': 204,
    'mevzuat/yargi/yargi_test5': 205,
    'mevzuat/yargi/yargi_test6': 206,
    'mevzuat/yargi/yargi_test7': 207,

    // Yasama (ID: 208-213)
    'mevzuat/yasama/yasama_test1': 208,
    'mevzuat/yasama/yasama_test2': 209,
    'mevzuat/yasama/yasama_test3': 210,
    'mevzuat/yasama/yasama_test4': 211,
    'mevzuat/yasama/yasama_test5': 212,
    'mevzuat/yasama/yasama_test6': 213,

    // Yürütme (ID: 214-219)
    'mevzuat/yurutme/yurutme_test1': 214,
    'mevzuat/yurutme/yurutme_test2': 215,
    'mevzuat/yurutme/yurutme_test3': 216,
    'mevzuat/yurutme/yurutme_test4': 217,
    'mevzuat/yurutme/yurutme_test5': 218,
    'mevzuat/yurutme/yurutme_test6': 219,
  };

  /// İlk kurulumda veya versiyon güncellemesinde JSON dosyalarını yükle
  static Future<void> initializeQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoaded = prefs.getBool(_dataLoadedKey) ?? false;
      final version = prefs.getInt(_versionKey) ?? 0;

      // Sadece gerektiğinde yükle
      if (!isLoaded || version < _currentVersion) {
        print('📚 Sorular yükleniyor... (Version: $_currentVersion)');
        await _loadAllQuestions();

        await prefs.setBool(_dataLoadedKey, true);
        await prefs.setInt(_versionKey, _currentVersion);
        print('✅ Sorular başarıyla yüklendi! (${_testMapping.length} test)');
      } else {
        print('ℹ️ Sorular zaten yüklü (Version: $version)');
      }
    } catch (e) {
      print('❌ Soru yükleme hatası: $e');
      rethrow;
    }
  }

  /// Tüm JSON dosyalarını yükle (Ultra fast parallel processing)
  static Future<void> _loadAllQuestions() async {
    try {
      // Önce mevcut soruları temizle
      await _clearJsonQuestions();

      // Asset manifest'i bir kez oku
      final assetKeys = await _getAssetManifestKeys();

      // Mevcut asset'leri filtrele
      final availableTests = _testMapping.entries
          .where((entry) =>
              assetKeys.contains('assets/questions/${entry.key}.json'))
          .toList();

      print('📚 ${availableTests.length} test dosyası yükleniyor...');

      // TÜM DOSYALARI TEK SEFERDE PARALEL YÜKLE
      final results = await Future.wait(
        availableTests.map((entry) =>
            _loadQuestionsFromAsset(entry.key, entry.value, assetKeys)),
        eagerError: false,
      );

      // Sonuçları topla
      int totalLoaded = 0;
      int totalErrors = 0;

      for (final result in results) {
        if (result.success) {
          totalLoaded += result.questionCount;
        } else {
          totalErrors++;
          if (kDebugMode) {
            print('⚠️ Yükleme hatası: ${result.error}');
          }
        }
      }

      print('✅ Yükleme tamamlandı: $totalLoaded soru, $totalErrors hata');
    } catch (e) {
      print('❌ Toplu yükleme hatası: $e');
      rethrow;
    }
  }

  /// AssetManifest.json anahtarlarını oku (mevcut asset yolları)
  static Future<Set<String>> _getAssetManifestKeys() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestJson);
      return manifestMap.keys.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// Belirli bir JSON dosyasını yükle (Optimized)
  static Future<LoadResult> _loadQuestionsFromAsset(
      String fileName, int testId, Set<String> assetKeys) async {
    try {
      final assetPath = 'assets/questions/$fileName.json';

      // Asset kontrolü
      if (!assetKeys.contains(assetPath)) {
        return LoadResult(
            success: false, questionCount: 0, error: 'Asset bulunamadı');
      }

      final dbHelper = DatabaseHelper.instance;

      // JSON dosyasını oku
      final jsonString = await rootBundle.loadString(assetPath);

      // Background thread'de parse et
      final questions = await compute(_parseQuestionsFromJson, {
        'jsonString': jsonString,
        'testId': testId,
      });

      if (questions.isEmpty) {
        return LoadResult(
            success: false, questionCount: 0, error: 'Soru bulunamadı');
      }

      // Database'e batch insert ile ekle
      await dbHelper.insertQuestionsBatch(questions);

      // Testin gerçek soru sayısını güncelle
      await dbHelper.updateTestQuestionCount(testId, questions.length);

      return LoadResult(success: true, questionCount: questions.length);
    } catch (e) {
      return LoadResult(success: false, questionCount: 0, error: e.toString());
    }
  }

  /// Background thread'de JSON parsing (Ultra optimized)
  static List<Question> _parseQuestionsFromJson(Map<String, dynamic> data) {
    try {
      final jsonString = data['jsonString'] as String? ?? '';
      final testId = data['testId'] as int? ?? 0;

      if (jsonString.isEmpty || testId == 0) {
        return <Question>[];
      }

      // Daha hızlı JSON parsing
      final List<dynamic> jsonList = json.decode(jsonString);
      final questions = <Question>[];

      for (int i = 0; i < jsonList.length; i++) {
        try {
          final questionData = jsonList[i] as Map<String, dynamic>?;
          if (questionData != null) {
            final question = Question.fromJson(questionData, testId);
            // Geçerli soru kontrolü
            if (_isValidQuestion(question)) {
              questions.add(question);
            }
          }
        } catch (e) {
          // Hatalı soruyu atla ve devam et
          continue;
        }
      }

      return questions;
    } catch (e) {
      return <Question>[];
    }
  }

  /// Soru geçerliliğini kontrol et
  static bool _isValidQuestion(Question question) {
    return question.questionText.isNotEmpty &&
        question.optionA.isNotEmpty &&
        question.optionB.isNotEmpty &&
        question.optionC.isNotEmpty &&
        ['a', 'b', 'c'].contains(question.correctAnswer.toLowerCase());
  }

  /// JSON'dan gelen soruları temizle (Optimized)
  static Future<void> _clearJsonQuestions() async {
    try {
      final dbHelper = DatabaseHelper.instance;

      // Batch delete için test ID'leri grupla
      final testIds = _testMapping.values.toList();
      const batchSize = 50;

      for (int i = 0; i < testIds.length; i += batchSize) {
        final end =
            (i + batchSize < testIds.length) ? i + batchSize : testIds.length;
        final batch = testIds.sublist(i, end);

        await Future.wait(
          batch.map((testId) => dbHelper.clearQuestionsByTestId(testId)),
        );
      }
    } catch (e) {
      print('⚠️ Soru temizleme hatası: $e');
    }
  }

  /// Test için soruları getir (hızlı SQLite sorgusu)
  static Future<List<Question>> getQuestionsByTestId(int testId) async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.getQuestionsByTestId(testId);
  }

  /// Veriler yüklendi mi kontrol et
  static Future<bool> isDataLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dataLoadedKey) ?? false;
  }

  /// Verileri yeniden yüklemek için (geliştirme/test amaçlı)
  static Future<void> forceReload() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dataLoadedKey);
    await prefs.remove(_versionKey);
    await initializeQuestions();
  }
}
