//
//  HabitRowView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import SwiftUI
import SwiftData

struct HabitRowView: View {

    // MARK: — Propiedades

    @Environment(\.modelContext) private var context
    let habit: Habit

    private var isCompleted: Bool { habit.isCompleted(on: .now) }
    private var habitColor: Color { Color(hex: habit.colorHex) }

    // MARK: — Body

    var body: some View {
        HStack(spacing: 12) {
            colorIndicator
            habitInfo
            Spacer()
            toggleButton
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    // MARK: — Subvistas

    private var colorIndicator: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(habitColor)
            .frame(width: 4, height: 36)
    }

    private var habitInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(habit.name)
                .font(.body.weight(isCompleted ? .regular : .medium))
                .foregroundStyle(isCompleted ? .secondary : .primary)

            Text(isCompleted ? "Completado hoy" : "Pendiente")
                .font(.caption)
                .foregroundStyle(isCompleted ? habitColor : .secondary)
        }
    }

    private var toggleButton: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                habit.toggle()
                try? context.save()
                NotificationCenter.default.post(name: .habitChanged, object: nil)
            }
        } label: {
            ZStack {
                Circle()
                    .fill(isCompleted ? habitColor : .clear)
                    .frame(width: 32, height: 32)

                Circle()
                    .strokeBorder(isCompleted ? .clear : Color.gray.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 32, height: 32)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: — Acciones

    private func toggle() {
        withAnimation(.spring(duration: 0.3)) {
            habit.toggle()
            try? context.save()
            NotificationCenter.default.post(name: .habitChanged, object: nil)
        }
    }
}
