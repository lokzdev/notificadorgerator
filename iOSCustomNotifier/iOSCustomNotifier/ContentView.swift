import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var manager = NotificationManager.shared

    // Configurações da Notificação
    @State private var notificationTitle: String = "Lembrete Importante"
    @State private var notificationBody: String = "Hora de checar suas metas!"
    @State private var repeatCount: Int = 3
    @State private var intervalValue: Double = 5
    @State private var timeUnit: TimeUnit = .seconds

    // Foto da Notificação
    @State private var selectedPickerItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    enum TimeUnit: String, CaseIterable, Identifiable {
        case seconds = "Segundos"
        case minutes = "Minutos"
        case hours = "Horas"

        var id: String { self.rawValue }

        var multiplier: Double {
            switch self {
            case .seconds: return 1.0
            case .minutes: return 60.0
            case .hours: return 3600.0
            }
        }
    }

    var totalIntervalInSeconds: Double {
        return intervalValue * timeUnit.multiplier
    }

    var body: some View {
        NavigationView {
            Form {
                // Seção: Conteúdo da Notificação
                Section(header: Text("CONTEÚDO")) {
                    TextField("Nome / Título da Notificação", text: $notificationTitle)

                    ZStack(alignment: .topLeading) {
                        if notificationBody.isEmpty {
                            Text("Mensagem da notificação...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 8)
                        }
                        TextEditor(text: $notificationBody)
                            .frame(minHeight: 70)
                    }
                }

                // Seção: Foto da Notificação
                Section(header: Text("FOTO DA NOTIFICAÇÃO (OPCIONAL)")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .cornerRadius(12)
                            .clipped()

                        Button(role: .destructive, action: {
                            selectedImage = nil
                            selectedPickerItem = nil
                        }) {
                            HStack {
                                Spacer()
                                Label("Remover Foto", systemImage: "trash")
                                Spacer()
                            }
                        }
                    }

                    PhotosPicker(
                        selection: $selectedPickerItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Spacer()
                            Label(selectedImage == nil ? "Escolher Foto da Galeria" : "Trocar Foto",
                                  systemImage: "photo.on.rectangle.angled")
                                .font(.body.weight(.medium))
                            Spacer()
                        }
                    }
                    .onChange(of: selectedPickerItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                await MainActor.run {
                                    self.selectedImage = uiImage
                                }
                            }
                        }
                    }
                }

                // Seção: Frequência e Intervalo
                Section(header: Text("FREQUÊNCIA E TEMPO")) {
                    Stepper(value: $repeatCount, in: 1...60) {
                        HStack {
                            Text("Repetições:")
                            Spacer()
                            Text("\(repeatCount)x")
                                .bold()
                                .foregroundColor(.blue)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Intervalo entre disparos:")
                            Spacer()
                            Text("\(Int(intervalValue)) \(timeUnit.rawValue.lowercased())")
                                .bold()
                                .foregroundColor(.blue)
                        }

                        Slider(value: $intervalValue, in: 1...60, step: 1)

                        Picker("Unidade de Tempo", selection: $timeUnit) {
                            ForEach(TimeUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }

                // Seção: Ações
                Section {
                    Button(action: {
                        if !manager.isAuthorized {
                            manager.requestPermission()
                        }
                        manager.scheduleNotifications(
                            title: notificationTitle,
                            body: notificationBody,
                            image: selectedImage,
                            repeatCount: repeatCount,
                            intervalSeconds: totalIntervalInSeconds
                        )
                    }) {
                        HStack {
                            Spacer()
                            Label("Iniciar Disparos", systemImage: "bell.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .tint(.blue)

                    if manager.pendingCount > 0 {
                        Button(role: .destructive, action: {
                            manager.cancelAllNotifications()
                        }) {
                            HStack {
                                Spacer()
                                Label("Cancelar Disparos Agendados", systemImage: "xmark.circle")
                                Spacer()
                            }
                        }
                    }
                }

                // Status
                Section {
                    HStack {
                        Spacer()
                        Text(manager.statusMessage)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Notificador Custom")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        manager.updatePendingCount()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
