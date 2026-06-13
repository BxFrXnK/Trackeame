//
//  ContentView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    // MARK: — Propiedades

    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @State private var showingAddHabit = false

    // MARK: — Body

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    emptyState
                } else {
                    habitList
                }
            }
            .navigationTitle("Mis hábitos")
            .toolbar { addButton }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
    }

    // MARK: — Subvistas

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.gray.opacity(0.4))

            Text("Sin hábitos todavía")
                .font(.title3.bold())

            Text("Pulsa el + para añadir tu primer hábito.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddHabit = true
            } label: {
                Label("Añadir hábito", systemImage: "plus")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(40)
    }

    private var habitList: some View {
        List {
            ForEach(habits) { habit in
                NavigationLink(destination: HabitDetailView(habit: habit)) {
                    HabitRowView(habit: habit)
                }
            }
            .onDelete(perform: deleteHabits)
        }
    }

    private var addButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingAddHabit = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    // MARK: — Acciones

    private func deleteHabits(at offsets: IndexSet) {
        offsets.forEach { context.delete(habits[$0]) }
        NotificationCenter.default.post(name: .habitListChanged, object: nil)
    }
}
