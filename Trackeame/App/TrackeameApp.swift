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

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .sheet(isPresented: .constant(!hasSeenOnboarding)) {
                    OnboardingView()
                        .interactiveDismissDisabled()
                }
        }
        .modelContainer(for: Habit.self)
    }
}
