//
//  HabitGridView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import SwiftUI
import SwiftData

// MARK: — Navegador de mes

struct HabitGridView: View {

    @Environment(\.modelContext) private var context
    let habit: Habit
    var onMonthChanged: ((Date) -> Void)? = nil

    @State private var selectedMonth: Date = Calendar.current.startOfMonth(for: Date())

    private var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            monthNavigator
            MonthGridView(habit: habit, month: selectedMonth)
        }
    }

    private var monthNavigator: some View {
        HStack {
            navigationButton(direction: .backward)
            Spacer()
            Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            Spacer()
            navigationButton(direction: .forward)
        }
    }

    private func navigationButton(direction: NavigationDirection) -> some View {
        let isDisabled = direction == .forward && isCurrentMonth
        return Button {
            withAnimation(.spring(duration: 0.3)) {
                let value = direction == .forward ? 1 : -1
                selectedMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth)!
                onMonthChanged?(selectedMonth)
            }
        } label: {
            Image(systemName: direction == .forward ? "chevron.right" : "chevron.left")
                .font(.body.bold())
                .foregroundStyle(isDisabled ? Color.secondary.opacity(0.3) : Color.primary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private enum NavigationDirection { case forward, backward }
}

// MARK: — Cuadrícula mensual

struct MonthGridView: View {

    @Environment(\.modelContext) private var context
    let habit: Habit
    let month: Date

    @State private var availableWidth: CGFloat = 300

    private let spacing: CGFloat = 6
    private let weekdayLabels = ["L", "M", "X", "J", "V", "S", "D"]

    private var cellSize: CGFloat {
        (availableWidth - spacing * 6) / 7
    }

    private var weeks: [[Date?]] {
        let calendar = Calendar.current
        let start = calendar.startOfMonth(for: month)
        let range = calendar.range(of: .day, in: .month, for: month)!

        var firstWeekday = calendar.component(.weekday, from: start) - 2
        if firstWeekday < 0 { firstWeekday += 7 }

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: start))
        }
        while days.count % 7 != 0 { days.append(nil) }

        return stride(from: 0, to: days.count, by: 7).map {
            Array(days[$0..<$0 + 7])
        }
    }

    private var totalHeight: CGFloat {
        let labelHeight: CGFloat = 20
        let rows = CGFloat(weeks.count)
        return labelHeight + spacing + (rows * cellSize) + (rows - 1) * spacing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            // Etiquetas días
            HStack(spacing: spacing) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                        .frame(width: cellSize, alignment: .center)
                }
            }

            // Semanas
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: spacing) {
                    ForEach(0..<7, id: \.self) { i in
                        if let day = week[i] {
                            DayCellView(habit: habit, day: day, cellSize: cellSize)
                        } else {
                            Color.clear.frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        // Medir el ancho real disponible sin GeometryReader
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    availableWidth = geo.size.width
                }
                .onChange(of: geo.size.width) { _, newWidth in
                    availableWidth = newWidth
                }
            }
        )
    }
}

// MARK: — Celda de día

struct DayCellView: View {

    @Environment(\.modelContext) private var context
    let habit: Habit
    let day: Date
    let cellSize: CGFloat

    private var habitColor: Color { Color(hex: habit.colorHex) }
    private var completed: Bool { habit.isCompleted(on: day) }
    private var isToday: Bool { Calendar.current.isDateInToday(day) }
    private var isFuture: Bool { Calendar.current.isFuture(day) }
    private var dayNumber: Int { Calendar.current.component(.day, from: day) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)

            if isToday {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(habitColor, lineWidth: 2)
            }

            Text("\(dayNumber)")
                .font(.system(size: 14, weight: completed ? .bold : .regular))
                .foregroundStyle(textColor)
        }
        .frame(width: cellSize, height: cellSize)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isFuture else { return }
            withAnimation(.spring(duration: 0.2)) {
                habit.toggle(on: day)
                try? context.save()
                NotificationCenter.default.post(name: .habitChanged, object: nil)
            }
        }
    }

    private var backgroundColor: Color {
        if isFuture  { return Color.gray.opacity(0.06) }
        if completed { return habitColor }
        return Color.gray.opacity(0.12)
    }

    private var textColor: Color {
        if completed { return .white }
        if isFuture  { return Color.secondary.opacity(0.4) }
        return .secondary
    }
}
