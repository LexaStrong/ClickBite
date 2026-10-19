# Flutter engine & plugin registrant
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Play Core (deferred components) - referenced by Flutter but not bundled
-dontwarn com.google.android.play.core.**

# JNI bridge used by native-asset plugins
-keep class com.github.dart_lang.jni.** { *; }
