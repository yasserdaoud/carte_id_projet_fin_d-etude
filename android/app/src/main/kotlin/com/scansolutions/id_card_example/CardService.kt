package com.scansolutions.mrzflutterplugin_example

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.util.Log

class CardService : HostApduService() {
    private val TAG = "CardService"
    private val SELECT_OK_SW = byteArrayOf(0x90.toByte(), 0x00.toByte())
    private val UNKNOWN_CMD_SW = byteArrayOf(0x6A.toByte(), 0x00.toByte())
    private val AID = "F0010203040506"
    private val SELECT_APDU_HEADER = byteArrayOf(0x00.toByte(), 0xA4.toByte(), 0x04.toByte(), 0x00.toByte())

    override fun processCommandApdu(apdu: ByteArray?, extras: Bundle?): ByteArray? {
        if (apdu == null) {
            return UNKNOWN_CMD_SW
        }

        Log.i(TAG, "APDU command received: ${bytesToHex(apdu)}")

        return when {
            isSelectApdu(apdu) -> {
                if (aidMatches(apdu, AID)) {
                    SELECT_OK_SW
                } else {
                    UNKNOWN_CMD_SW
                }
            }
            else -> handleOtherCommands(apdu)
        }
    }

    override fun onDeactivated(reason: Int) {
        Log.i(TAG, "Deactivated: $reason")
    }

    private fun isSelectApdu(apdu: ByteArray): Boolean {
        return apdu.size >= 4 && apdu.sliceArray(0..3).contentEquals(SELECT_APDU_HEADER)
    }

    private fun aidMatches(apdu: ByteArray, aid: String): Boolean {
        val aidBytes = hexStringToByteArray(aid)
        return apdu.size >= 5 + aidBytes.size && apdu.sliceArray(5 until 5 + aidBytes.size).contentEquals(aidBytes)
    }

    private fun bytesToHex(bytes: ByteArray): String {
        val sb = StringBuilder()
        for (b in bytes) {
            sb.append(String.format("%02X", b))
        }
        return sb.toString()
    }

    private fun hexStringToByteArray(s: String): ByteArray {
        val len = s.length
        val data = ByteArray(len / 2)
        var i = 0
        while (i < len) {
            data[i / 2] = ((Character.digit(s[i], 16) shl 4) + Character.digit(s[i + 1], 16)).toByte()
            i += 2
        }
        return data
    }

    private fun handleOtherCommands(apdu: ByteArray): ByteArray {
        val commandHex = bytesToHex(apdu)
        Log.i(TAG, "Handling other command: $commandHex")

        if (apdu.size >= 4 && apdu[1] == 0xCA.toByte()) {
            return getCardData()
        }

        return UNKNOWN_CMD_SW
    }

    private fun getCardData(): ByteArray {
        val dbHelper = DatabaseHelper.getInstance(this)
        val profile = dbHelper.getLastProfile()

        if (profile != null) {
            val documentNumber = profile["documentNumber"] ?: ""
            val firstName = profile["firstName"] ?: ""
            val lastName = profile["lastName"] ?: ""

            val response = StringBuilder()
            response.append(documentNumber)
            response.append(firstName)
            response.append(lastName)

            val responseBytes = response.toString().toByteArray(Charsets.UTF_8)
            return responseBytes + SELECT_OK_SW
        }

        return UNKNOWN_CMD_SW
    }
}
