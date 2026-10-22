package com.notif.customnotifier

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import java.io.File
import java.io.FileOutputStream

class MainActivity : AppCompatActivity() {

    private lateinit var etTitle: EditText
    private lateinit var etBody: EditText
    private lateinit var etCount: EditText
    private lateinit var etInterval: EditText
    private lateinit var spinnerUnit: Spinner
    private lateinit var ivPreview: ImageView
    private lateinit var btnPickImage: Button
    private lateinit var btnRemoveImage: Button
    private lateinit var btnStart: Button
    private lateinit var btnCancel: Button
    private lateinit var tvStatus: TextView

    private var selectedImagePath: String? = null

    // Lançador para escolher imagem da galeria
    private val pickImageLauncher =
        registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
            if (uri != null) {
                saveImageLocally(uri)
            }
        }

    // Lançador para pedir permissão de notificação no Android 13+ (API 33)
    private val requestNotificationPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
            if (isGranted) {
                tvStatus.text = "Permissão de notificação concedida!"
            } else {
                tvStatus.text = "Atenção: Permissão de notificação foi negada."
                Toast.makeText(this, "Permita as notificações nas configurações do Android.", Toast.LENGTH_LONG).show()
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        NotificationHelper.createNotificationChannel(this)

        initViews()
        setupSpinner()
        checkNotificationPermission()
        setupListeners()
    }

    private fun initViews() {
        etTitle = findViewById(R.id.etTitle)
        etBody = findViewById(R.id.etBody)
        etCount = findViewById(R.id.etCount)
        etInterval = findViewById(R.id.etInterval)
        spinnerUnit = findViewById(R.id.spinnerUnit)
        ivPreview = findViewById(R.id.ivPreview)
        btnPickImage = findViewById(R.id.btnPickImage)
        btnRemoveImage = findViewById(R.id.btnRemoveImage)
        btnStart = findViewById(R.id.btnStart)
        btnCancel = findViewById(R.id.btnCancel)
        tvStatus = findViewById(R.id.tvStatus)
    }

    private fun setupSpinner() {
        val units = arrayOf("Segundos", "Minutos", "Horas")
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, units)
        spinnerUnit.adapter = adapter
    }

    private fun checkNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val permission = Manifest.permission.POST_NOTIFICATIONS
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                requestNotificationPermission.launch(permission)
            }
        }
    }

    private fun saveImageLocally(uri: Uri) {
        try {
            contentResolver.openInputStream(uri)?.use { inputStream ->
                val destinationFile = File(filesDir, "notif_image.jpg")
                FileOutputStream(destinationFile).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }

                selectedImagePath = destinationFile.absolutePath

                val bitmap = BitmapFactory.decodeFile(destinationFile.absolutePath)
                ivPreview.setImageBitmap(bitmap)
                ivPreview.visibility = View.VISIBLE
                btnRemoveImage.visibility = View.VISIBLE
                tvStatus.text = "Foto selecionada com sucesso!"
            }
        } catch (e: Exception) {
            Toast.makeText(this, "Erro ao carregar foto: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun removeSelectedImage() {
        selectedImagePath = null
        ivPreview.setImageDrawable(null)
        ivPreview.visibility = View.GONE
        btnRemoveImage.visibility = View.GONE
        tvStatus.text = "Foto removida."
    }

    private fun setupListeners() {
        btnPickImage.setOnClickListener {
            pickImageLauncher.launch("image/*")
        }

        btnRemoveImage.setOnClickListener {
            removeSelectedImage()
        }

        btnStart.setOnClickListener {
            val title = etTitle.text.toString().trim().ifEmpty { "Notificação" }
            val body = etBody.text.toString().trim().ifEmpty { "Lembrete programado." }
            val count = etCount.text.toString().toIntOrNull() ?: 1
            val intervalInput = etInterval.text.toString().toLongOrNull() ?: 5L

            val multiplier = when (spinnerUnit.selectedItemPosition) {
                1 -> 60L    // Minutos
                2 -> 3600L  // Horas
                else -> 1L  // Segundos
            }

            val totalIntervalSec = (intervalInput * multiplier).coerceAtLeast(1L)
            val safeCount = count.coerceIn(1, 100)

            // Cancela agendamentos anteriores antes de iniciar novo ciclo
            NotificationHelper.cancelAlarms(this)

            // Agenda o primeiro disparo (step 1) passando a foto se houver
            NotificationHelper.scheduleNextAlarm(
                context = this,
                title = title,
                body = body,
                imagePath = selectedImagePath,
                totalCount = safeCount,
                currentStep = 1,
                intervalSeconds = totalIntervalSec
            )

            btnCancel.visibility = View.VISIBLE
            val hasImageNotice = if (selectedImagePath != null) " (com foto)" else ""
            tvStatus.text = "✅ Agendado: $safeCount disparos$hasImageNotice a cada $totalIntervalSec segundo(s)!"
            Toast.makeText(this, "Disparos iniciados!", Toast.LENGTH_SHORT).show()
        }

        btnCancel.setOnClickListener {
            NotificationHelper.cancelAlarms(this)
            btnCancel.visibility = View.GONE
            tvStatus.text = "Disparos cancelados com sucesso."
            Toast.makeText(this, "Cancelado!", Toast.LENGTH_SHORT).show()
        }
    }
}
