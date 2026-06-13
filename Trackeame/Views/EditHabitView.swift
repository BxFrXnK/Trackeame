//
//  EditHabitView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import SwiftUI
import SwiftData

struct EditHabitView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let habit: Habit

    @State private var name: String
    @State private var selectedColor: Color
    @FocusState private var nameFocused: Bool

    init(habit: Habit) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _selectedColor = State(initialValue: Color(hex: habit.colorHex))
    }

    private var isValidName: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre del hábito", text: $name)
                        .focused($nameFocused)
                } header: {
                    Text("Nombre")
                }

                Section("Color") {
                    ColorPickerGrid(selectedColor: $selectedColor)
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("Editar hábito")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Guardar") { saveChanges() }
                        .bold()
                        .disabled(!isValidName)
                }
            }
            .onAppear { nameFocused = true }
        }
    }

    private func saveChanges() {
        habit.name = name.trimmingCharacters(in: .whitespaces)
        habit.colorHex = selectedColor.toHex()
        try? context.save()
        NotificationCenter.default.post(name: .habitListChanged, object: nil)
        dismiss()
    }
}
