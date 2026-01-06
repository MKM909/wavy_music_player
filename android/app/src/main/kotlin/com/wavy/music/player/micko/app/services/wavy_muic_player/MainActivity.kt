package com.wavy.music.player.micko.app.services.wavy_muic_player

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Close any native resources on app restart
        if (savedInstanceState != null) {
            // App is being restarted, clean up
        }
    }

    override fun onDestroy() {
        // Ensure everything is closed properly
        super.onDestroy()
    }
}