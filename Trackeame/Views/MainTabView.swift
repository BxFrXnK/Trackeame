//
//  MainTabView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import SwiftUI

struct MainTabView: View {

    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }
                .tag(Tab.home)

            ContentView()
                .tabItem { Label("Hábitos", systemImage: "checkmark.circle.fill") }
                .tag(Tab.habits)

            StatsView()
                .tabItem { Label("Estadísticas", systemImage: "chart.bar.fill") }
                .tag(Tab.stats)

            SettingsView()
                .tabItem { Label("Opciones", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .preferredColorScheme(appTheme.colorScheme)
    }

    enum Tab {
        case home, habits, stats, settings
    }
}
