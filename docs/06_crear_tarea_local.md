# HU-06: Crear Tarea Local

## Objetivo de la Historia

Como usuario, necesito crear una tarea de forma local desde `Home` para visualizar rapidamente como voy a organizar mis actividades dentro de la app.

En esta etapa el comportamiento sigue siendo local. Todavia no existe persistencia en base de datos ni sincronizacion con un backend.

## Comportamiento Implementado

La pantalla `Home` ahora permite crear tareas locales usando el boton flotante `+`.

El flujo actual es:

1. El usuario entra a `Home`.
2. Presiona el boton flotante para abrir el dialogo `Crear tarea`.
3. Ingresa un titulo para la tarea.
4. Si el titulo es valido, la tarea se agrega inmediatamente a la lista local visible en pantalla.
5. Si el titulo esta vacio o solo contiene espacios, se muestra el mensaje `Ingresa un titulo para crear la tarea`.

## Alcance Actual

La historia cubre un escenario de organizacion local, por lo tanto:

- La tarea se conserva solo en memoria mientras la app esta abierta.
- No se guarda en Firebase ni en almacenamiento local persistente.
- No se capturan descripcion, fecha ni prioridad en esta HU.
- La lista se actualiza visualmente al crear una nueva tarea.

## Pantallas y Archivos Relacionados

- `lib/screens/home_screen.dart`
- `lib/models/task.dart`
- `test/screens/home_screen_test.dart`

## Criterios Cubiertos

La HU-06 queda cubierta porque actualmente se cumple que:

- Desde `Home` se puede iniciar la creacion de una tarea.
- Una tarea con titulo no vacio aparece en la lista local.
- Un titulo vacio muestra un mensaje entendible para el usuario.
- El comportamiento principal quedo respaldado con una prueba widget.

## Prueba Relacionada

La validacion principal de esta historia esta implementada en:

- `test/screens/home_screen_test.dart`

Esta prueba verifica:

1. Estado inicial de `Home`.
2. Apertura del dialogo de creacion.
3. Validacion de titulo vacio.
4. Creacion exitosa de una tarea local y visualizacion en la lista.
