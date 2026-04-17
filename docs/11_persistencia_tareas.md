# HU-11: Persistencia de Tareas en Firestore

## Objetivo de la Historia

Esta historia incorpora persistencia real para las tareas del usuario usando `Cloud Firestore`. El objetivo es que las tareas ya no existan solo en memoria durante la ejecucion de la app, sino que queden asociadas a la cuenta autenticada y puedan recuperarse en sesiones posteriores.

## Alcance Funcional

Con esta HU, el modulo `Home` cambia de un comportamiento local a uno respaldado por base de datos:

- Las tareas se cargan desde Firestore al entrar a `Home`.
- Las nuevas tareas se guardan en Firestore al crearse.
- Las actualizaciones de estado pendiente/completada tambien se sincronizan con Firestore.
- Si la sesion del usuario sigue activa, las tareas vuelven a estar disponibles al reabrir la aplicacion.
- Si ocurre un error de carga, guardado o actualizacion, la interfaz muestra un mensaje entendible.

## Dependencias y Configuracion Requerida

La historia depende de la configuracion Firebase ya introducida en:

- `docs/09_registro_real.md`
- `docs/10_login_real.md`

Adicionalmente, esta HU requiere:

- `cloud_firestore` como dependencia del proyecto.
- Un proyecto Firebase con `Firestore Database` habilitado.
- Reglas de Firestore compatibles con usuarios autenticados.

## Configuracion Esperada en Firebase

### Firestore Database

El proyecto debe tener una base de datos Firestore creada dentro del mismo proyecto Firebase usado para autenticacion. La implementacion actual asume que las tareas viven bajo una estructura separada por usuario, por lo que la base de datos debe permitir operaciones autenticadas sobre documentos anidados por `uid`.

### Reglas de Seguridad

La configuracion esperada de reglas durante desarrollo autenticado es una variacion de este esquema:

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Estas reglas expresan el supuesto central de la HU:

- cada usuario solo puede leer sus propias tareas
- cada usuario solo puede escribir sus propias tareas

## Modelo de Persistencia

Las tareas se almacenan bajo la siguiente ruta:

```txt
users/{uid}/tasks/{taskId}
```

Donde:

- `uid` corresponde al usuario autenticado en Firebase Auth
- `taskId` corresponde al documento de la tarea dentro de la subcoleccion `tasks`

Cada documento de tarea incluye actualmente:

- `title`
- `description`
- `isCompleted`
- `createdAt`

## Comportamiento de la Aplicacion

### Inicio de la App

El arranque ahora pasa por una capa de inicializacion Firebase (`AppStartGate`). Esta capa intenta:

1. inicializar Firebase
2. detectar si existe una sesion activa
3. dirigir al usuario a `Home` o `Login`

Esto permite que la persistencia de sesion y la de tareas se comporten de forma coherente.

### Carga de Tareas

`HomeScreen` delega la carga a un repositorio. En la implementacion real, ese repositorio consulta Firestore para el usuario actual y obtiene la coleccion de tareas ordenada por `createdAt`.

### Creacion de Tareas

Cuando el usuario crea una tarea valida:

- la UI valida que el titulo no este vacio
- el repositorio crea el documento en Firestore
- la tarea guardada se incorpora al listado visible en `Home`

### Actualizacion de Estado

Cuando el usuario marca o desmarca una tarea:

- cambia el estado visual de la tarea
- la actualizacion se persiste en Firestore

## Manejo de Errores

La persistencia de tareas usa un tipo de error propio (`TaskFailure`) para desacoplar la UI de errores directos del SDK de Firebase.

Los mensajes visibles al usuario cubren principalmente:

- error al cargar tareas
- error al guardar una tarea
- error al actualizar una tarea
- falta de autenticacion activa
- Firebase o Firestore sin configuracion valida para la plataforma

## Componentes Introducidos o Ajustados

### Inicializacion

- `lib/main.dart`
- `lib/services/firebase_bootstrap.dart`

### Persistencia de Tareas

- `lib/services/task_repository.dart`
- `lib/services/firestore_task_repository.dart`
- `lib/models/task.dart`

### UI de Home

- `lib/screens/home_screen.dart`

## Decisiones de Diseño

Esta HU usa una interfaz de repositorio para tareas en lugar de acceder directamente a Firestore desde la pantalla. Eso permite:

- aislar la logica de persistencia
- facilitar pruebas de widget sin backend real
- mantener `HomeScreen` enfocada en comportamiento de UI

La misma idea ya venia aplicandose en autenticacion y aqui se extiende al modulo de tareas.

## Verificacion y Pruebas

La cobertura automatizada valida:

- estado vacio cuando no hay tareas recuperadas
- creacion de una tarea valida
- permanencia de tareas al reconstruir `Home`
- mensaje entendible si falla el guardado
- cambio de estado pendiente/completada con repositorio persistente

Archivo principal de prueba:

- `test/screens/home_screen_test.dart`

## Resultado Esperado

Con la configuracion Firebase correcta y una sesion autenticada activa, la app queda preparada para que las tareas del usuario sobrevivan al cierre de la aplicacion y vuelvan a cargarse desde Firestore cuando la sesion se restaura.
