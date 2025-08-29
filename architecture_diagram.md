# Arquitectura de la Aplicación Salon Booking

## Diagrama de Componentes

```mermaid
graph TD
    A[main.dart] --> B[MyApp]
    B --> C[MultiProvider]
    C --> D[UserProvider]
    C --> E[MaterialApp]
    E --> F[SplashScreen]
    
    F --> G[OnBoardingScreen]
    G --> H[Authentication]
    H --> I[FirebaseAuth]
    H --> J[GoogleSignIn]
    
    G --> K[BottomNavigationComponent]
    K --> L[HomeScreen]
    K --> M[MapsPage]
    K --> N[BookingScreen]
    K --> O[ProfileScreen]
    
    L --> P[Carousel]
    L --> Q[SearchBar]
    L --> R[StreamBuilder - Services]
    L --> S[StreamBuilder - Workers]
    
    R --> T[CloudFirestore]
    S --> T
    
    D --> U[UserProvider]
    U --> V[ChangeNotifier]
    
    H --> U
```

## Diagrama de Flujo de Datos

```mermaid
graph LR
    A[Usuario inicia app] --> B[SplashScreen]
    B --> C[OnBoardingScreen]
    C --> D[Google Auth]
    D --> E{Autenticación exitosa?}
    E -->|Sí| F[BottomNavigation]
    E -->|No| G[Mostrar error]
    F --> H[Navegación entre pantallas]
    H --> I[HomeScreen]
    H --> J[MapsPage]
    H --> K[BookingScreen]
    H --> L[ProfileScreen]
    I --> M[Firestore Services]
    I --> N[Firestore Workers]
```

## Estructura de Directorios

```
lib/
├── main.dart
├── components/
│   ├── bottom_navigationbar.dart
│   ├── carousel.dart
│   ├── searchbar.dart
│   └── date_picker.dart
├── controller/
│   └── auth_controller.dart
├── provider/
│   └── user_provider.dart
├── screens/
│   ├── booking/
│   │   └── booking_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── introduction/
│   │   ├── onboarding_screen.dart
│   │   └── spalsh_screen.dart
│   ├── maps/
│   │   └── maps_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/
    └── horizontal_line.dart