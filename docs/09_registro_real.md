# HU-09: Registro Real con Firebase Auth

## Objetivo de la Historia

Como usuario, quiero crear mi cuenta real para guardar mi informacion de manera persistente y poder avanzar hacia un flujo autenticado en la aplicacion.

## Comportamiento Implementado

La pantalla de registro ya no usa un mock local. Ahora intenta crear el usuario con `Firebase Auth` usando correo y contrasena.

Si el registro es exitoso:

- Se crea la cuenta en Firebase Authentication.
- El usuario es redirigido a `Home`.

Si ocurre un error:

- Se muestra un mensaje entendible dentro de la app.

## Requisitos Previos

Antes de probar el registro real necesitas:

1. Tener una cuenta de Google.
2. Tener acceso a [Firebase Console](https://console.firebase.google.com/).
3. Tener instalado Flutter.
4. Tener configurado el proyecto para compilar Android, iOS o Web.

## Paso a Paso en Firebase

### 1. Crear el proyecto en Firebase

1. Entra a Firebase Console.
2. Presiona `Crear un proyecto`.
3. Asigna un nombre al proyecto, por ejemplo: `to-do-ufpso`.
4. Puedes desactivar Google Analytics si no lo necesitas para esta fase.
5. Finaliza la creacion del proyecto.

### 2. Habilitar Authentication

1. En el menu lateral entra a `Authentication`.
2. Presiona `Comenzar`.
3. Abre la pestana `Sign-in method`.
4. Habilita `Email/Password`.
5. Guarda los cambios.

### 3. Instalar herramientas necesarias

En tu maquina instala o verifica:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

Luego autentica tu sesion:

```bash
firebase login
```

## Paso a Paso en el Proyecto Flutter

### 4. Obtener dependencias

Dentro del proyecto ejecuta:

```bash
flutter pub get
```

### 5. Vincular Flutter con Firebase

Desde la raiz del proyecto ejecuta:

```bash
flutterfire configure
```

Durante este proceso:

1. Selecciona el proyecto de Firebase que acabas de crear.
2. Marca las plataformas que vas a usar.
3. Permite que genere el archivo `lib/firebase_options.dart`.

Importante:

- Este repositorio ya trae un `lib/firebase_options.dart` placeholder para no bloquear el desarrollo.
- Cuando ejecutes `flutterfire configure`, ese archivo debe ser reemplazado por el generado por FlutterFire.

### 6. Verificar configuracion por plataforma

#### Android

Revisa que exista el archivo:

- `android/app/google-services.json`

Si FlutterFire no lo deja listo automaticamente, descargalo desde Firebase Console:

1. En `Configuracion del proyecto`.
2. Seccion `Tus apps`.
3. Selecciona la app Android.
4. Descarga `google-services.json`.
5. Guardalo en `android/app/`.

#### iOS

Revisa que exista el archivo:

- `ios/Runner/GoogleService-Info.plist`

Si hace falta:

1. En Firebase Console abre la app iOS.
2. Descarga `GoogleService-Info.plist`.
3. Agregalo a `ios/Runner/`.

#### Web

Si vas a usar Web, el paso obligatorio es haber ejecutado correctamente:

```bash
flutterfire configure
```

Web necesita opciones explicitas de Firebase para inicializar la app.

### 7. Ejecutar la aplicacion

Inicia la app normalmente:

```bash
flutter run
```

### 8. Probar el registro real

1. Entra a `Crear Cuenta`.
2. Usa un correo valido.
3. Usa una contrasena de minimo 6 caracteres.
4. Presiona `Registrarse`.
5. Si todo esta correcto, deberias entrar a `Home`.

### 9. Verificar el usuario en Firebase

En Firebase Console:

1. Ve a `Authentication`.
2. Abre la pestana `Users`.
3. Confirma que el correo registrado aparece en la lista.

## Mensajes de Error Mapeados

La app ya interpreta varios errores comunes de Firebase:

- Correo ya registrado.
- Correo invalido.
- Contrasena debil.
- Error de red.
- Metodo `Email/Password` deshabilitado.
- Firebase sin configurar en el proyecto.

## Archivos Relacionados

- `lib/screens/register_screen.dart`
- `lib/services/auth_service.dart`
- `lib/services/firebase_auth_service.dart`
- `lib/firebase_options.dart`
- `test/screens/register_screen_test.dart`

## Nota Importante

Aunque el flujo ya fue adaptado para usar Firebase Auth, el registro real solo funcionara cuando completes la configuracion descrita arriba.

Si intentas registrar un usuario sin terminar esa configuracion, la app mostrara un mensaje entendible indicando que Firebase aun no esta configurado.
