# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive database
-keep class hive.** { *; }
-keep class hive_flutter.** { *; }

# Excel package
-keep class excel.** { *; }
-keep class archive.** { *; }

# File picker
-keep class file_picker.** { *; }

# Share plus
-keep class share_plus.** { *; }

# Provider
-keep class provider.** { *; }

# Go router
-keep class go_router.** { *; }

# Path provider
-keep class path_provider.** { *; }

# Permission handler
-keep class permission_handler.** { *; }

# General Android rules
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep custom classes (if any)
-keep class com.xlsfilereader.app.** { *; }

# Prevent obfuscation of model classes
-keep class * extends java.io.Serializable { *; }
-keepclassmembers class * extends java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
} 