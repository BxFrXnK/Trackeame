//
//  AddHabitView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import SwiftUI
import SwiftData

struct AddHabitView: View {

    // MARK: — Propiedades

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedColor: Color = .habitDefault
    @FocusState private var nameFocused: Bool

    private var isValidName: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: — Body

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                colorSection
            }
            .navigationTitle("Nuevo hábito")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Guardar") { saveHabit() }
                        .bold()
                        .disabled(!isValidName)
                }
            }
            .onAppear { nameFocused = true }
        }
    }

    // MARK: — Secciones

    private var nameSection: some View {
        Section {
            TextField("Nombre del hábito", text: $name)
                .focused($nameFocused)
        } header: {
            Text("Nombre")
        } footer: {
            Text("Por ejemplo: Leer, Meditar, Gimnasio…")
        }
    }

    private var colorSection: some View {
        Section("Color") {
            ColorPickerGrid(selectedColor: $selectedColor)
                .padding(.vertical, 8)
        }
    }

    // MARK: — Acciones

    private func saveHabit() {
        let habit = Habit(
            name: name.trimmingCharacters(in: .whitespaces),
            colorHex: selectedColor.toHex()
        )
        context.insert(habit)
        try? context.save()
        NotificationCenter.default.post(name: .habitListChanged, object: nil)
        dismiss()
    }
}

// MARK: — Selector de color

struct ColorPickerGrid: View {
    @Binding var selectedColor: Color

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
            ForEach(Color.habitColors, id: \.self) { color in
                colorCircle(for: color)
            }
        }
    }

    private func colorCircle(for color: Color) -> some View {
        let isSelected = selectedColor == color
        return Circle()
            .fill(color)
            .frame(width: 32, height: 32)
            .overlay {
                if isSelected {
                    Circle()
                        .strokeBorder(.white, lineWidth: 2)
                        .padding(3)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .onTapGesture {
                withAnimation { selectedColor = color }
            }
    }
}
