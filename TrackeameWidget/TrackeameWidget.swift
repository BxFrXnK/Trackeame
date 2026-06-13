//
//  TrackeameWidget.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: — Modelo simplificado para el widget

struct HabitEntry: TimelineEntry {
    let date: Date
    let habits: [HabitSnapshot]
}

struct HabitSnapshot: Identifiable {
    let id: UUID
    let name: String
    let colorHex: String
    let weekDays: [Bool] // 7 valores, lunes a domingo
}

// MARK: — Provider

struct TrackeameProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habits: placeholderHabits)
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) {
        completion(HabitEntry(date: Date(), habits: loadHabits()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let entry = HabitEntry(date: Date(), habits: loadHabits())
        // Actualiza cada hora
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    // Carga los hábitos desde SwiftData
    private func loadHabits() -> [HabitSnapshot] {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: Habit.self, configurations: config)
            let context = ModelContext(container)
            let habits = try context.fetch(FetchDescriptor<Habit>())
            print("🔵 Widget cargó \(habits.count) hábitos")
            return habits.map { habit in
                HabitSnapshot(
                    id: habit.id,
                    name: habit.name,
                    colorHex: habit.colorHex,
                    weekDays: weekStatus(for: habit)
                )
            }
        } catch {
            print("🔴 Error widget: \(error)")
            return []
        }
    }

    // Devuelve los 7 días de la semana actual (lunes a domingo)
    private func weekStatus(for habit: Habit) -> [Bool] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: monday)!
            return habit.isCompleted(on: day)
        }
    }

    private var placeholderHabits: [HabitSnapshot] {
        [
            HabitSnapshot(id: UUID(), name: "Leer", colorHex: "#34C759",
                          weekDays: [true, true, false, true, true, false, false]),
            HabitSnapshot(id: UUID(), name: "Gimnasio", colorHex: "#007AFF",
                          weekDays: [true, false, true, false, true, false, false]),
            HabitSnapshot(id: UUID(), name: "Meditar", colorHex: "#FF9500",
                          weekDays: [true, true, true, true, false, false, false])
        ]
    }
}

// MARK: — Vista del widget

struct TrackeameWidgetEntryView: View {
    var entry: HabitEntry
    @Environment(\.widgetFamily) var family

    private let dayLabels = ["L", "M", "X", "J", "V", "S", "D"]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Cabecera con días
            HStack(spacing: 0) {
                Text("")
                    .frame(maxWidth: family == .systemSmall ? 60 : 80, alignment: .leading)
                ForEach(0..<7, id: \.self) { i in
                    Text(dayLabels[i])
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Filas de hábitos
            ForEach(visibleHabits) { habit in
                HabitWidgetRow(habit: habit, compact: family == .systemSmall)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
    }

    // Pequeño muestra 3 hábitos, mediano muestra 5
    private var visibleHabits: [HabitSnapshot] {
        let limit = family == .systemSmall ? 3 : 5
        return Array(entry.habits.prefix(limit))
    }
}

struct HabitWidgetRow: View {
    let habit: HabitSnapshot
    let compact: Bool

    private let today = Calendar.current.component(.weekday, from: Date())
    private var todayIndex: Int { (today + 5) % 7 }

    var body: some View {
        HStack(spacing: 0) {
            // Nombre del hábito
            Text(habit.name)
                .font(.system(size: compact ? 10 : 11, weight: .medium))
                .lineLimit(1)
                .frame(maxWidth: compact ? 60 : 80, alignment: .leading)

            // Celdas de la semana
            ForEach(0..<7, id: \.self) { i in
                let completed = habit.weekDays[i]
                let isToday = i == todayIndex
                let isFuture = i > todayIndex

                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(cellColor(completed: completed, isFuture: isFuture, colorHex: habit.colorHex))
                        .frame(height: compact ? 18 : 20)

                    if isToday && !completed {
                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(Color(hex: habit.colorHex), lineWidth: 1.5)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 1.5)
            }
        }
    }

    private func cellColor(completed: Bool, isFuture: Bool, colorHex: String) -> Color {
        if isFuture { return Color.gray.opacity(0.08) }
        if completed { return Color(hex: colorHex) }
        return Color.gray.opacity(0.15)
    }
}

// MARK: — Configuración del widget

struct TrackeameWidget: Widget {
    let kind: String = "TrackeameWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrackeameProvider()) { entry in
            TrackeameWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Trackeame")
        .description("Seguimiento semanal de tus hábitos.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: — Preview

#Preview(as: .systemMedium) {
    TrackeameWidget()
} timeline: {
    HabitEntry(date: Date(), habits: [
        HabitSnapshot(id: UUID(), name: "Leer", colorHex: "#34C759",
                      weekDays: [true, true, false, true, true, false, false]),
        HabitSnapshot(id: UUID(), name: "Gimnasio", colorHex: "#007AFF",
                      weekDays: [true, false, true, false, true, false, false]),
        HabitSnapshot(id: UUID(), name: "Meditar", colorHex: "#FF9500",
                      weekDays: [true, true, true, true, false, false, false])
    ])
}
