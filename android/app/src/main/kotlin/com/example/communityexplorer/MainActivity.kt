package xyz.violet.communityexplorer

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  
    private val NATIVELIBDIR_CHANNEL = "xyz.violet.communityexplorer2/nativelibdir";

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
