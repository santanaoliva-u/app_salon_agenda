import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_app/components/date_picker.dart';
import 'package:salon_app/services/config_service.dart';
import 'package:salon_app/services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  /// Index of the currently selected service in the list
  int selectedIndex = 0;

  /// Global key for form validation
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _notesController = TextEditingController();

  // Selected service data
  String? _selectedServiceId;
  String? _selectedServiceName;
  String? _selectedWorkerId;
  String? _selectedWorkerName;
  DateTime? _selectedDateTime;

  bool _isBooking = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void onClick(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _onServiceSelected(String serviceId, String serviceName) {
    setState(() {
      _selectedServiceId = serviceId;
      _selectedServiceName = serviceName;
    });
  }

  void _onDateTimeSelected(DateTime dateTime) {
    setState(() {
      _selectedDateTime = dateTime;
    });
  }

  /// Builds a widget to display when Firebase is not available
  ///
  /// This widget shows an offline indicator with appropriate messaging
  /// and visual cues to inform the user about the connectivity status.
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

  /// Builds a widget to display when there's an error loading services
  ///
  /// Shows an error message with the specific error details and
  /// provides visual feedback about the problem.
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

  /// Builds a loading widget with skeleton placeholders
  ///
  /// Shows animated placeholders that match the structure of the actual
  /// service list to provide better user experience during loading.
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

  /// Builds a widget to display when no services are available
  ///
  /// Shows an appropriate message and icon when the services collection
  /// is empty or when no services match the current filters.
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

  /// Handles the booking process with comprehensive validation and error handling
  ///
  /// This method performs the following steps:
  /// 1. Validates the form data (name, phone, email)
  /// 2. Checks that required selections are made (service, worker, time)
  /// 3. Validates booking data using the booking service
  /// 4. Checks slot availability to prevent double bookings
  /// 5. Creates the booking in Firestore
  /// 6. Shows appropriate success/error messages
  /// 7. Resets the form on successful booking
  ///
  /// Error handling includes:
  /// - Form validation errors
  /// - Missing selections
  /// - Slot availability conflicts
  /// - Network/API errors
  /// - Authentication issues
  Future<void> _handleBooking(BuildContext context) async {
    // Step 1: Validate form data
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required selections
    if (_selectedServiceId == null ||
        _selectedWorkerId == null ||
        _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona servicio, trabajador y horario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Validate booking data
      final validationError = bookingService.validateBookingData(
        serviceId: _selectedServiceId!,
        workerId: _selectedWorkerId!,
        dateTime: _selectedDateTime!,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
      );

      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check slot availability
      final isAvailable = await bookingService.isSlotAvailable(
        _selectedWorkerId!,
        _selectedDateTime!,
      );

      if (!context.mounted) return;

      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este horario ya no está disponible'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create booking
      final success = await bookingService.createBooking(
        serviceId: _selectedServiceId!,
        serviceName: _selectedServiceName!,
        workerId: _selectedWorkerId!,
        workerName: _selectedWorkerName!,
        dateTime: _selectedDateTime!,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        customerEmail: _customerEmailController.text.trim().isNotEmpty
            ? _customerEmailController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (!context.mounted) return;

      if (success) {
        // Clear form
        _formKey.currentState!.reset();
        _customerNameController.clear();
        _customerPhoneController.clear();
        _customerEmailController.clear();
        _notesController.clear();
        setState(() {
          _selectedServiceId = null;
          _selectedServiceName = null;
          _selectedWorkerId = null;
          _selectedWorkerName = null;
          _selectedDateTime = null;
          selectedIndex = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reserva realizada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la reserva. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
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
              child: Padding(
                padding: const EdgeInsets.only(top: 38, left: 18, right: 18),
                child: Column(
                  children: [
                    const Row(
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
                    CustomDatePicker(
                      onDateSelected: (date) {
                        // For now, just select the date at 9 AM as default
                        final dateTime =
                            DateTime(date.year, date.month, date.day, 9, 0);
                        _onDateTimeSelected(dateTime);
                      },
                    ),
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
                  Consumer<ConfigService>(
                    builder: (context, config, child) {
                      if (!config.firebaseEnabled) {
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
                                  onTap: () {
                                    onClick(index);
                                    _onServiceSelected(
                                        doc.id, doc["name"] ?? "Servicio");
                                  },
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

            // Customer Information Form
            /// Formulario para recopilar información del cliente
            ///
            /// Incluye validación completa para:
            /// - Nombre: requerido, mínimo 2 caracteres
            /// - Teléfono: requerido, formato válido
            /// - Email: opcional, formato válido si se proporciona
            /// - Notas: opcional, sin validación específica
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Información del Cliente",
                      style: TextStyle(
                        color: Color.fromARGB(255, 45, 42, 42),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customer Name - Campo requerido con validación básica
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.trim().length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Customer Phone - Campo requerido con validación de formato
                    TextFormField(
                      controller: _customerPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: '+1234567890',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El teléfono es requerido';
                        }
                        if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                          return 'Formato de teléfono inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Customer Email - Campo opcional con validación de formato
                    TextFormField(
                      controller: _customerEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        hintText: 'cliente@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Formato de email inválido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes - Campo opcional sin validación específica
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas adicionales (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        hintText: 'Alergias, preferencias especiales...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            Consumer<ConfigService>(
              builder: (context, config, child) {
                return GestureDetector(
                  onTap: _isBooking || !config.firebaseEnabled
                      ? null
                      : () => _handleBooking(context),
                  child: Container(
                    margin:
                        const EdgeInsets.only(left: 18, right: 18, bottom: 20),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _isBooking
                          ? Colors.grey
                          : config.firebaseEnabled
                              ? const Color(0xff721c80)
                              : Colors.grey,
                      gradient: _isBooking || !config.firebaseEnabled
                          ? null
                          : const LinearGradient(
                              colors: [
                                Color(0xff721c80),
                                Color.fromARGB(255, 196, 103, 169),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    ),
                    child: Center(
                      child: _isBooking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              config.firebaseEnabled
                                  ? "Reservar cita"
                                  : "Modo sin conexión",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
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
