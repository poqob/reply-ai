-keepattributes *Annotation*,EnclosingMethod,InnerClasses,Signature

-keep class com.write4me.llama_flutter_android.** { *; }

-keep class kotlin.jvm.functions.** { *; }
-keep class kotlin.jvm.internal.** { *; }
-keep class kotlin.coroutines.** { *; }
-keep class kotlin.coroutines.intrinsics.** { *; }

-keepclassmembers class kotlin.Metadata {
    *** *;
}

-dontwarn com.write4me.llama_flutter_android.**
-dontwarn kotlin.**
