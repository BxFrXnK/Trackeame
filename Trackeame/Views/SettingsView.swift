//
//  SettingsView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 9
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    @State private var showingAddHabit = false
    @State private var habitToEdit: Habit? = nil
    @State private var showingDeleteAlert = false
    @State private var habitToDelete: Habit? = nil

    private var reminderTime: Date {
        Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date()) ?? Date()
    }

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                notificationsSection
                habitsSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Opciones")
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .sheet(item: $habitToEdit) { habit in
                EditHabitView(habit: habit)
            }
            .alert("Eliminar hábito", isPresented: $showingDeleteAlert, presenting: habitToDelete) { habit in
                Button("Eliminar", role: .destructive) { delete(habit) }
                Button("Cancelar", role: .cancel) {}
            } message: { habit in
                Text("¿Seguro que quieres eliminar \"\(habit.name)\"? Se perderá todo su historial.")
            }
        }
    }

    // MARK: — Secciones

    private var appearanceSection: some View {
        Section("Apariencia") {
            Picker("Tema", selection: $appTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Label(theme.label, systemImage: theme.icon).tag(theme)
                }
            }
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $reminderEnabled) {
                Label("Recordatorio diario", systemImage: "bell.fill")
            }
            .onChange(of: reminderEnabled) { _, enabled in
                enabled ? scheduleReminder() : cancelReminder()
            }

            if reminderEnabled {
                DatePicker(
                    "Hora",
                    selection: Binding(
                        get: { reminderTime },
                        set: { date in
                            reminderHour = Calendar.current.component(.hour, from: date)
                            reminderMinute = Calendar.current.component(.minute, from: date)
                            scheduleReminder()
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
            }
        } header: {
            Text("Notificaciones")
        } footer: {
            Text("Recibirás un recordatorio diario para revisar tus hábitos.")
        }
    }

    private var habitsSection: some View {
        Section("Gestionar hábitos") {
            Button {
                showingAddHabit = true
            } label: {
                Label("Añadir hábito", systemImage: "plus.circle.fill")
                    .foregroundStyle(.green)
            }

            ForEach(habits) { habit in
                HStack {
                    Circle()
                        .fill(Color(hex: habit.colorHex))
                        .frame(width: 10, height: 10)
                    Text(habit.name)
                    Spacer()
                    Button {
                        habitToEdit = habit
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onDelete { offsets in
                offsets.forEach { i in
                    habitToDelete = habits[i]
                    showingDeleteAlert = true
                }
            }
        }
    }

    private var aboutSection: some View {
        Section("Acerca de") {
            LabeledContent("Versión", value: appVersion)
            LabeledContent("Hábitos activos", value: "\(habits.count)")
            LabeledContent("Total completados", value: "\(habits.reduce(0) { $0 + $1.completions.count })")
        }
    }

    // MARK: — Acciones

    private func delete(_ habit: Habit) {
        context.delete(habit)
        try? context.save()
        NotificationCenter.default.post(name: .habitListChanged, object: nil)
    }

    private func scheduleReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Trackeame"
            content.body = "¿Has completado tus hábitos de hoy?"
            content.sound = .default

            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: — Tema de la app

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "Sistema"
        case .light:  return "Claro"
        case .dark:   return "Oscuro"
        }
    }
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
