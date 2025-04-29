import 'package:talalsouqoman/imports.dart';
import 'package:intl/intl.dart';

class VehiclesSDetails extends StatefulWidget {
  const VehiclesSDetails({super.key});

  @override
  State<VehiclesSDetails> createState() => _VehiclesSDetailsState();
}

class _VehiclesSDetailsState extends State<VehiclesSDetails> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isAdminOrManager = false;
  List<Map<String, dynamic>> _vehicles = [];
  List<String> _insuranceNotifications = []; // List to store notifications

  String _model = '';
  String _year = '';
  String _plateNumber = '';
  String _chassisNumber = '';
  DateTime? _insuranceExpiryDate;

  @override
  void initState() {
    super.initState();
    _fetchUserPrivilege();
    _fetchVehiclesAndCheckExpiry();
  }

  Future<void> _fetchUserPrivilege() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('users')
          .select('privilege')
          .eq('userid', user.id)
          .single();

      setState(() {
        _isAdminOrManager =
            response['privilege'] == 'admin' || response['privilege'] == 'manager';
      });
    } catch (e) {
      _showSnackBar('Error fetching user privilege: $e');
    }
  }

  Future<void> _fetchVehiclesAndCheckExpiry() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('vehicles').select();
      final List<Map<String, dynamic>> fetchedVehicles =
      List<Map<String, dynamic>>.from(response);

      setState(() {
        _vehicles = fetchedVehicles;
        _insuranceNotifications.clear(); // Clear previous notifications
      });

      _checkInsuranceExpiry(fetchedVehicles);
    } catch (e) {
      _showSnackBar('Error fetching vehicles: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkInsuranceExpiry(List<Map<String, dynamic>> vehicles) {
    final now = DateTime.now();
    final expiryThreshold = now.add(const Duration(days: 30));

    for (final vehicle in vehicles) {
      final expiryDateString = vehicle['insurance_expiry_date'];
      if (expiryDateString != null) {
        try {
          final expiryDate = DateTime.parse(expiryDateString);
          if (expiryDate.isBefore(expiryThreshold) && expiryDate.isAfter(now)) {
            _addNotification(
                'Reminder: Insurance for vehicle "${vehicle['model']}" (Plate: ${vehicle['plate_number']}) expires soon on ${DateFormat('yyyy-MM-dd').format(expiryDate)}!');
          } else if (expiryDate.isBefore(now)) {
            _addNotification(
                'Alert: Insurance for vehicle "${vehicle['model']}" (Plate: ${vehicle['plate_number']}) expired on ${DateFormat('yyyy-MM-dd').format(expiryDate)}!');
          }
        } catch (e) {
          print('Error parsing insurance expiry date for vehicle ${vehicle['model']}: $e');
        }
      }
    }
  }

  void _addNotification(String message) {
    setState(() {
      _insuranceNotifications.add(message);
    });
  }

  Future<void> _addVehicle() async {
    if (!_isAdminOrManager) {
      _showSnackBar('Only admins and managers can add vehicles.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _supabase.from('vehicles').insert({
        'model': _model,
        'year': _year,
        'plate_number': _plateNumber,
        'chassis_number': _chassisNumber,
        'insurance_expiry_date': _insuranceExpiryDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      _showSnackBar('Vehicle added successfully!');
      _fetchVehiclesAndCheckExpiry();
      Navigator.pop(context);
      _resetForm();
    } catch (e) {
      _showSnackBar('Error adding vehicle: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _model = '';
      _year = '';
      _plateNumber = '';
      _chassisNumber = '';
      _insuranceExpiryDate = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Vehicles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVehiclesAndCheckExpiry,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(
                    notifications: _insuranceNotifications, // Pass the notifications
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
          ? const Center(child: Text("No vehicles found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return VehicleCard(
            vehicle: vehicle,
            onPressed: () => _showVehicleInfoDialog(vehicle),
          );
        },
      ),
      floatingActionButton: _isAdminOrManager
          ? FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => _buildAddVehicleDialog(),
        ),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      )
          : null,
    );
  }

  Widget _buildAddVehicleDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Vehicle",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField('Model', (val) => _model = val, required: true),
                _buildTextField('Year', (val) => _year = val, required: true),
                _buildTextField(
                    'Plate Number', (val) => _plateNumber = val,
                    required: true),
                _buildTextField(
                    'Chassis Number', (val) => _chassisNumber = val,
                    required: true),
                _buildDatePicker(
                    'Insurance Expiry Date',
                        (DateTime? date) =>
                        setState(() => _insuranceExpiryDate = date)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addVehicle,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Add Vehicle'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => required && (value == null || value.isEmpty)
            ? 'This field is required'
            : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(String label, Function(DateTime?) onDateSelected) {
    final TextEditingController controller = TextEditingController(
      text: _insuranceExpiryDate != null
          ? DateFormat('yyyy-MM-dd').format(_insuranceExpiryDate!)
          : '',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: _insuranceExpiryDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            onDateSelected(pickedDate);
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      ),
    );
  }

  void _showVehicleInfoDialog(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle['model'] ?? 'Vehicle Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Model:', vehicle['model']),
              _buildInfoRow('Year:', vehicle['year']),
              _buildInfoRow('Plate Number:', vehicle['plate_number']),
              _buildInfoRow('Chassis Number:', vehicle['chassis_number']),
              _buildInfoRow(
                  'Insurance Expiry:',
                  vehicle['insurance_expiry_date'] != null
                      ? DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(vehicle['insurance_expiry_date']))
                      : 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onPressed;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: const CircleAvatar(
          child: Icon(Icons.directions_car),
          radius: 20,
        ),
        title: Text(
          vehicle['model'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Year: ${vehicle['year'] ?? 'N/A'}"),
            Text("Plate: ${vehicle['plate_number'] ?? 'N/A'}"),
            if (vehicle['insurance_expiry_date'] != null)
              Text(
                "Expiry: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(vehicle['insurance_expiry_date']))}",
                style: DateTime.parse(vehicle['insurance_expiry_date'])
                    .isBefore(DateTime.now())
                    ? const TextStyle(color: Colors.red) // Highlight expired
                    : DateTime.parse(vehicle['insurance_expiry_date'])
                    .isBefore(DateTime.now().add(const Duration(days: 30)))
                    ? const TextStyle(color: Colors.orange) // Highlight expiring soon
                    : null,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: onPressed,
        ),
      ),
    );
  }
}