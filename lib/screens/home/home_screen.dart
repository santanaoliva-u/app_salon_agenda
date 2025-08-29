import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Alias para tu SearchBar personalizado
import 'package:salon_app/components/searchbar.dart' as custom;

// Carousel custom, no choca con carousel_slider
import '../../components/carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff721c80),
                          Color.fromARGB(255, 196, 103, 169),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 38, left: 18, right: 18),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.location_solid,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Kalyan, IN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                CupertinoIcons.person_alt_circle_fill,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                          custom.SearchBar(), // Alias aplicado
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 150,
                  left: 0,
                  right: 0,
                  child: Carousel(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Column(
                children: [
                  const HorizontalText(),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('services')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      // Manejo de errores
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Error al cargar servicios: ${snapshot.error}'),
                        );
                      }

                      // Indicador de carga
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                          color: Colors.purple,
                        );
                      }

                      // Verificar si hay datos
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No hay servicios disponibles'),
                        );
                      }

                      // Mostrar datos
                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            // Verificar que el documento exista
                            var document = snapshot.data!.docs[index];
                            if (document.exists) {
                              return CategoryCard(e: document);
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18, top: 16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        "Best Specialists",
                        style: TextStyle(
                          color: Color(0xff721c80),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Spacer(flex: 8),
                      Text(
                        "View all",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.grey,
                        size: 18,
                      ),
                      Spacer(flex: 1),
                    ],
                  ),
                  const SizedBox(height: 18),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('workers')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      // Manejo de errores
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Error al cargar trabajadores: ${snapshot.error}'),
                        );
                      }

                      // Indicador de carga
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                          color: Colors.purple,
                        );
                      }

                      // Verificar si hay datos
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No hay trabajadores disponibles'),
                        );
                      }

                      // Mostrar datos
                      return SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            // Verificar que el documento exista
                            var document = snapshot.data!.docs[index];
                            if (document.exists) {
                              return Container(
                                margin: const EdgeInsets.only(right: 12.0),
                                height: 160,
                                width: 120,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      document["img"] ??
                                          "https://via.placeholder.com/120x160?text=Sin+Imagen",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: 80,
                                    height: 22,
                                    child: Text(
                                      document["name"] ?? "Sin nombre",
                                      style:
                                          const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              height: 20,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 220, 218, 218),
                    width: 0.9,
                  ),
                ),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(top: 12, right: 18, left: 18, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.south_america_outlined,
                        size: 28,
                        color: Color(0xff721c80),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'website',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.discount,
                        size: 28,
                        color: Color(0xff721c80),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Offers',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.phone_in_talk_sharp,
                        size: 28,
                        color: Color(0xff721c80),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Call',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalText extends StatelessWidget {
  const HorizontalText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 18, right: 18, bottom: 12),
      child: Row(
        children: [
          Text(
            "Best Services",
            style: TextStyle(
              color: Color(0xff721c80),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Spacer(),
          Text(
            "View all",
            style: TextStyle(color: Colors.grey),
          ),
          Icon(
            Icons.double_arrow_rounded,
            color: Colors.grey,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> e;
  const CategoryCard({
    super.key,
    required this.e,
  });

  @override
  Widget build(BuildContext context) {
    // Verificar que el documento exista y tenga datos
    if (e.data() == null) {
      return const SizedBox.shrink();
    }

    // Acceder a los datos de forma segura
    final data = e.data() as Map<String, dynamic>;
    final String imageUrl = data['img'] ?? '';
    final String name = data['name'] ?? 'Sin nombre';

    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10.0,
                  spreadRadius: 0.5,
                  offset: Offset(3.0, 3.0),
                )
              ],
              image: DecorationImage(
                image: NetworkImage(imageUrl.isNotEmpty
                    ? imageUrl
                    : "https://via.placeholder.com/50x50?text=Sin+Imagen"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            name,
            style: const TextStyle(color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}
