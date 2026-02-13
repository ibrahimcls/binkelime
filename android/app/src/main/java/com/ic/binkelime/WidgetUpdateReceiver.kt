package com.ic.binkelime

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import com.google.firebase.firestore.FirebaseFirestore
import org.json.JSONObject
import java.util.concurrent.CountDownLatch

class WidgetUpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Firebase'den veri çek ve local'e yaz
        fetchAndSaveWordData(context)
    }

    private fun fetchAndSaveWordData(context: Context) {
        try {
            val db = FirebaseFirestore.getInstance()
            val latch = CountDownLatch(1)

            db.collection("current")
                .limit(1)
                .get()
                .addOnSuccessListener { querySnapshot ->
                    try {
                        if (!querySnapshot.isEmpty) {
                            val doc = querySnapshot.documents[0]
                            val use = doc.getString("use") ?: ""
                            val instead = doc.getString("instead") ?: ""
                            val description = doc.getString("description") ?: ""

                            // SharedPreferences'a kaydet
                            val sharedPref = context.getSharedPreferences(
                                "home_widget_prefs",
                                Context.MODE_PRIVATE
                            )
                            sharedPref.edit().apply {
                                putString("use", use)
                                putString("instead", instead)
                                putString("description", description)
                                apply()
                            }

                            // Widget'ı çek ve güncelle
                            val appWidgetManager = AppWidgetManager.getInstance(context)
                            val componentName = ComponentName(context, HomeWidget::class.java)
                            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)

                            for (appWidgetId in appWidgetIds) {
                                updateAppWidget(context, appWidgetManager, appWidgetId)
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    } finally {
                        latch.countDown()
                    }
                }
                .addOnFailureListener { exception ->
                    exception.printStackTrace()
                    latch.countDown()
                }

            // Maksimum 5 saniye bekle
            latch.await()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Sonraki güncellemeyi planla
        WidgetUpdateScheduler.schedulePeriodicUpdates(context)
    }
}
