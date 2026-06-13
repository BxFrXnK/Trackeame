//
//  StatsView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import SwiftUI
import SwiftData

struct StatsView: View {

    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @State private var selectedPeriod: StatsPeriod = .monthly
    @State private var referenceDate: Date = Calendar.current.startOfMonth(for: Date())

    var body: some View {
        NavigationStack {
            List {
                periodSelector
                overallSection
                habitsSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Estadísticas")
        }
    }

    // MARK: — Selector de periodo

    private var periodSelector: some View {
        Section {
            Picker("Periodo", selection: $selectedPeriod) {
                ForEach(StatsPeriod.allCases) { period in
                    Label(period.label, systemImage: period.icon)
                        .tag(period)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .padding(.vertical, 4)
        }
    }

    // MARK: — Resumen global

    private var overallSection: some View {
        Section("Resumen") {
            HStack(spacing: 12) {
                StatCardView(
                    value: "\(Int(overallRate * 100))%",
                    label: "Cumplimiento global",
                    color: rateColor(overallRate)
                )
                StatCardView(
                    value: "\(totalCompletions)",
                    label: "Total completados",
                    color: .blue
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    // MARK: — Por hábito

    private var habitsSection: some View {
        Section("Por hábito") {
            ForEach(habits) { habit in
                HabitStatRow(
                    habit: habit,
                    period: selectedPeriod,
                    reference: referenceDate
                )
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

// MARK: — Fila de estadística por hábito

struct HabitStatRow: View {
    let habit: Habit
    let period: StatsPeriod
    let reference: Date

    private var habitColor: Color { Color(hex: habit.colorHex) }
    private var rate: Double { habit.completionRate(for: period, reference: reference) }
    private var currentStreak: Int { habit.currentStreak }
    private var bestStreak: Int { habit.bestStreak }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Cabecera
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

            // Barra de progreso
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

            // Rachas
            HStack(spacing: 16) {
                Label("\(currentStreak) días seguidos", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(currentStreak > 0 ? .orange : .secondary)
                Label("Mejor: \(bestStreak)", systemImage: "trophy.fill")
                    .font(.caption)
                    .foregroundStyle(bestStreak > 0 ? .yellow : .secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var rateColor: Color {
        switch rate {
        case 0..<0.4:  return .red
        case 0.4..<0.7: return .orange
        default:        return .green
        }
    }
}
