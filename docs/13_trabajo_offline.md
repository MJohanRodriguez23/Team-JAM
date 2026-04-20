# HU-13: Trabajo Offline

## Objetivo de la Historia

Esta historia incorpora soporte de trabajo offline sobre la persistencia de tareas. El objetivo es que la app no dependa completamente de la conectividad para consultar, crear o actualizar tareas cuando Firestore ya dispone de cache local en el dispositivo.

## Alcance Funcional

Con esta HU, la aplicacion queda preparada para:

- consultar tareas desde cache local cuando no hay conexion
- aceptar cambios de creacion y actualizacion mientras el dispositivo esta offline
- mantener visible el listado disponible en el dispositivo
- evitar que la falta de internet bloquee el flujo principal de `Home`

## Base Tecnica

La estrategia elegida no introduce una base local paralela. En su lugar, la app aprovecha la persistencia offline oficial de `Cloud Firestore`.

Segun la documentacion oficial de Firebase, Firestore soporta persistencia offline en:

- Android
- plataformas Apple
- Web

Fuente oficial:

- https://firebase.google.com/docs/firestore/manage-data/enable-offline

## Configuracion Aplicada en la App

La configuracion offline se centraliza en:

- `lib/services/firebase_bootstrap.dart`

Esta capa realiza dos responsabilidades:

1. inicializar Firebase
2. configurar el comportamiento offline de Firestore antes de que Auth y las pantallas dependan del SDK

## Configuracion por Plataforma

### Android, iOS y macOS

En estas plataformas se configura:

```dart
firestore.settings = const Settings(persistenceEnabled: true);
```

Esto deja habilitada la persistencia local de Firestore para lectura y escritura sin conexion.

### Web

En web la persistencia offline no se asume activa por defecto, por lo que la app intenta habilitarla explícitamente con sincronizacion entre pestañas:

```dart
await firestore.enablePersistence(
  const PersistenceSettings(synchronizeTabs: true),
);
```

Si el navegador o el contexto no soportan esa persistencia, la app no interrumpe el flujo principal; simplemente continúa sin bloquear la interfaz.

### Windows y Linux

La implementacion actual no fuerza una configuracion offline especial para estas plataformas, porque la propia documentacion oficial de Firestore no las incluye dentro del soporte de persistencia offline para este escenario.

## Comportamiento Esperado

Cuando el usuario pierde conectividad:

- `Home` puede seguir mostrando tareas previamente cacheadas
- una nueva tarea puede quedar registrada localmente por Firestore
- una actualizacion de estado pendiente/completada puede quedar en cola local
- cuando la conexion vuelve, Firestore sincroniza los cambios con el backend

## Relacion con la HU de Persistencia

Esta historia extiende lo ya implementado en:

- `docs/11_persistencia_tareas.md`

La diferencia principal es que `HU-11` define la persistencia remota y `HU-13` documenta y configura el comportamiento cuando la conectividad no esta disponible temporalmente.

## Manejo de Errores y Flujo Principal

La app intenta que la falta de red no rompa la experiencia de `Home`. En especial:

- la inicializacion de persistencia offline no debe bloquear la app si el navegador no soporta una capacidad concreta
- la UI sigue dependiendo del repositorio y de los mensajes entendibles ya definidos para errores reales de Firebase
- la navegacion principal no se detiene por ausencia momentanea de internet

## Componentes Relacionados

- `lib/services/firebase_bootstrap.dart`
- `lib/services/firestore_task_repository.dart`
- `lib/screens/home_screen.dart`
- `lib/main.dart`

## Resultado Esperado

Con Firebase y Firestore correctamente configurados en una plataforma soportada, la app puede seguir mostrando y modificando tareas en condiciones offline, apoyandose en la cache local administrada por Firestore y sincronizando los cambios cuando la conexion vuelve.
