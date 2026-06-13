//
//  TrackeameApp.swift
//  Trackeame
//
//  Created by Francisco Garcia on 12/06/2026.
//

import SwiftUI
import SwiftData

@main
struct TrackeameApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Habit.self)
    }
}
