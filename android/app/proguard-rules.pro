# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Prevent obfuscation of Camera and Image packages
-keep class androidx.camera.** { *; }
-keep class com.google.common.util.concurrent.** { *; }
-dontwarn androidx.camera.**

# Suppress common harmless warnings
-dontwarn io.flutter.**
-dontwarn com.google.errorprone.annotations.**
