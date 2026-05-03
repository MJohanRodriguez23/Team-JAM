# HU-07: Listar Estado Vacio

## Objetivo de la Historia

Como usuario, quiero ver un estado vacio cuando no tengo tareas registradas localmente para entender que todavia no he creado ninguna y saber cual es la siguiente accion disponible.

## Comportamiento Implementado

Cuando el usuario entra a `Home` y la lista local de tareas esta vacia, la pantalla muestra un estado vacio dedicado.

Este estado incluye:

- Un icono ilustrativo para representar que aun no existen tareas.
- Un mensaje principal: `Aun no tienes tareas locales`.
- Un texto de apoyo que explica que el usuario puede empezar creando su primera tarea.
- Un boton visible `Crear mi primera tarea`.
- El boton flotante `+`, que sigue disponible para abrir el flujo de creacion.

## Alcance Actual

En esta fase el comportamiento sigue siendo completamente local:

- El estado vacio depende solo de la lista en memoria de `Home`.
- No existe sincronizacion con backend ni persistencia permanente.
- El objetivo de la HU es mejorar la comprension del estado inicial de la app.

## Pantallas y Archivos Relacionados

- `lib/screens/home_screen.dart`
- `test/screens/home_screen_test.dart`
- `docs/06_crear_tarea_local.md`

## Criterios Cubiertos

La HU-07 queda cubierta porque actualmente:

- Si no existen tareas locales, `Home` muestra un estado vacio entendible.
- El usuario recibe una pista visual y textual sobre la ausencia de tareas.
- La opcion de crear una tarea permanece visible dentro del contenido y en el FAB.

## Prueba Relacionada

La cobertura principal de esta historia esta en:

- `test/screens/home_screen_test.dart`

La prueba valida:

1. Que el estado vacio aparezca al entrar a `Home` sin tareas.
2. Que el mensaje e ilustracion sean visibles.
3. Que la opcion de crear tarea siga disponible.
