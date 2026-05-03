# HU-02: Login de Usuario (Fase UI)

## Objetivo de la Fase 1

La aplicación continúa en la **Fase 1**, centrada en la construcción de la **Interfaz de Usuario (UI)**, la **navegación** y las **validaciones locales**.

En esta etapa aún no existe integración con Firebase Authentication ni una base de datos de usuarios. El propósito del login actual es permitir que el estudiante pruebe el flujo de acceso, comprenda el comportamiento del formulario y visualice cómo se conectan las pantallas antes de pasar a la autenticación real.

## Interfaz de Inicio de Sesión (`login_screen.dart`)

Actualmente la aplicación inicia en la pantalla de *Login*. Su responsabilidad actual es:

1. Capturar el correo electrónico.
2. Capturar la contraseña.
3. Validar localmente que ambos campos cumplan el formato esperado.
4. Mostrar un indicador de carga (`CircularProgressIndicator`) al presionar el botón si los datos son válidos.
5. Simular internamente una espera de un (1) segundo.
6. Redirigir de forma exitosa a la pantalla principal (`home_screen.dart`).
7. Permitir la navegación hacia la pantalla de registro (`register_screen.dart`).
8. Mostrar accesos visuales para Google, GitHub y Facebook como referencia de futuras integraciones sociales.

## Validaciones ("Mocks") Actuales

Para ingresar de manera exitosa a la pantalla principal, actualmente puedes usar **cualquier combinación de datos válidos**.

El sistema no verifica todavía si el usuario existe, si la contraseña coincide con una cuenta real o si hay una sesión almacenada. El login actual solo valida:

### Correo Electrónico

- **Debe existir:** No puede estar vacío.
- **Debe tener formato de email:** Se valida usando una Expresión Regular (`Regex`).
  - ❌ Incorrecto: `usuario`
  - ❌ Incorrecto: `estudiante@ufpso`
  - ✅ Correcto: `estudiante@ufpso.edu.co`
  - ✅ Correcto: `prueba@gmail.com`

### Contraseña

- **Debe existir:** No puede estar vacía.
- **Debe tener mínimo 6 caracteres:** Cualquier texto de 6 o más caracteres permite avanzar en el flujo mock.
  - ❌ Incorrecto: `12345`
  - ✅ Correcto: `123456`
  - ✅ Correcto: `MiClaveSegura2026`

## Flujo Visual Implementado

La pantalla de login implementa actualmente el siguiente comportamiento:

1. Muestra la identidad visual institucional de la app.
2. Presenta los campos de correo y contraseña.
3. Incluye un botón principal `Ingresar`.
4. Muestra una sección social con íconos de Google, GitHub y Facebook.
5. Incluye el mensaje `¿No tienes una cuenta? Registrate gratis`, donde el enlace redirige a la pantalla de registro.

## Criterio para Considerar la HU-02 Terminada

Dentro de la fase UI, esta historia puede considerarse finalizada porque ya cumple con:

- Pantalla de login visible como entrada principal de la app.
- Validación local de correo y contraseña.
- Mensajes de error entendibles.
- Estado de carga simulado.
- Navegación exitosa hacia Home.
- Navegación hacia registro.
- Prueba de widget para validar el comportamiento principal.

## Pruebas Relacionadas

El comportamiento del login está cubierto por:

- `test/screens/login_screen_test.dart`
- `test/utils/validators_test.dart`

Estas pruebas verifican validaciones, loading y navegación del flujo mock actual.
