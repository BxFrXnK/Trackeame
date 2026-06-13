//
//  Habit.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import Foundation
import SwiftData

@Model
class Habit {

    // MARK: — Propiedades

    var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date
    var completions: [Date]

    // MARK: — Inicializador

    init(name: String, colorHex: String = "#34C759") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
        self.completions = []
    }

    // MARK: — Consultas

    /// Devuelve true si el hábito está completado en la fecha indicada
    func isCompleted(on date: Date) -> Bool {
        completions.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }

    /// Porcentaje de cumplimiento para el periodo y referencia indicados
    func completionRate(for period: StatsPeriod, reference: Date) -> Double {
        let days = relevantDays(for: period, reference: reference)
        guard !days.isEmpty else { return 0 }
        let completed = days.filter { isCompleted(on: $0) }.count
        return Double(completed) / Double(days.count)
    }

    // MARK: — Acciones

    /// Marca o desmarca el hábito para la fecha indicada
    func toggle(on date: Date = Date()) {
        let calendar = Calendar.current
        if let index = completions.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            completions.remove(at: index)
        } else {
            completions.append(date)
        }
    }

    // MARK: — Privado

    /// Devuelve los días relevantes para el cálculo del periodo, sin incluir fechas futuras
    private func relevantDays(for period: StatsPeriod, reference: Date) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        switch period {
        case .weekly:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
            return daysInRange(from: weekInterval.start, count: 7, calendar: calendar, upTo: today)

        case .monthly:
            let monthStart = calendar.startOfMonth(for: reference)
            guard let range = calendar.range(of: .day, in: .month, for: reference) else { return [] }
            return daysInRange(from: monthStart, count: range.count, calendar: calendar, upTo: today)

        case .yearly:
            guard let yearStart = calendar.date(from: calendar.dateComponents([.year], from: today)),
                  let range = calendar.range(of: .day, in: .year, for: today) else { return [] }
            return daysInRange(from: yearStart, count: range.count, calendar: calendar, upTo: today)
        }
    }

    /// Genera un array de fechas consecutivas desde un inicio, filtrando las futuras
    private func daysInRange(from start: Date, count: Int, calendar: Calendar, upTo limit: Date) -> [Date] {
        (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start)
        }.filter { $0 <= limit }
    }
    
    // MARK: — Rachas

    /// Racha actual de días consecutivos hasta hoy
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())
        while isCompleted(on: date) {
            streak += 1
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
        return streak
    }

    // Mejor racha histórica
    var bestStreak: Int {
        guard !completions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sorted = completions
            .map { calendar.startOfDay(for: $0) }
            .sorted()

        var best = 1
        var current = 1

        for i in 1..<sorted.count {
            let diff = calendar.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day ?? 0
            if diff == 1 {
                current += 1
                best = max(best, current)
            } else if diff > 1 {
                current = 1
            }
        }
        return best
    }
}
