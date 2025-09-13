# 📱 RESPONSİVE TASARIM KURALLARI

## 🚨 ZORUNLU KURALLAR

### ❌ ASLA KULLANMA:
```dart
// ❌ YANLIŞ - Sabit değerler
const SizedBox(height: 20)
const EdgeInsets.all(16)
const EdgeInsets.symmetric(horizontal: 12)
fontSize: 18
width: 100
height: 50
borderRadius: BorderRadius.circular(12)
```

### ✅ HER ZAMAN KULLAN:
```dart
// ✅ DOĞRU - Responsive değerler
SizedBox(height: ResponsiveHelper.getVerticalPadding(context))
EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context))
EdgeInsets.symmetric(horizontal: ResponsiveHelper.getHorizontalPadding(context))
fontSize: ResponsiveHelper.getHeaderFontSize(context)
width: ResponsiveHelper.getIconSize(context, defaultSize: 100)
height: ResponsiveHelper.getIconSize(context, defaultSize: 50)
borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context, defaultRadius: 12))
```

## 📏 RESPONSİVE DEĞER KATEGORİLERİ

### 🎨 **TASARIM DEĞERLERİ (Sabit Kalabilir):**
- `opacity` değerleri (0.1, 0.2, 0.3, vb.)
- `color` kodları (#FF0000, Colors.red, vb.)
- `fontWeight` değerleri (FontWeight.bold, FontWeight.w500, vb.)
- `letterSpacing` değerleri
- `textAlign` değerleri (TextAlign.center, TextAlign.left, vb.)
- `mainAxisAlignment` değerleri
- `crossAxisAlignment` değerleri
- `maxLines` değerleri
- `textOverflow` değerleri
- `elevation` değerleri
- `shadowColor` değerleri
- `backgroundColor` değerleri
- `foregroundColor` değerleri
- `duration` değerleri (performans için)
- `curve` değerleri
- `border` width değerleri (1, 2, vb.)

### 📐 **LAYOUT DEĞERLERİ (Responsive Olmalı):**
- `SizedBox` boyutları
- `EdgeInsets` değerleri
- `Container` boyutları
- `Icon` boyutları
- `fontSize` değerleri
- `padding` değerleri
- `margin` değerleri
- `BorderRadius` değerleri
- `BoxShadow` blurRadius ve offset değerleri
- `width` ve `height` değerleri

## 🔧 RESPONSİVE HELPER KULLANIMI

### 📱 **Ekran Kategorileri:**
```dart
// Ekran boyut kontrolü
ResponsiveHelper.isExtraSmallScreen(context) // < 320px
ResponsiveHelper.isSmallScreen(context)      // < 360px
ResponsiveHelper.isMediumScreen(context)     // 360-400px
ResponsiveHelper.isLargeScreen(context)      // > 400px
```

### 📏 **Boyut Değerleri:**
```dart
// Padding değerleri
ResponsiveHelper.getHorizontalPadding(context)  // 8-20px
ResponsiveHelper.getVerticalPadding(context)    // 12-24px

// Font boyutları
ResponsiveHelper.getHeaderFontSize(context)     // 16-24px
ResponsiveHelper.getSubheaderFontSize(context)  // 11-14px
ResponsiveHelper.getBodyFontSize(context)       // 13-16px

// Icon boyutları
ResponsiveHelper.getIconSize(context, defaultSize: 24) // 16.8-24px

// Nav bar değerleri
ResponsiveHelper.getNavBarHeight(context)       // 40-60px
ResponsiveHelper.getNavBarItemSize(context)     // 26-48px
ResponsiveHelper.getNavBarIconSize(context)     // 12-24px

// Border radius
ResponsiveHelper.getBorderRadius(context, defaultRadius: 12) // 9.6-12px
```

## 🎯 KOD ŞABLONLARI

### 📦 **Container Şablonu:**
```dart
Container(
  width: ResponsiveHelper.getIconSize(context, defaultSize: 100),
  height: ResponsiveHelper.getIconSize(context, defaultSize: 50),
  padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
  margin: EdgeInsets.symmetric(
    horizontal: ResponsiveHelper.getHorizontalPadding(context),
    vertical: ResponsiveHelper.getVerticalPadding(context),
  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(
      ResponsiveHelper.getBorderRadius(context, defaultRadius: 12)
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF6D79EC).withOpacity(0.08),
        blurRadius: ResponsiveHelper.isSmallScreen(context) ? 12 : 15,
        offset: Offset(0, ResponsiveHelper.isSmallScreen(context) ? 4 : 6),
      ),
    ],
  ),
  child: // İçerik
)
```

### 📝 **Text Şablonu:**
```dart
Text(
  'Metin',
  style: TextStyle(
    fontSize: ResponsiveHelper.getHeaderFontSize(context),
    fontWeight: FontWeight.bold, // Sabit kalabilir
    color: const Color(0xFF6D79EC), // Sabit kalabilir
  ),
)
```

### 🎨 **Icon Şablonu:**
```dart
Icon(
  Icons.home,
  size: ResponsiveHelper.getIconSize(context, defaultSize: 24),
  color: const Color(0xFF6D79EC), // Sabit kalabilir
)
```

### 📏 **SizedBox Şablonu:**
```dart
SizedBox(
  width: ResponsiveHelper.getIconSize(context, defaultSize: 20),
  height: ResponsiveHelper.getVerticalPadding(context),
)
```

### 🎯 **Button Şablonu:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: ResponsiveHelper.getHorizontalPadding(context),
      vertical: ResponsiveHelper.getVerticalPadding(context),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.getBorderRadius(context, defaultRadius: 12)
      ),
    ),
  ),
  onPressed: () {},
  child: Text(
    'Buton',
    style: TextStyle(
      fontSize: ResponsiveHelper.getBodyFontSize(context),
    ),
  ),
)
```

## 🚨 KONTROL LİSTESİ

### ✅ **Her Yeni Widget'ta Kontrol Et:**
- [ ] SizedBox boyutları responsive mi?
- [ ] EdgeInsets değerleri responsive mi?
- [ ] Container boyutları responsive mi?
- [ ] Icon boyutları responsive mi?
- [ ] Font boyutları responsive mi?
- [ ] Padding değerleri responsive mi?
- [ ] Margin değerleri responsive mi?
- [ ] BorderRadius değerleri responsive mi?
- [ ] BoxShadow değerleri responsive mi?

### ❌ **Sabit Kalabilir Değerler:**
- [ ] Opacity değerleri
- [ ] Color kodları
- [ ] FontWeight değerleri
- [ ] LetterSpacing değerleri
- [ ] TextAlign değerleri
- [ ] Alignment değerleri
- [ ] MaxLines değerleri
- [ ] TextOverflow değerleri
- [ ] Elevation değerleri
- [ ] Duration değerleri
- [ ] Curve değerleri
- [ ] Border width değerleri

## 🎯 ÖRNEK KULLANIM

### ❌ **Yanlış Kod:**
```dart
Container(
  width: 100,
  height: 50,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Text(
    'Başlık',
    style: TextStyle(fontSize: 18),
  ),
)
```

### ✅ **Doğru Kod:**
```dart
Container(
  width: ResponsiveHelper.getIconSize(context, defaultSize: 100),
  height: ResponsiveHelper.getIconSize(context, defaultSize: 50),
  padding: EdgeInsets.all(ResponsiveHelper.getHorizontalPadding(context)),
  margin: EdgeInsets.symmetric(
    horizontal: ResponsiveHelper.getHorizontalPadding(context),
    vertical: ResponsiveHelper.getVerticalPadding(context),
  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(
      ResponsiveHelper.getBorderRadius(context, defaultRadius: 12)
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF6D79EC).withOpacity(0.08),
        blurRadius: ResponsiveHelper.isSmallScreen(context) ? 12 : 15,
        offset: Offset(0, ResponsiveHelper.isSmallScreen(context) ? 4 : 6),
      ),
    ],
  ),
  child: Text(
    'Başlık',
    style: TextStyle(
      fontSize: ResponsiveHelper.getHeaderFontSize(context),
    ),
  ),
)
```

## 🚀 SONUÇ

Bu kurallara uyarak yazılan her kod otomatik olarak responsive olacak ve tüm telefonlarda mükemmel görünecek!

**Unutma: Her yeni widget'ta bu kuralları kontrol et!** 📱✨
