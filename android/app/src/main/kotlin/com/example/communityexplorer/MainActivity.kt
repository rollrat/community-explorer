package xyz.violet.communityexplorer

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
  
    private val NATIVELIBDIR_CHANNEL = "xyz.violet.communityexplorer/nativelibdir";

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NATIVELIBDIR_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getNativeDir") {
                result.success(getApplicationContext().getApplicationInfo().nativeLibraryDir);
            }
            result.notImplemented()
        }

    }
}
