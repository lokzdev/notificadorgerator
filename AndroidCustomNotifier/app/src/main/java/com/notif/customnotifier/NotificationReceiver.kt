package com.notif.customnotifier

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.core.app.NotificationCompat
import java.io.File

class NotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("EXTRA_TITLE") ?: "Notificação"
        val body = intent.getStringExtra("EXTRA_BODY") ?: "Conteúdo"
        val imagePath = intent.getStringExtra("EXTRA_IMAGE_PATH")
        val totalCount = intent.getIntExtra("EXTRA_TOTAL_COUNT", 1)
        val currentStep = intent.getIntExtra("EXTRA_CURRENT_STEP", 1)
        val intervalSec = intent.getLongExtra("EXTRA_INTERVAL_SEC", 5L)

        // Intent para abrir o app caso o usuário clique na notificação
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Carrega a foto personalizada caso exista
        var bitmap: Bitmap? = null
        if (!imagePath.isNullOrEmpty()) {
            val file = File(imagePath)
            if (file.exists()) {
                bitmap = BitmapFactory.decodeFile(file.absolutePath)
            }
        }

        val builder = NotificationCompat.Builder(context, NotificationHelper.CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setContentIntent(contentPendingIntent)
            .setAutoCancel(true)

        if (bitmap != null) {
            // Estilo com foto expansível e ícone lateral
            builder.setLargeIcon(bitmap)
            builder.setStyle(
                NotificationCompat.BigPictureStyle()
                    .bigPicture(bitmap)
                    .setSummaryText(body)
            )
        } else {
            // Estilo padrão de texto longo
            builder.setStyle(NotificationCompat.BigTextStyle().bigText(body))
        }

        // Cada disparo exibe uma notificação única
        notificationManager.notify(currentStep, builder.build())

        // Se ainda restam disparos, encadeia o próximo alarme com precisão mantendo a foto
        if (currentStep < totalCount) {
            NotificationHelper.scheduleNextAlarm(
                context = context,
                title = title,
                body = body,
                imagePath = imagePath,
                totalCount = totalCount,
                currentStep = currentStep + 1,
                intervalSeconds = intervalSec
            )
        }
    }
}
