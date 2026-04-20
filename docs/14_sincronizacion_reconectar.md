# HU-14: Sincronizacion al Reconectar

## Objetivo de la Historia

Esta historia formaliza el comportamiento de sincronizacion despues del trabajo offline. El objetivo es que los cambios realizados sin conexion no queden aislados en cache local, sino que se propaguen automaticamente a Firestore cuando el dispositivo recupera acceso a la red.

## Base Tecnica

La app se apoya en la persistencia offline oficial de Cloud Firestore. Cuando Firestore trabaja con cache local habilitada:

- las escrituras se aceptan localmente aunque no haya red
- los cambios quedan pendientes en el cliente
- al volver la conectividad, Firestore sincroniza esas operaciones con el backend

La documentacion oficial indica que, cuando el dispositivo vuelve a estar en linea, Firestore sincroniza los cambios locales con el backend y resuelve escrituras concurrentes bajo la regla `last write wins`.

Fuente oficial:

- https://firebase.google.com/docs/firestore/manage-data/enable-offline

## Comportamiento Implementado

Con esta HU, `Home` deja de depender solo de lecturas puntuales y queda suscrita al flujo de tareas persistidas.

La implementacion actual:

- escucha cambios de la coleccion de tareas del usuario
- recibe actualizaciones con metadata de Firestore
- detecta cuando existen cambios pendientes de escritura
- detecta cuando esos cambios ya quedaron sincronizados
- informa al usuario con mensajes claros

## Flujo de Sincronizacion

Cuando el usuario crea o edita tareas sin conexion:

1. Firestore acepta el cambio en cache local.
2. La app sigue mostrando las tareas disponibles sin bloquear `Home`.
3. El snapshot reporta que existen `pending writes`.
4. Cuando vuelve la conexion, Firestore envia los cambios al backend.
5. El snapshot deja de marcar escrituras pendientes.
6. La UI informa que los cambios fueron sincronizados.

## Mensajes al Usuario

La UI contempla al menos estos mensajes:

- `Cambios guardados localmente. Se sincronizaran cuando vuelva la conexion.`
- `Cambios sincronizados con Firestore.`
- `No se pudieron sincronizar tus tareas. Intenta nuevamente.`

## Manejo de Conflictos

La aplicacion no implementa un resolvedor manual de conflictos. En esta fase se adopta el comportamiento propio de Firestore para sincronizacion offline:

- si existen escrituras concurrentes sobre el mismo documento, prevalece la ultima escritura aplicada por Firestore

Por eso, dentro del alcance actual, el manejo de conflictos se aborda de dos formas:

- dejando que Firestore resuelva la escritura final
- mostrando mensajes claros cuando ocurre un fallo de sincronizacion observable desde el stream

## Componentes Ajustados

- `lib/services/task_repository.dart`
- `lib/services/firestore_task_repository.dart`
- `lib/screens/home_screen.dart`

## Decisiones de Diseño

Para soportar sincronizacion visible desde la UI se incorporo un flujo reactivo de tareas (`watchTasks`) en el repositorio.

Esto permite que `HomeScreen`:

- reciba cambios locales y remotos sin recargar manualmente
- sepa si el snapshot todavia tiene cambios pendientes
- muestre feedback cuando la sincronizacion termina

## Verificacion y Pruebas

La cobertura automatizada valida:

- que `Home` puede reaccionar a cambios pendientes
- que `Home` informa cuando la sincronizacion termina
- que el resto de flujos de autenticacion, persistencia y listado siguen funcionando

Archivo principal de validacion:

- `test/screens/home_screen_test.dart`

## Resultado Esperado

Con Firestore offline habilitado y una plataforma compatible, el usuario puede seguir trabajando sin internet y la app sincroniza automaticamente los cambios al reconectar, manteniendo la informacion actualizada en Firestore sin romper el flujo principal.
