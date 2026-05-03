# HU-08: Completar Tarea Local

## Objetivo de la Historia

Como usuario, quiero marcar tareas locales como completadas para llevar un control visual de mis pendientes y reconocer rapidamente lo que ya hice.

## Comportamiento Implementado

Cuando el usuario ya tiene tareas creadas en `Home`, cada una puede cambiar entre estado pendiente y completada.

El flujo actual es:

1. El usuario crea una tarea local.
2. La tarea aparece inicialmente como pendiente.
3. Al marcarla, cambia visualmente a completada.
4. Al desmarcarla, vuelve a mostrarse como pendiente.

## Cambios Visuales Aplicados

Cuando una tarea queda completada:

- El icono cambia a `check_circle`.
- El titulo se muestra con linea tachada.
- El color del texto pasa a un tono mas suave.
- El subtitulo cambia a `Tarea completada`.

Cuando la tarea vuelve a pendiente:

- El icono vuelve a `radio_button_unchecked`.
- El titulo recupera su estilo normal.
- El subtitulo vuelve a `Tarea pendiente`.

## Alcance Actual

En esta HU el comportamiento sigue siendo local:

- El estado de completado solo vive en memoria.
- No existe persistencia en base de datos ni almacenamiento local permanente.
- La actualizacion es inmediata dentro de la UI de `Home`.

## Pantallas y Archivos Relacionados

- `lib/screens/home_screen.dart`
- `lib/models/task.dart`
- `test/screens/home_screen_test.dart`

## Criterios Cubiertos

La HU-08 queda cubierta porque:

- Las tareas locales pueden marcarse como completadas.
- El estado visual cambia de manera clara al completarlas.
- Las tareas pueden desmarcarse para volver a pendiente.
- El flujo principal esta respaldado por pruebas widget.

## Prueba Relacionada

La validacion principal de esta historia esta implementada en:

- `test/screens/home_screen_test.dart`

La prueba verifica:

1. Creacion de una tarea local.
2. Estado inicial pendiente.
3. Cambio visual a completada.
4. Retorno al estado pendiente al desmarcarla.
