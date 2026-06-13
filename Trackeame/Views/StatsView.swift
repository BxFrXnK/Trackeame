//
//  StatsView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {

    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @State private var selectedPeriod: StatsPeriod = .monthly
    @State private var referenceDate: Date = Calendar.current.startOfMonth(for: Date())

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    periodSelectorView
                    globalChartsView
                    perHabitView
                }
                .padding()
            }
            .navigationTitle("Estadísticas")
        }
    }

    // MARK: — Selector de periodo

    private var periodSelectorView: some View {
        Picker("Periodo", selection: $selectedPeriod) {
            ForEach(StatsPeriod.allCases) { period in
                Label(period.label, systemImage: period.icon).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: — Gráficas globales

    private var globalChartsView: some View {
        VStack(spacing: 12) {
            Text("Resumen global")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                StatCardView(
                    value: "\(Int(overallRate * 100))%",
                    label: "Cumplimiento",
                    color: rateColor(overallRate)
                )
                StatCardView(
                    value: "\(totalCompletions)",
                    label: "Total completados",
                    color: .blue
                )
            }

            GlobalRingChart(rate: overallRate)

            WeekdayBarChart(habits: habits)
        }
    }

    // MARK: — Por hábito

    private var perHabitView: some View {
        VStack(spacing: 12) {
            Text("Por hábito")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(habits) { habit in
                VStack(alignment: .leading, spacing: 12) {
                    HabitStatRow(
                        habit: habit,
                        period: selectedPeriod,
                        reference: referenceDate
                    )
                    HabitProgressLineChart(habit: habit)
                }
                .padding(16)
                .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    // MARK: — Cálculos

    private var overallRate: Double {
        guard !habits.isEmpty else { return 0 }
        let rates = habits.map { $0.completionRate(for: selectedPeriod, reference: referenceDate) }
        return rates.reduce(0, +) / Double(rates.count)
    }

    private var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.completions.count }
    }

    private func rateColor(_ rate: Double) -> Color {
        switch rate {
        case 0..<0.4:  return .red
        case 0.4..<0.7: return .orange
        default:        return .green
        }
    }
}

// MARK: — Gráfica circular global

struct GlobalRingChart: View {
    let rate: Double

    private var rateColor: Color {
        switch rate {
        case 0..<0.4:  return .red
        case 0.4..<0.7: return .orange
        default:        return .green
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Cumplimiento global")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 20)
                Circle()
                    .trim(from: 0, to: rate)
                    .stroke(rateColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.8), value: rate)

                VStack(spacing: 2) {
                    Text("\(Int(rate * 100))%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(rateColor)
                    Text("completado")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 180)
            .padding(.vertical, 12)
            .padding(.horizontal, 40)
        }
        .padding(16)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: — Barras por día de la semana

struct WeekdayBarChart: View {
    let habits: [Habit]

    private let weekdays = ["L", "M", "X", "J", "V", "S", "D"]

    private var data: [(day: String, rate: Double)] {
        let calendar = Calendar.current
        let today = Date()

        return weekdays.enumerated().map { index, label in
            let completionsOnDay = habits.reduce(0) { count, habit in
                let matchingDays = habit.completions.filter {
                    let weekday = (calendar.component(.weekday, from: $0) + 5) % 7
                    return weekday == index
                }.count
                return count + matchingDays
            }
            let totalDaysOfType = habits.reduce(0) { count, habit in
                let daysSinceCreation = calendar.dateComponents([.day], from: habit.createdAt, to: today).day ?? 0
                return count + max(1, (daysSinceCreation / 7) + 1)
            }
            let rate = totalDaysOfType > 0 ? Double(completionsOnDay) / Double(totalDaysOfType) : 0
            return (day: label, rate: min(rate, 1.0))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Por día de la semana")
                .font(.caption)
                .foregroundStyle(.secondary)

            Chart(data, id: \.day) { item in
                BarMark(
                    x: .value("Día", item.day),
                    y: .value("Cumplimiento", item.rate)
                )
                .foregroundStyle(
                    item.rate >= 0.7 ? Color.green :
                    item.rate >= 0.4 ? Color.orange : Color.red
                )
                .cornerRadius(6)
            }
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(values: [0, 0.5, 1.0]) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v * 100))%")
                                .font(.caption2)
                        }
                    }
                    AxisGridLine()
                }
            }
            .frame(height: 160)
        }
        .padding(16)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: — Línea de progreso por hábito

struct HabitProgressLineChart: View {
    let habit: Habit

    private var data: [(date: Date, completed: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<30).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -29 + offset, to: today) else { return nil }
            return (date: date, completed: habit.isCompleted(on: date) ? 1.0 : 0.0)
        }
    }

    private var habitColor: Color { Color(hex: habit.colorHex) }

    var body: some View {
        Chart(data, id: \.date) { item in
            LineMark(
                x: .value("Fecha", item.date),
                y: .value("Completado", item.completed)
            )
            .foregroundStyle(habitColor)
            .interpolationMethod(.stepEnd)

            AreaMark(
                x: .value("Fecha", item.date),
                y: .value("Completado", item.completed)
            )
            .foregroundStyle(habitColor.opacity(0.1))
            .interpolationMethod(.stepEnd)
        }
        .chartYScale(domain: 0...1)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 10)) { _ in
                AxisValueLabel(format: .dateTime.day().month())
                    .font(.caption2)
            }
        }
        .frame(height: 60)
    }
}

// MARK: — Fila de estadística por hábito

struct HabitStatRow: View {
    let habit: Habit
    let period: StatsPeriod
    let reference: Date

    private var habitColor: Color { Color(hex: habit.colorHex) }
    private var rate: Double { habit.completionRate(for: period, reference: reference) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(habitColor)
                    .frame(width: 10, height: 10)
                Text(habit.name)
                    .font(.body.bold())
                Spacer()
                Text("\(Int(rate * 100))%")
                    .font(.body.bold())
                    .foregroundStyle(rateColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(habitColor)
                        .frame(width: geo.size.width * rate, height: 6)
                        .animation(.spring(duration: 0.5), value: rate)
                }
            }
            .frame(height: 6)

            HStack(spacing: 16) {
                Label("\(habit.currentStreak) días seguidos", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(habit.currentStreak > 0 ? .orange : .secondary)
                Label("Mejor: \(habit.bestStreak)", systemImage: "trophy.fill")
                    .font(.caption)
                    .foregroundStyle(habit.bestStreak > 0 ? .yellow : .secondary)
            }
        }
    }

    private var rateColor: Color {
        switch rate {
        case 0..<0.4:  return .red
        case 0.4..<0.7: return .orange
        default:        return .green
        }
    }
}
