//
//  HabitDetailView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import SwiftUI

struct HabitDetailView: View {

    // MARK: — Propiedades

    let habit: Habit
    @State private var statsPeriod: StatsPeriod = .monthly
    @State private var currentMonth: Date = Calendar.current.startOfMonth(for: Date())

    private var habitColor: Color { Color(hex: habit.colorHex) }

    private var completionRate: String {
        let rate = habit.completionRate(for: statsPeriod, reference: currentMonth)
        return "\(Int(rate * 100))%"
    }

    // MARK: — Body

    var body: some View {
        List {
            statsSection
            historySection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(habit.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar { periodMenu }
    }

    // MARK: — Secciones

    private var statsSection: some View {
        Section {
            HStack(spacing: 12) {
                StatCardView(
                    value: completionRate,
                    label: statsPeriod.label,
                    color: habitColor
                )
                StatCardView(
                    value: "\(habit.completions.count)",
                    label: "Total completados",
                    color: habitColor
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    private var historySection: some View {
        Section("Historial") {
            HabitGridView(habit: habit) { month in
                currentMonth = month
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
    }

    // MARK: — Toolbar

    private var periodMenu: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                ForEach(StatsPeriod.allCases) { period in
                    Button {
                        statsPeriod = period
                    } label: {
                        Label(period.label, systemImage: period.icon)
                        if statsPeriod == period {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Image(systemName: statsPeriod.icon)
            }
        }
    }
}

// MARK: — Tarjeta de estadística

struct StatCardView: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
