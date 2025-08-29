import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_app/services/api_config_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _googleMapsController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final apiConfig = context.read<ApiConfigService>();
    _googleMapsController.text = apiConfig.googleMapsApiKey ?? '';
  }

  @override
  void dispose() {
    _googleMapsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xff721c80),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ApiConfigService>(
        builder: (context, apiConfig, child) {
          final configStatus = apiConfig.getConfigurationStatus();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Claves de API'),
                const SizedBox(height: 16),

                // Google Maps API Key Section
                _buildApiKeySection(
                  context,
                  title: 'Google Maps API Key',
                  controller: _googleMapsController,
                  isConfigured: configStatus['googleMapsConfigured'],
                  onSave: () => _saveGoogleMapsApiKey(context),
                  onTest: () => _testGoogleMapsApiKey(context),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Servicios'),
                const SizedBox(height: 16),

                // Firebase Toggle
                _buildServiceToggle(
                  context,
                  title: 'Firebase',
                  subtitle:
                      'Habilitar servicios de Firebase (Autenticación, Base de datos)',
                  value: configStatus['firebaseEnabled'],
                  onChanged: (value) => _toggleFirebase(context, value),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Estado del Sistema'),
                const SizedBox(height: 16),

                // System Status Cards
                _buildStatusCard(
                  title: 'Google Maps',
                  status: configStatus['googleMapsConfigured']
                      ? 'Configurado'
                      : 'No configurado',
                  statusColor: configStatus['googleMapsConfigured']
                      ? Colors.green
                      : Colors.orange,
                  icon: Icons.map,
                ),

                const SizedBox(height: 12),

                _buildStatusCard(
                  title: 'Firebase',
                  status: configStatus['firebaseEnabled']
                      ? 'Habilitado'
                      : 'Deshabilitado',
                  statusColor: configStatus['firebaseEnabled']
                      ? Colors.green
                      : Colors.red,
                  icon: Icons.cloud,
                ),

                const SizedBox(height: 24),

                // Reset to Defaults
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Restablecer Configuración',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Esto restablecerá todas las configuraciones a sus valores predeterminados.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showResetConfirmation(context),
                          icon: const Icon(Icons.restore),
                          label: const Text('Restablecer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xff721c80),
      ),
    );
  }

  Widget _buildApiKeySection(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required bool isConfigured,
    required VoidCallback onSave,
    required VoidCallback onTest,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isConfigured ? Icons.check_circle : Icons.warning,
                  color: isConfigured ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                labelText: 'Clave de API',
                hintText: 'Ingrese su clave de API',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff721c80),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTest,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Probar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xff721c80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xff721c80),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGoogleMapsApiKey(BuildContext context) async {
    final apiConfig = context.read<ApiConfigService>();
    final apiKey = _googleMapsController.text.trim();

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese una clave de API válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await apiConfig.updateGoogleMapsApiKey(apiKey);
    if (mounted) {
      if (success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clave de API guardada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la clave de API'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testGoogleMapsApiKey(BuildContext context) async {
    final apiKey = _googleMapsController.text.trim();

    if (apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingrese una clave de API para probar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Simple validation - check if it looks like a valid API key format
    if (apiKey.length < 20 || !apiKey.contains('AIza')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El formato de la clave de API no parece válido'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clave de API validada (formato correcto)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleFirebase(BuildContext context, bool value) async {
    final apiConfig = context.read<ApiConfigService>();
    final success = await apiConfig.toggleFirebase(value);

    if (mounted) {
      if (success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Firebase habilitado. Reinicie la aplicación para aplicar los cambios.'
                  : 'Firebase deshabilitado. La aplicación funcionará en modo limitado.',
            ),
            backgroundColor: value ? Colors.green : Colors.orange,
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar la configuración de Firebase'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Restablecimiento'),
        content: const Text(
          '¿Está seguro de que desea restablecer todas las configuraciones a sus valores predeterminados? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiConfig = context.read<ApiConfigService>();
              await apiConfig.resetToDefaults();
              _googleMapsController.clear();

              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Configuración restablecida a valores predeterminados'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }
}
