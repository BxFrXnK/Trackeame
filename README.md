# Trackeame

Aplicación nativa para iOS y macOS de seguimiento de hábitos diarios, desarrollada íntegramente en Swift y SwiftUI como proyecto personal.

---

## Capturas de pantalla

> *Próximamente*

---

## Descripción

Trackeame permite crear hábitos personalizados y hacer un seguimiento visual de su cumplimiento día a día. La interfaz está diseñada para ser rápida e intuitiva, con el objetivo de reducir la fricción al registrar un hábito completado.

El proyecto nació como un ejercicio práctico para aprender el ecosistema nativo de Apple desde cero, abarcando SwiftUI, SwiftData, navegación con TabView y notificaciones locales.

---

## Funcionalidades

- Crear, editar y eliminar hábitos con nombre y color personalizados
- Marcar y desmarcar hábitos para cualquier día del historial
- Calendario mensual interactivo con navegación entre meses
- Pantalla de inicio con resumen diario y progreso visual
- Estadísticas por hábito: porcentaje de cumplimiento, racha actual y mejor racha
- Periodos de estadísticas configurables: semanal, mensual y anual
- Recordatorio diario configurable mediante notificaciones locales
- Soporte de tema claro, oscuro y sistema
- Compatible con iPhone y Mac desde un único proyecto

---

## Tecnologías

| Tecnología | Uso |
|---|---|
| Swift | Lenguaje principal |
| SwiftUI | Interfaz de usuario |
| SwiftData | Persistencia local |
| WidgetKit | Widget (en desarrollo) |
| UserNotifications | Recordatorios locales |
| Xcode Multiplatform | Proyecto único para iOS y macOS |

---

## Arquitectura

El proyecto sigue una separación clara por capas:

```
Trackeame/
├── App/          — Punto de entrada y configuración
├── Models/       — Modelo de datos y lógica de negocio
├── Views/        — Vistas y componentes de interfaz
├── Services/     — Servicios y comunicación entre capas
└── Extensions/   — Extensiones de tipos del sistema
```

La capa de modelos encapsula toda la lógica de fechas, rachas y estadísticas, manteniendo las vistas libres de lógica de negocio.

---

## Requisitos

- Xcode 16 o superior
- iOS 17 o superior
- macOS 14 o superior
- Cuenta de Apple (para instalar en dispositivo físico)

---

## Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tunombre/Trackeame.git
   ```
2. Abre `Trackeame.xcodeproj` en Xcode.
3. Selecciona tu dispositivo o simulador en la barra superior.
4. Pulsa **⌘ + R** para compilar y ejecutar.

No se requieren dependencias externas ni gestores de paquetes.

---

## Estado del proyecto

| Funcionalidad | Estado |
|---|---|
| Gestión de hábitos | ✅ Completo |
| Calendario mensual | ✅ Completo |
| Estadísticas y rachas | ✅ Completo |
| Recordatorios locales | ✅ Completo |
| Temas claro/oscuro | ✅ Completo |
| Widget iOS/macOS | 🔄 En desarrollo |
| Sincronización iCloud | 🔄 Pendiente |

---

## Autor

**Francisco García**  
Proyecto personal de aprendizaje de desarrollo nativo Apple.

---

## Licencia

Este proyecto es de uso personal y no está disponible para distribución.
