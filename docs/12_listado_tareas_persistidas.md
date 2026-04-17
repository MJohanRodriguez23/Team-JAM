# HU-12: Listado de Tareas Persistidas

## Objetivo de la Historia

Esta historia formaliza el comportamiento de lectura de tareas persistidas. El foco ya no es el guardado en si, sino la consulta del listado asociado a la cuenta autenticada cuando el usuario entra a `Home`.

## Alcance Funcional

Con esta HU, `Home` debe comportarse como una vista de lectura sobre Firestore:

- al ingresar a `Home`, la app consulta las tareas persistidas del usuario autenticado
- el listado visible corresponde solo a la cuenta activa
- si no existen tareas para esa cuenta, se muestra el estado vacio

## Dependencias de Configuracion

Esta historia depende de la configuracion ya descrita en:

- `docs/09_registro_real.md`
- `docs/10_login_real.md`
- `docs/11_persistencia_tareas.md`

En particular, asume:

- Firebase inicializado correctamente
- sesion autenticada disponible en Firebase Auth
- Firestore habilitado en el proyecto
- reglas de seguridad alineadas con el `uid` del usuario autenticado

## Fuente de Datos

El listado de tareas se resuelve desde `Cloud Firestore` usando la siguiente estructura:

```txt
users/{uid}/tasks/{taskId}
```

Esta estructura define el criterio de aislamiento entre cuentas:

- cada usuario consulta solo su subcoleccion `tasks`
- `Home` no consulta una coleccion global compartida
- el `uid` autenticado es el identificador que determina qué tareas se leen

## Comportamiento de Carga

La pantalla `Home` ejecuta la carga en su ciclo de inicializacion y delega el acceso a datos a `TaskRepository`.

En la implementacion real:

- `HomeScreen` solicita las tareas al repositorio
- `FirestoreTaskRepository` resuelve el `uid` actual
- la consulta se ejecuta sobre `users/{uid}/tasks`
- los documentos obtenidos se convierten en objetos `Task`

## Visibilidad por Cuenta

El criterio `solo veo las tareas asociadas a mi cuenta` se cumple en la capa de repositorio, no en la UI.

Esto significa que:

- la pantalla recibe un listado ya filtrado por usuario
- la separacion de cuentas depende de la ruta de Firestore y de las reglas de seguridad
- si dos usuarios tienen tareas guardadas, cada uno consulta una subcoleccion distinta

## Estado Vacio

Cuando la consulta retorna cero documentos:

- `Home` no muestra una lista vacia sin contexto
- se presenta el estado vacio con mensaje e invitacion a crear tareas

Este comportamiento cubre tanto el primer uso como el caso de una cuenta autenticada sin tareas guardadas.

## Manejo de Errores

Si la consulta falla:

- la pantalla no se cae
- el usuario recibe un mensaje entendible

Los errores contemplados incluyen:

- usuario no autenticado
- Firebase o Firestore sin configuracion valida
- fallo al consultar documentos

## Componentes Relacionados

- `lib/screens/home_screen.dart`
- `lib/services/task_repository.dart`
- `lib/services/firestore_task_repository.dart`
- `lib/models/task.dart`

## Verificacion Automatizada

La HU queda respaldada por:

- pruebas widget de `Home` para carga de tareas y estado vacio
- pruebas de repositorio para validar que la consulta se resuelve por usuario

Archivos principales:

- `test/screens/home_screen_test.dart`
- `test/services/firestore_task_repository_test.dart`

## Resultado Esperado

Con la sesion autenticada activa y Firestore configurado, el usuario entra a `Home` y encuentra sus tareas persistidas disponibles para continuar el trabajo desde el punto en que lo dejo, sin ver tareas pertenecientes a otras cuentas.
