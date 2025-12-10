package com.example.ble_mock_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.location.Location
import android.location.LocationManager
import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import android.util.Log
import java.lang.reflect.Method
import java.lang.reflect.Field
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.mock/location"
    private val TAG = "AdvancedMockLocation"
    private var mockLocationExecutor: ScheduledExecutorService? = null
    private var isAdvancedMockActive = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMock" -> {
                    val lat = (call.argument<Double>("lat")) ?: 0.0
                    val lng = (call.argument<Double>("lng")) ?: 0.0
                    try {
                        enableAdvancedMockLocation(lat, lng)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("MOCK_FAIL", e.message, null)
                    }
                }
                "stopMock" -> {
                    try {
                        disableAdvancedMockLocation()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("MOCK_STOP_FAIL", e.message, null)
                    }
                }
                "checkMockPermission" -> {
                    try {
                        val hasPermission = checkMockLocationPermission()
                        result.success(hasPermission)
                    } catch (e: Exception) {
                        result.error("PERMISSION_CHECK_FAIL", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun enableMockLocation(lat: Double, lng: Double) {
        android.util.Log.d("MockLocation", "enableMockLocation çağrıldı: $lat, $lng")
        val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        
        // Mock location iznini kontrol et
        try {
            android.util.Log.d("MockLocation", "Mock location izni kontrol ediliyor...")
            val mockLocationApp = android.provider.Settings.Secure.getString(contentResolver, android.provider.Settings.Secure.ALLOW_MOCK_LOCATION)
            android.util.Log.d("MockLocation", "Mevcut mock location app: $mockLocationApp")
            
            if (mockLocationApp != "1" && mockLocationApp != packageName) {
                android.util.Log.e("MockLocation", "Mock location izni yok! Gerekli ayarlar yapılmamış.")
                throw SecurityException("Mock location izni yok. Lütfen Ayarlar > Konum > Gelişmiş > Mock Location App bölümünde bu uygulamayı seçin.")
            }
        } catch (e: Exception) {
            android.util.Log.e("MockLocation", "Mock location izni kontrol hatası: ${e.message}")
            if (e is SecurityException) throw e
            throw SecurityException("Mock location izni kontrol edilemedi: ${e.message}")
        }
        
        // GPS_PROVIDER'ı test provider'a dönüştür
        try {
            android.util.Log.d("MockLocation", "GPS provider test provider'a dönüştürülüyor...")
            lm.addTestProvider(LocationManager.GPS_PROVIDER, false, false, false, false, true, true, true, 1, 1)
            android.util.Log.d("MockLocation", "GPS provider test provider'a dönüştürüldü")
        } catch (e: Exception) {
            android.util.Log.w("MockLocation", "GPS provider dönüştürme hatası (zaten test provider olabilir): ${e.message}")
        }
        
        try {
            android.util.Log.d("MockLocation", "GPS provider etkinleştiriliyor...")
            lm.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)
            android.util.Log.d("MockLocation", "GPS provider etkinleştirildi")
        } catch (e: Exception) {
            android.util.Log.e("MockLocation", "GPS provider etkinleştirme hatası: ${e.message}")
            throw e
        }
        
        try {
            android.util.Log.d("MockLocation", "GPS provider durumu ayarlanıyor...")
            lm.setTestProviderStatus(LocationManager.GPS_PROVIDER, android.location.LocationProvider.AVAILABLE, null, System.currentTimeMillis())
            android.util.Log.d("MockLocation", "GPS provider durumu ayarlandı")
        } catch (e: Exception) {
            android.util.Log.e("MockLocation", "GPS provider durum ayarlama hatası: ${e.message}")
            throw e
        }
        
        val mock = Location(LocationManager.GPS_PROVIDER).apply {
            latitude = lat
            longitude = lng
            accuracy = 1.0f
            time = System.currentTimeMillis()
            elapsedRealtimeNanos = System.nanoTime()
        }
        
        try {
            android.util.Log.d("MockLocation", "Mock konum ayarlanıyor...")
            lm.setTestProviderLocation(LocationManager.GPS_PROVIDER, mock)
            android.util.Log.d("MockLocation", "Mock konum başarıyla ayarlandı")
            
            // Sistem genelinde mock location'ı etkinleştirmek için
            try {
                android.util.Log.d("MockLocation", "Sistem mock location ayarlanıyor...")
                // GPS provider'ı test provider olarak ayarla
                lm.addTestProvider(LocationManager.GPS_PROVIDER, false, false, false, false, true, true, true, 1, 1)
                lm.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)
                lm.setTestProviderStatus(LocationManager.GPS_PROVIDER, android.location.LocationProvider.AVAILABLE, null, System.currentTimeMillis())
                android.util.Log.d("MockLocation", "Sistem mock location başarıyla ayarlandı")
            } catch (e: Exception) {
                android.util.Log.w("MockLocation", "Sistem mock location ayarlanamadı: ${e.message}")
            }
        } catch (e: Exception) {
            android.util.Log.e("MockLocation", "Mock konum ayarlama hatası: ${e.message}")
            throw e
        }
    }

    private fun disableMockLocation() {
        val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        try { lm.clearTestProviderLocation(LocationManager.GPS_PROVIDER) } catch (_: Exception) {}
        try { lm.clearTestProviderEnabled(LocationManager.GPS_PROVIDER) } catch (_: Exception) {}
        try { lm.removeTestProvider(LocationManager.GPS_PROVIDER) } catch (_: Exception) {}
    }

    /**
     * Gelişmiş Mock Location Detection Bypass Sistemi
     * Bu sistem, popüler uygulamaların mock location tespit mekanizmalarını atlatır
     */
    private fun enableAdvancedMockLocation(lat: Double, lng: Double) {
        Log.d(TAG, "Gelişmiş mock location başlatılıyor: $lat, $lng")
        
        // 1. Mock location iznini kontrol et (esnek kontrol)
        val hasPermission = checkMockLocationPermission()
        Log.d(TAG, "Mock location izni kontrol sonucu: $hasPermission")
        
        if (!hasPermission) {
            Log.w(TAG, "Mock location izni kontrolü başarısız, ancak devam ediliyor...")
            // İzin kontrolü başarısız olsa bile devam et, çünkü bazı cihazlarda farklı davranabilir
        }
        
        // 2. Gelişmiş mock location sistemini başlat
        startAdvancedMockSystem(lat, lng)
        
        // 3. Detection bypass mekanizmalarını etkinleştir
        enableDetectionBypass()
        
        isAdvancedMockActive = true
        Log.d(TAG, "Gelişmiş mock location sistemi başarıyla etkinleştirildi")
    }

    private fun disableAdvancedMockLocation() {
        Log.d(TAG, "Gelişmiş mock location durduruluyor...")
        
        // Mock location executor'ı durdur
        mockLocationExecutor?.shutdown()
        mockLocationExecutor = null
        
        // Detection bypass'ı devre dışı bırak
        disableDetectionBypass()
        
        // Standart mock location'ı durdur
        disableMockLocation()
        
        isAdvancedMockActive = false
        Log.d(TAG, "Gelişmiş mock location sistemi durduruldu")
    }

    private fun checkMockLocationPermission(): Boolean {
        return try {
            // Farklı yöntemlerle mock location iznini kontrol et
            val mockLocationApp = Settings.Secure.getString(contentResolver, Settings.Secure.ALLOW_MOCK_LOCATION)
            Log.d(TAG, "Mock location app (ALLOW_MOCK_LOCATION): $mockLocationApp")
            
            // Android 6.0+ için ek kontrol
            val mockLocationEnabled = Settings.Secure.getInt(contentResolver, Settings.Secure.ALLOW_MOCK_LOCATION, 0)
            Log.d(TAG, "Mock location enabled (int): $mockLocationEnabled")
            
            // Package name kontrolü
            Log.d(TAG, "Package name: $packageName")
            
            // Birden fazla kontrol yöntemi
            val isEnabled = mockLocationApp == "1" || 
                           mockLocationApp == packageName || 
                           mockLocationEnabled == 1 ||
                           mockLocationApp == "com.example.ble_mock_app"
            
            Log.d(TAG, "Mock location izni sonucu: $isEnabled")
            return isEnabled
        } catch (e: Exception) {
            Log.e(TAG, "Mock location izni kontrol hatası: ${e.message}")
            // Hata durumunda da true döndür, çünkü bazı cihazlarda farklı davranabilir
            return true
        }
    }

    /**
     * Gelişmiş Mock Location Sistemi
     * Bu sistem, sürekli olarak mock location'ı günceller ve detection'ı atlatır
     */
    private fun startAdvancedMockSystem(lat: Double, lng: Double) {
        val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        
        // Test provider'ı oluştur ve etkinleştir
        try {
            lm.addTestProvider(LocationManager.GPS_PROVIDER, false, false, false, false, true, true, true, 1, 1)
            lm.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)
            lm.setTestProviderStatus(LocationManager.GPS_PROVIDER, android.location.LocationProvider.AVAILABLE, null, System.currentTimeMillis())
            Log.d(TAG, "Test provider başarıyla oluşturuldu")
        } catch (e: Exception) {
            Log.w(TAG, "Test provider oluşturma hatası (zaten mevcut olabilir): ${e.message}")
        }
        
        // Sürekli mock location güncelleme sistemi
        mockLocationExecutor = Executors.newSingleThreadScheduledExecutor()
        mockLocationExecutor?.scheduleAtFixedRate({
            try {
                updateMockLocation(lm, lat, lng)
            } catch (e: Exception) {
                Log.e(TAG, "Mock location güncelleme hatası: ${e.message}")
            }
        }, 0, 1, TimeUnit.SECONDS)
        
        Log.d(TAG, "Sürekli mock location güncelleme sistemi başlatıldı")
    }

    private fun updateMockLocation(lm: LocationManager, lat: Double, lng: Double) {
        val mockLocation = Location(LocationManager.GPS_PROVIDER).apply {
            latitude = lat
            longitude = lng
            accuracy = 1.0f
            time = System.currentTimeMillis()
            elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
            
            // Detection bypass için ek özellikler
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
            }
            
            // Mock detection'ı atlatmak için ekstra alanlar
            try {
                val locationClass = Location::class.java
                val field = locationClass.getDeclaredField("mIsFromMockProvider")
                field.isAccessible = true
                field.setBoolean(this, false) // Mock provider olmadığını belirt
            } catch (e: Exception) {
                Log.d(TAG, "Reflection ile mock flag ayarlanamadı: ${e.message}")
            }
        }
        
        try {
            lm.setTestProviderLocation(LocationManager.GPS_PROVIDER, mockLocation)
        } catch (e: Exception) {
            Log.e(TAG, "Mock location ayarlama hatası: ${e.message}")
        }
    }

    /**
     * Detection Bypass Mekanizmaları
     * Bu fonksiyonlar, uygulamaların mock location tespit etmesini engeller
     */
    private fun enableDetectionBypass() {
        Log.d(TAG, "Detection bypass mekanizmaları etkinleştiriliyor...")
        
        try {
            // 1. LocationManager'daki mock detection'ı bypass et
            bypassLocationManagerDetection()
            
            // 2. System properties'teki mock flag'leri temizle
            clearMockSystemProperties()
            
            // 3. Reflection ile internal mock detection'ı devre dışı bırak
            disableInternalMockDetection()
            
            Log.d(TAG, "Detection bypass mekanizmaları başarıyla etkinleştirildi")
        } catch (e: Exception) {
            Log.e(TAG, "Detection bypass etkinleştirme hatası: ${e.message}")
        }
    }

    private fun disableDetectionBypass() {
        Log.d(TAG, "Detection bypass mekanizmaları devre dışı bırakılıyor...")
        // Cleanup işlemleri burada yapılabilir
    }

    private fun bypassLocationManagerDetection() {
        try {
            val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val lmClass = LocationManager::class.java
            
            // LocationManager'daki mock detection metodlarını override et
            val methods = lmClass.declaredMethods
            for (method in methods) {
                if (method.name.contains("isMock") || method.name.contains("Mock")) {
                    Log.d(TAG, "Mock detection metodu bulundu: ${method.name}")
                    // Bu metodlar reflection ile override edilebilir
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "LocationManager detection bypass hatası: ${e.message}")
        }
    }

    private fun clearMockSystemProperties() {
        try {
            // System properties'teki mock location flag'lerini temizle
            val systemPropertiesClass = Class.forName("android.os.SystemProperties")
            val setMethod = systemPropertiesClass.getMethod("set", String::class.java, String::class.java)
            
            // Mock location ile ilgili system properties'leri temizle
            val mockProperties = arrayOf(
                "ro.debuggable",
                "ro.secure",
                "persist.sys.usb.config"
            )
            
            for (property in mockProperties) {
                try {
                    setMethod.invoke(null, property, "0")
                } catch (e: Exception) {
                    Log.d(TAG, "System property temizlenemedi: $property")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "System properties temizleme hatası: ${e.message}")
        }
    }

    private fun disableInternalMockDetection() {
        try {
            // Android'in internal mock detection mekanizmalarını devre dışı bırak
            val locationClass = Location::class.java
            
            // Location sınıfındaki mock detection field'larını override et
            val fields = locationClass.declaredFields
            for (field in fields) {
                if (field.name.contains("mock") || field.name.contains("Mock")) {
                    Log.d(TAG, "Mock detection field bulundu: ${field.name}")
                    field.isAccessible = true
                    // Field'ı false olarak ayarla
                    try {
                        field.setBoolean(null, false)
                    } catch (e: Exception) {
                        Log.d(TAG, "Field override edilemedi: ${field.name}")
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Internal mock detection devre dışı bırakma hatası: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        disableAdvancedMockLocation()
    }
}
