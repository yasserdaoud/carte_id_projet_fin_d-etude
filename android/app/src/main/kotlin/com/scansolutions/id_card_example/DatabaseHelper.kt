package com.scansolutions.mrzflutterplugin_example

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper private constructor(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(SQL_CREATE_ENTRIES)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL(SQL_DELETE_ENTRIES)
        onCreate(db)
    }

    fun getLastProfile(): Map<String, String>? {
        val db = this.readableDatabase
        val cursor = db.query(
            TABLE_NAME, null, null, null, null, null, "$COLUMN_ID DESC", "1"
        )

        with(cursor) {
            if (moveToFirst()) {
                val profile = mutableMapOf<String, String>()
                profile["documentNumber"] = getString(getColumnIndexOrThrow(COLUMN_DOCUMENT_NUMBER))
                profile["firstName"] = getString(getColumnIndexOrThrow(COLUMN_FIRST_NAME))
                profile["lastName"] = getString(getColumnIndexOrThrow(COLUMN_LAST_NAME))
                profile["dateOfBirth"] = getString(getColumnIndexOrThrow(COLUMN_DATE_OF_BIRTH))
                profile["nationality"] = getString(getColumnIndexOrThrow(COLUMN_NATIONALITY))
                profile["dateOfExpiry"] = getString(getColumnIndexOrThrow(COLUMN_DATE_OF_EXPIRY))
                // Add other fields as needed
                return profile
            }
        }
        return null
    }

    companion object {
        const val DATABASE_VERSION = 1
        const val DATABASE_NAME = "voterprofile.db"
        const val TABLE_NAME = "profiles"
        const val COLUMN_ID = "id"
        const val COLUMN_DOCUMENT_NUMBER = "documentNumber"
        const val COLUMN_FIRST_NAME = "firstName"
        const val COLUMN_LAST_NAME = "lastName"
        const val COLUMN_DATE_OF_BIRTH = "dateOfBirth"
        const val COLUMN_NATIONALITY = "nationality"
        const val COLUMN_DATE_OF_EXPIRY = "dateOfExpiry"
        // Add other columns as needed

        private var instance: DatabaseHelper? = null

        fun getInstance(context: Context): DatabaseHelper {
            if (instance == null) {
                instance = DatabaseHelper(context.applicationContext)
            }
            return instance!!
        }

        private const val SQL_CREATE_ENTRIES = """
            CREATE TABLE $TABLE_NAME (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_DOCUMENT_NUMBER TEXT NOT NULL,
                $COLUMN_FIRST_NAME TEXT NOT NULL,
                $COLUMN_LAST_NAME TEXT NOT NULL,
                $COLUMN_DATE_OF_BIRTH TEXT NOT NULL,
                $COLUMN_NATIONALITY TEXT NOT NULL,
                $COLUMN_DATE_OF_EXPIRY TEXT NOT NULL
                // Add other columns as needed
            )
        """

        private const val SQL_DELETE_ENTRIES = "DROP TABLE IF EXISTS $TABLE_NAME"
    }
}
