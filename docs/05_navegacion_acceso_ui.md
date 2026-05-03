# HU-03: Navegación de Acceso (Fase UI)

## Objetivo de la Fase 1

En la **Fase 1** del proyecto seguimos trabajando únicamente la **UI**, la **navegación** y los comportamientos simulados del flujo de acceso.

Todavía no existe autenticación real ni persistencia de sesión con Firebase. El objetivo de esta historia es validar que el usuario pueda desplazarse correctamente entre las pantallas de acceso y la pantalla principal, entendiendo el flujo general de la aplicación antes de la integración real.

## Flujo de Navegación Implementado

Actualmente el proyecto implementa el siguiente recorrido:

1. La aplicación inicia en la pantalla de *Login*.
2. Desde *Login*, el usuario puede navegar a *Registro* mediante el enlace `Registrate gratis`.
3. Desde *Registro*, el usuario puede volver a *Login* mediante el enlace `Ya tienes cuenta? Inicia sesion`.
4. Si el formulario de login es válido, el usuario es redirigido a *Home*.
5. Desde *Home*, el botón de cerrar sesión devuelve al usuario a *Login*.

## Pantallas Involucradas

La navegación de esta historia conecta las siguientes pantallas:

- `login_screen.dart`
- `register_screen.dart`
- `home_screen.dart`

## Comportamiento Actual

La navegación es completamente local y simulada:

- No existe una sesión autenticada real.
- No se almacena ningún token ni usuario.
- El cierre de sesión no invalida credenciales, solo redirige a la pantalla de acceso.
- Las rutas se manejan mediante `Navigator.pushReplacementNamed(...)`.

## Criterios Cubiertos en la Implementación

La HU-03 puede considerarse completada en esta fase porque ya cumple con:

- Cambio entre login y registro desde las pantallas de acceso.
- Entrada a Home luego de un login mock exitoso.
- Retorno a login desde Home al cerrar sesión.
- Integración visual coherente con el resto del flujo.

## Prueba Relacionada

El flujo principal de esta historia está verificado en:

- `test/screens/access_navigation_test.dart`

Esta prueba recorre el escenario completo:

1. Login a Registro.
2. Registro a Login.
3. Login válido a Home.
4. Logout desde Home a Login.
