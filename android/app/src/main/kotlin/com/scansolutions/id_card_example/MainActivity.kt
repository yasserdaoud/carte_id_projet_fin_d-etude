package com.scansolutions.mrzflutterplugin_example

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val imageChannel = "image_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // Configure MethodChannel for image decoding
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, imageChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "decodeImage" -> {
                        val jp2ImageData = call.argument<ByteArray?>("jp2ImageData")
                        if (jp2ImageData != null) {
                            ImageUtil.decodeImage(applicationContext, jp2ImageData, result)
                        } else {
                            result.error("INVALID_ARGUMENT", "jp2ImageData is null", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }


    }




}
