# Correcciones para los Componentes de UI

## Problemas identificados en los componentes

1. **SearchBar**: Falta de validación y manejo de entrada de usuario
2. **Carousel**: Posibles problemas de configuración y carga de imágenes
3. **BottomNavigationComponent**: Posibles problemas de estado y navegación
4. **HomeScreen**: Problemas de layout y manejo de datos

## Correcciones para SearchBar

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Implementar lógica de búsqueda aquí
    // Por ejemplo, llamar a una función de callback
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 18),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.6,
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.start,
              cursorHeight: 20,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.pink,
                ),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Buscar servicios...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(45),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.slider_horizontal_3,
                color: Colors.pink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
            ),
            child: const Center(
              child: Icon(
                Icons.filter_alt_outlined,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
```

## Correcciones para Carousel

```dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carousel extends StatelessWidget {
  const Carousel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        _buildCarouselItem(
          context,
          "https://images.squarespace-cdn.com/content/v1/5e867df9747b0e555c337eef/1589945925617-4NY8TG8F76FH1O0P46FW/Kampaamo-helsinki-hair-design-balayage-hiustenpidennys-varjays.png",
          "¡Luce Increíble!",
          "Y ahorra algo",
          "Obtén hasta 20% de descuento",
        ),
        _buildCarouselItem(
          context,
          "https://img.grouponcdn.com/bynder/2sLSquS1xGWk4QjzYuL7h461CDsJ/2s-2048x1229/v1/sc600x600.jpg",
          "Reserva tu\nCita",
          "Ahora",
          "¡Reserva aquí!",
        ),
      ],
      options: CarouselOptions(
        height: 180.0,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        viewportFraction: 0.85,
        onPageChanged: (index, reason) {
          // Callback opcional para manejar cambios de página
        },
      ),
    );
  }

  Widget _buildCarouselItem(
    BuildContext context,
    String imageUrl,
    String title,
    String subtitle,
    String buttonText,
  ) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: const LinearGradient(
          colors: [
            Color(0xff721c80),
            Color.fromARGB(255, 196, 103, 169),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xffffffff),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xffffffff),
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                _buildButton(buttonText),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff721c80),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

## Correcciones para BottomNavigationComponent

```dart
import 'package:flutter/material.dart';
import 'package:salon_app/screens/booking/booking_screen.dart';
import 'package:salon_app/screens/home/home_screen.dart';
import 'package:salon_app/screens/maps/maps_screen.dart';
import 'package:salon_app/screens/profile/profile_screen.dart';

class BottomNavigationComponent extends StatefulWidget {
  const BottomNavigationComponent({super.key});

  @override
  State<BottomNavigationComponent> createState() =>
      _BottomNavigationComponentState();
}

class _BottomNavigationComponentState extends State<BottomNavigationComponent> {
  List<Widget> screens = [
    const HomeScreen(),
    const MapsPage(),
    const BookingScreen(),
    const ProfileScreen()
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Color(0xff721c80),
            ),
            label: 'Inicio',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_on_outlined,
              color: Color(0xff721c80),
            ),
            label: 'Visitar',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.edit_calendar_outlined,
              color: Color(0xff721c80),
            ),
            label: 'Reservar',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Color(0xff721c80),
            ),
            label: 'Perfil',
            backgroundColor: Colors.white,
          ),
        ],
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        iconSize: 26,
        onTap: _onItemTapped,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}
```

## Beneficios de las correcciones

1. **Mejor manejo de recursos**: Disposal correcto de controladores
2. **Experiencia de usuario mejorada**: Indicadores de carga y manejo de errores
3. **Layout responsivo**: Uso de MediaQuery para tamaños adaptables
4. **Prevención de errores**: Validaciones y fallbacks
5. **Consistencia visual**: Sombras y bordes redondeados consistentes

## Consideraciones importantes

1. **Pruebas en diferentes dispositivos**: Verificar el comportamiento en distintos tamaños de pantalla
2. **Accesibilidad**: Asegurar que los colores tengan suficiente contraste
3. **Rendimiento**: Evitar rebuilds innecesarios con IndexedStack
4. **Internacionalización**: Considerar la localización de textos
5. **Mantenimiento**: Código estructurado para facilitar futuras modificaciones