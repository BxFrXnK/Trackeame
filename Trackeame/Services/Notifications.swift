//
//  Notifications.swift
//  Trackeame
//
//  Created by Francisco Garcia on 13/06/2026.
//

import Foundation

// Notificaciones internas de la app para comunicación entre capas
extension Notification.Name {

    // Se emite cuando el estado de un hábito cambia (marcar/desmarcar)
    static let habitChanged = Notification.Name("com.trackeame.habitChanged")

    // Se emite cuando se añade o elimina un hábito
    static let habitListChanged = Notification.Name("com.trackeame.habitListChanged")
}
