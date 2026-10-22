import Foundation
import UserNotifications
import UIKit

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false
    @Published var pendingCount: Int = 0
    @Published var statusMessage: String = "Pronto para agendar."

    init() {
        checkPermission()
        updatePendingCount()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    self.statusMessage = "Erro ao pedir permissão: \(error.localizedDescription)"
                } else if granted {
                    self.statusMessage = "Permissão de notificações concedida!"
                } else {
                    self.statusMessage = "Permissão negada nos Ajustes do iPhone."
                }
            }
        }
    }

    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }

    func updatePendingCount() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.pendingCount = requests.count
            }
        }
    }

    /// Agenda as notificações com imagem, repetições e sem indicador de 1/10
    func scheduleNotifications(
        title: String,
        body: String,
        image: UIImage?,
        repeatCount: Int,
        intervalSeconds: Double
    ) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Notificação" : title
        let cleanBody = body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Lembrete programado." : body

        // Prepara o anexo de imagem caso o usuário tenha selecionado uma foto
        var attachment: UNNotificationAttachment? = nil
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.85) {
            let tempDir = FileManager.default.temporaryDirectory
            let imageURL = tempDir.appendingPathComponent("custom_notif_\(UUID().uuidString).jpg")
            do {
                try imageData.write(to: imageURL)
                attachment = try UNNotificationAttachment(
                    identifier: "custom_image_attachment",
                    url: imageURL,
                    options: nil
                )
            } catch {
                print("Erro ao anexar imagem: \(error.localizedDescription)")
            }
        }

        let safeCount = min(max(1, repeatCount), 60)
        let safeInterval = max(1.0, intervalSeconds)

        for i in 1...safeCount {
            let content = UNMutableNotificationContent()
            content.title = cleanTitle // Título limpo sem 1/10 ou contadores
            content.body = cleanBody
            content.sound = .default

            if let attachment = attachment {
                content.attachments = [attachment]
            }

            let triggerDelay = safeInterval * Double(i)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerDelay, repeats: false)
            let request = UNNotificationRequest(
                identifier: "custom_notif_\(UUID().uuidString)_\(i)",
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.statusMessage = "Erro ao agendar: \(error.localizedDescription)"
                    }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let hasImageText = image != nil ? " (com foto)" : ""
            self.statusMessage = "✅ Agendado: \(safeCount) disparos\(hasImageText) a cada \(Int(safeInterval))s!"
            self.updatePendingCount()
        }
    }

    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        DispatchQueue.main.async {
            self.pendingCount = 0
            self.statusMessage = "Todos os disparos foram cancelados."
        }
    }
}
