import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_app/components/date_picker.dart';
import 'package:salon_app/services/api_config_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedIndex = 0;

  void onClick(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildOfflineServicesList() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 32,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Firebase no disponible',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              'Modo sin conexión',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorServicesList(String error) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            const Text(
              'Error al cargar servicios',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingServicesList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12.0),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff721c80)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyServicesList() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'No hay servicios disponibles',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBooking(BuildContext context) async {
    try {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procesando reserva...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Simulate booking process
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reserva realizada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar la reserva: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOfflineBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modo Sin Conexión'),
        content: const Text(
          'La funcionalidad de reservas requiere conexión a Firebase. '
          'Por favor, habilite Firebase en la configuración o conecte a internet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to settings
              Navigator.of(context).pushNamed('/settings');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff721c80),
            ),
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 240,
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
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 38, left: 18, right: 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          "Book Your Appointment",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                      ],
                    ),
                    CustomDatePicker(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available Slots",
                    style: TextStyle(
                        color: Color.fromARGB(255, 45, 42, 42),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide()),
                        label: const Text("10:00 AM"),
                        backgroundColor: Colors.white,
                      ),
                      Chip(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide()),
                        label: const Text(
                          "10:00 AM",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.purple,
                      ),
                      Chip(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide()),
                        label: const Text("10:00 AM"),
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                  const ChipWrapper(),
                  const ChipWrapper(),
                  const ChipWrapper(),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Select Services",
                    style: TextStyle(
                        color: Color.fromARGB(255, 45, 42, 42),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Consumer<ApiConfigService>(
                    builder: (context, apiConfig, child) {
                      if (!apiConfig.firebaseEnabled) {
                        return _buildOfflineServicesList();
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('services')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return _buildErrorServicesList(
                                snapshot.error.toString());
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildLoadingServicesList();
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _buildEmptyServicesList();
                          }

                          return SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                final doc = snapshot.data!.docs[index];
                                return GestureDetector(
                                  onTap: () => onClick(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.elasticIn,
                                    margin: const EdgeInsets.only(right: 12.0),
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        border: (index == selectedIndex)
                                            ? Border.all(
                                                width: 3,
                                                color: const Color(0xff721c80),
                                              )
                                            : Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14)),
                                          child: Image.network(
                                            doc["img"] ?? "",
                                            height: 60,
                                            width: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 60,
                                                width: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          doc["name"] ?? "Servicio",
                                          style: const TextStyle(
                                            color: Color(0xff721c80),
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "₹${doc["price"] ?? "0"}",
                                          style: const TextStyle(
                                            color: Color(0xff721c80),
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const Spacer()
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Consumer<ApiConfigService>(
              builder: (context, apiConfig, child) {
                return GestureDetector(
                  onTap: apiConfig.firebaseEnabled
                      ? () => _handleBooking(context)
                      : () => _showOfflineBookingDialog(context),
                  child: Container(
                    margin: const EdgeInsets.only(left: 18, right: 18),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: apiConfig.firebaseEnabled
                          ? const Color(0xff721c80)
                          : Colors.grey,
                      gradient: apiConfig.firebaseEnabled
                          ? const LinearGradient(
                              colors: [
                                Color(0xff721c80),
                                Color.fromARGB(255, 196, 103, 169),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: Center(
                        child: Text(
                      apiConfig.firebaseEnabled
                          ? "Reservar cita"
                          : "Modo sin conexión",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChipWrapper extends StatelessWidget {
  const ChipWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Chip(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide()),
          label: const Text("10:00 AM"),
          backgroundColor: Colors.white,
        ),
        Chip(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide()),
          label: const Text("10:00 AM"),
          backgroundColor: Colors.white,
        ),
        Chip(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide()),
          label: const Text("10:00 AM"),
          backgroundColor: Colors.white,
        ),
      ],
    );
  }
}

// ElevatedButton(
//     onPressed: () async {
//       var snap = FirebaseFirestore.instance.collection('workers');
//       List data = [];
//       snap.doc('G9ZvAbTR9HvoiMChKrTA').get().then((value) {
//         setState(() {
//           print('snap');
//           print(value["booked"]);
//           data = value["booked"];
//           print(data);
//           data.add('value10');
//         });
//       }).then((value) => snap
//           .doc('G9ZvAbTR9HvoiMChKrTA')
//           .update({
//             'booked': data,
//           }) // <-- Updated data
//           .then((_) => print('Success'))
//           .catchError((error) => print('Failed: $error')));
//     },
//     child: Text("Book"))
