/*
package com.scansolutions.mrzflutterplugin_example

import android.app.Activity
import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.nfc.NfcEvent
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class NfcActivity : Activity(), NfcAdapter.CreateNdefMessageCallback {

    private var nfcAdapter: NfcAdapter? = null
    private var nfcData: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_nfc)

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        if (nfcAdapter == null) {
            Toast.makeText(this, "NFC is not available", Toast.LENGTH_LONG).show()
            finish()
            return
        }

        nfcAdapter?.setNdefPushMessageCallback(this, this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.scansolutions.mrzflutterplugin_example/nfc")
            .setMethodCallHandler { call, result ->
                if (call.method == "sendNfcData") {
                    nfcData = call.argument("data")
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun createNdefMessage(event: NfcEvent?): NdefMessage? {
        return nfcData?.let {
            NdefMessage(arrayOf(
                NdefRecord.createMime("application/vnd.com.scansolutions.mrzflutterplugin_example", it.toByteArray())
            ))
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
*/
/*
<activity
android:name=".NfcActivity"
android:launchMode="singleTask">
<intent-filter>
<action android:name="android.nfc.action.NDEF_DISCOVERED" />
<category android:name="android.intent.category.DEFAULT" />
<data android:mimeType="text/plain" />
</intent-filter>
<intent-filter>
<action android:name="android.nfc.action.TECH_DISCOVERED" />
</intent-filter>
<intent-filter>
<action android:name="android.nfc.action.TAG_DISCOVERED" />
</intent-filter>
<meta-data android:name="android.nfc.action.TECH_DISCOVERED"
android:resource="@xml/nfc_tech_filter" />
</activity>

 */