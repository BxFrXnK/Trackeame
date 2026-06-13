//
//  StatsPeriod.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import Foundation

enum StatsPeriod: String, CaseIterable, Identifiable {

    case weekly
    case monthly
    case yearly

    // MARK: — Identifiable

    var id: String { rawValue }

    // MARK: — Presentación

    var label: String {
        switch self {
        case .weekly:  return "Esta semana"
        case .monthly: return "Este mes"
        case .yearly:  return "Este año"
        }
    }

    var icon: String {
        switch self {
        case .weekly:  return "calendar"
        case .monthly: return "calendar.badge.clock"
        case .yearly:  return "chart.bar.fill"
        }
    }
}
