package com.ic.binkelime

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject

class HomeWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = createWordRemoteViews(context)
            configureDescriptionMaxLines(views, appWidgetManager.getAppWidgetOptions(appWidgetId))
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onEnabled(context: Context) {
        WidgetUpdateScheduler.schedulePeriodicUpdates(context)
    }

    override fun onDisabled(context: Context) {
        WidgetUpdateScheduler.cancelUpdates(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context?,
        appWidgetManager: AppWidgetManager?,
        appWidgetId: Int,
        options: Bundle?
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, options)
        if (context == null || appWidgetManager == null) return
        val views = createWordRemoteViews(context)
        configureDescriptionMaxLines(views, options)
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = createWordRemoteViews(context)
    configureDescriptionMaxLines(views, appWidgetManager.getAppWidgetOptions(appWidgetId))
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun createWordRemoteViews(context: Context): RemoteViews {
    val widgetData = HomeWidgetPlugin.getData(context)
    val sharedPref = context.getSharedPreferences(
        "home_widget_prefs",
        Context.MODE_PRIVATE
    )
    
    val intent = Intent(context, MainActivity::class.java)
    val pendingIntent = PendingIntent.getActivity(
        context,
        0,
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    
    return RemoteViews(context.packageName, R.layout.home_widget).apply {
        val jsonString = widgetData.getString("text_from_flutter", null)

        if (jsonString != null) {
            try {
                val jsonObject = JSONObject(jsonString)
                val word = Word(
                    use = jsonObject.optString("use", ""),
                    instead = jsonObject.optString("instead", ""),
                    description = jsonObject.optString("description", "")
                )

                setTextViewText(R.id.text_instead, "${word.instead} yerine kullan")
                setTextViewText(R.id.text_use, word.use)
                setTextViewText(R.id.text_description, word.description)
            } catch (e: Exception) {
                val use = sharedPref.getString("use", "") ?: ""
                val instead = sharedPref.getString("instead", "") ?: ""
                val description = sharedPref.getString("description", "") ?: ""

                setTextViewText(R.id.text_instead, "$instead yerine kullan")
                setTextViewText(R.id.text_use, use)
                setTextViewText(R.id.text_description, description)
            }
        } else {
            val use = sharedPref.getString("use", "") ?: ""
            val instead = sharedPref.getString("instead", "") ?: ""
            val description = sharedPref.getString("description", "") ?: ""

            if (use.isNotEmpty()) {
                setTextViewText(R.id.text_instead, "$instead yerine kullan")
                setTextViewText(R.id.text_use, use)
                setTextViewText(R.id.text_description, description)
            } else {
                setTextViewText(R.id.text_instead, "Veri yok")
                setTextViewText(R.id.text_use, "Uygulamayı açarak veriyi güncelle")
                setTextViewText(R.id.text_description, "")
            }
        }
        
        setOnClickPendingIntent(R.id.text_instead, pendingIntent)
        setOnClickPendingIntent(R.id.text_use, pendingIntent)
        setOnClickPendingIntent(R.id.text_description, pendingIntent)
    }
}

private fun configureDescriptionMaxLines(
    views: RemoteViews,
    options: Bundle?
) {
    val minHeight = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) ?: 0
    val isSingleRow = getCellsForSize(minHeight) <= 1
    views.setInt(R.id.text_description, "setMaxLines", if (isSingleRow) 1 else Int.MAX_VALUE)
    views.setBoolean(R.id.text_description, "setSingleLine", isSingleRow)
}

private fun getCellsForSize(size: Int): Int = (size + 30) / 70