//
//  Calendar+Extensions.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import Foundation

extension Calendar {

    // MARK: — Inicio de periodos

    /// Devuelve el primer día del mes de la fecha indicada
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }

    /// Devuelve el primer día de la semana (lunes) de la fecha indicada
    func startOfWeek(for date: Date) -> Date {
        let weekday = component(.weekday, from: date)
        let daysFromMonday = (weekday + 5) % 7
        return self.date(byAdding: .day, value: -daysFromMonday, to: startOfDay(for: date))!
    }

    /// Devuelve el primer día del año de la fecha indicada
    func startOfYear(for date: Date) -> Date {
        let components = dateComponents([.year], from: date)
        return self.date(from: components)!
    }

    // MARK: — Consultas

    /// Devuelve true si la fecha es posterior al día de hoy
    func isFuture(_ date: Date) -> Bool {
        date > startOfDay(for: Date())
    }

    /// Devuelve true si la fecha pertenece al mes indicado
    func isDate(_ date: Date, inSameMonthAs reference: Date) -> Bool {
        isDate(date, equalTo: reference, toGranularity: .month)
    }

    /// Devuelve los días de una semana completa a partir del lunes
    func daysOfWeek(for date: Date) -> [Date] {
        let monday = startOfWeek(for: date)
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: monday) }
    }
}
