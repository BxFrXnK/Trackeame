//
//  HomeView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    private var completedToday: Int {
        habits.filter { $0.isCompleted(on: .now) }.count
    }

    private var totalHabits: Int { habits.count }

    private var progress: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(completedToday) / Double(totalHabits)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:  return "Buenos días"
        case 12..<18: return "Buenas tardes"
        default:      return "Buenas noches"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    summaryCard
                    habitsList
                }
                .padding()
            }
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: — Tarjeta resumen

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(completedToday) de \(totalHabits)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("hábitos completados hoy")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // Círculo de progreso
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progressColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 0.6), value: progress)
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .frame(width: 64, height: 64)
            }

            // Barra de progreso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.spring(duration: 0.6), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private var progressColor: Color {
        switch progress {
        case 0..<0.4:  return .red
        case 0.4..<0.7: return .orange
        default:        return .green
        }
    }

    // MARK: — Lista de hábitos

    private var habitsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hoy")
                .font(.headline)

            if habits.isEmpty {
                Text("No tienes hábitos todavía.\nVe a la pestaña Hábitos para añadir uno.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            } else {
                ForEach(habits) { habit in
                    HomeHabitRow(habit: habit)
                }
            }
        }
    }
}

// MARK: — Fila de hábito en Home

struct HomeHabitRow: View {
    @Environment(\.modelContext) private var context
    let habit: Habit

    private var isCompleted: Bool { habit.isCompleted(on: .now) }
    private var habitColor: Color { Color(hex: habit.colorHex) }

    var body: some View {
        HStack(spacing: 12) {
            // Icono
            ZStack {
                Circle()
                    .fill(isCompleted ? habitColor : habitColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: isCompleted ? "checkmark" : "circle")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isCompleted ? .white : habitColor)
            }

            Text(habit.name)
                .font(.body.weight(isCompleted ? .regular : .medium))
                .foregroundStyle(isCompleted ? .secondary : .primary)
                .strikethrough(isCompleted, color: .secondary)

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    habit.toggle()
                    try? context.save()
                }
            } label: {
                Text(isCompleted ? "Deshacer" : "Marcar")
                    .font(.caption.bold())
                    .foregroundStyle(isCompleted ? .secondary : habitColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        isCompleted ? Color.secondary.opacity(0.1) : habitColor.opacity(0.15),
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}
