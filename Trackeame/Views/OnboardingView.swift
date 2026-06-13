//
//  OnboardingView.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import SwiftUI

struct OnboardingView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icono
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "#34C759"))
                    .frame(width: 110, height: 110)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 32)

            // Título
            Text("Bienvenido a Trackeame")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Text("Tu compañero diario para construir\nhábitos que duran.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 48)

            // Características
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: "Seguimiento diario",
                    description: "Marca tus hábitos cada día con un solo toque."
                )
                FeatureRow(
                    icon: "calendar",
                    color: .blue,
                    title: "Historial mensual",
                    description: "Visualiza tu progreso mes a mes en un calendario."
                )
                FeatureRow(
                    icon: "flame.fill",
                    color: .orange,
                    title: "Rachas y estadísticas",
                    description: "Mantén tu racha y consulta tu porcentaje de cumplimiento."
                )
                FeatureRow(
                    icon: "bell.fill",
                    color: .purple,
                    title: "Recordatorios",
                    description: "Configura un recordatorio diario para no olvidarte."
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            // Botón
            Button {
                hasSeenOnboarding = true
                dismiss()
            } label: {
                Text("Empezar")
                    .font(.body.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#34C759"), in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

// MARK: — Fila de característica

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
