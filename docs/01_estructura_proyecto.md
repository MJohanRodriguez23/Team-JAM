# Estructura del Proyecto Flutter

Para mantener nuestro código de **To-Do UFPSO** ordenado, mantenible y escalable desde el día 1, utilizaremos una arquitectura basada en capas y separación de responsabilidades.

Toda la lógica de nuestra aplicación vivirá dentro de la carpeta `lib/`. A continuación se detalla para qué sirve cada una de las sub-carpetas que hemos creado:

## 📁 lib/

### 1. `models/`
Aquí vivirá la representación de nuestros datos. Por ejemplo, la clase `Task` o `UserModel`. 
Estos archivos solo deben contener propiedades y métodos para convertir los datos (ej. `fromJson` y `toJson` para interactuar con Firestore). **No deben tener lógica de negocio ni UI.**

### 2. `screens/` (o `pages/`)
Contiene las pantallas principales de nuestra aplicación (ej. `LoginScreen`, `HomeScreen`, `CreateTaskScreen`).
Una regla general es que un archivo en esta carpeta representa una ruta completa en la aplicación.

### 3. `widgets/`
Aquí colocaremos componentes visuales reutilizables que **no** son pantallas completas. Por ejemplo: `TaskCard`, `CustomButton`, `CustomTextField`.
Separar los widgets ayuda a que nuestras pantallas (`screens/`) no tengan cientos de líneas de código y sean fáciles de leer.

### 4. `services/`
Esta carpeta es crucial. Aquí vivirá el código que interactúa con el mundo exterior (APIs, Base de Datos, Autenticación).
Para este proyecto, aquí crearemos por ejemplo `AuthService` (para Firebase Auth) y `FirestoreService` (para leer/escribir tareas).
**Las pantallas nunca deben contactar a Firestore directamente, siempre deben pedirle los datos a un Service.**

### 5. `providers/` (Gestión de Estado)
Aquí residirá la lógica de estado de nuestra aplicación (usando Provider, Riverpod, o el gestor de estado que definamos).
Los *providers* son los encargados de conectar los `services/` con la UI (`screens/` y `widgets/`). 
Por ejemplo, un `TasksProvider` le pedirá las tareas al `FirestoreService` y notificará a la UI cuando las tareas estén listas para mostrarse.

### 6. `utils/`
Archivos con funciones auxiliares, constantes, paletas de colores o validadores (ej. validación de formato de email para el login).

---

## Flujo de Trabajo (Regla de Oro)

Para entender cómo se conectan estas carpetas, imagina el siguiente flujo cuando un usuario quiere ver sus tareas:

1. La **Screen** (`HomeScreen`) y sus **Widgets** (`TaskCard`) dibujan la UI.
2. La UI le pide las tareas al **Provider** (`TasksProvider`).
3. El **Provider** le solicita los datos al **Service** (`FirestoreService`).
4. El **Service** descarga los datos brutos de Firebase y los convierte en objetos **Model** (`Task`).
5. El **Service** le entrega la lista de `Task` al **Provider**.
6. El **Provider** le avisa a la **Screen** que los datos están listos.
7. La **Screen** se actualiza y muestra al usuario sus tareas.

¡Este orden garantizará que nuestro proyecto no se convierta en un "código espagueti" a medida que crece en las próximas semanas!
