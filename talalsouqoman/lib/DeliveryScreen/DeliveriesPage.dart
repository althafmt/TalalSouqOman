import 'package:talalsouqoman/imports.dart';
import 'package:intl/intl.dart';

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});

  @override
  _DeliveriesPageState createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  final _supabase = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _deliveries = [];
  bool _isAdminOrManager = false;

  // Form controllers
  final _routeController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _startKmController = TextEditingController();
  final _endKmController = TextEditingController();
  final _totalBillsController = TextEditingController();
  final _helper1Controller = TextEditingController();
  final _helper2Controller = TextEditingController();

  // Form variables
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _vehicles = [];
  int? _selectedDriverId;
  int? _selectVehicleId;
  String? _editingDeliveryId; // Changed to String

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
    _fetchDrivers();
    _fetchVehicles();
    _checkAdminStatus();
  }

  @override
  void dispose() {
    _routeController.dispose();
    _vehicleController.dispose();
    _startKmController.dispose();
    _endKmController.dispose();
    _totalBillsController.dispose();
    _helper1Controller.dispose();
    _helper2Controller.dispose();
    super.dispose();
  }

  Future<void> _fetchDeliveries() async {
    try {
      final response = await _supabase
          .from('deliveries')
          .select('*, drivers(driver_name)')
          .order('date', ascending: false);

      setState(() {
        _deliveries = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      _showErrorSnackbar("Failed to load deliveries: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchDrivers() async {
    try {
      final response = await _supabase
          .from('drivers')
          .select('id, driver_name')
          .order('driver_name', ascending: true);

      setState(() => _drivers = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      _showErrorSnackbar("Failed to load drivers: $e");
    }
  }

  Future<void> _fetchVehicles() async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select('id, model, plate_number')
          .order('plate_number', ascending: true);

      setState(() => _vehicles = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      _showErrorSnackbar("Failed to load drivers: $e");
    }
  }

  Future<void> _checkAdminStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

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
      setState(() => _loading = false);
    }
  }

  Future<void> _submitStartingDetails() async {
    if (_selectedDate == null ||
        _startTime == null ||
        _selectedDriverId == null ||
        _selectVehicleId == null ||
        _routeController.text.isEmpty ||
        double.tryParse(_startKmController.text) == null) {
      _showErrorSnackbar("Please fill all required Starting fields.");
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      _showErrorSnackbar('User not logged in');
      return;
    }

    try {
      final response = await _supabase.from('deliveries').insert({
        'date': _selectedDate!.toIso8601String(),
        'route': _routeController.text,
        'vehicle': _vehicleController.text,
        'start_km': double.parse(_startKmController.text),
        'total_bills': double.tryParse(_totalBillsController.text) ?? 0.0,
        'start_time': _startTime!.format(context),
        'driver_id': _selectedDriverId,
        'vehicle_id' : _selectVehicleId,
        'helper1': _helper1Controller.text,
        'helper2': _helper2Controller.text,
        'created_by': user.id,
        'is_completed': false,
      }).select();

      _showSuccessSnackbar('Starting details added successfully');
      setState(() => _deliveries.insert(0, response.first));
      _resetForm();
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackbar("Failed to add Starting details: $e");
    }
  }

  Future<void> _submitEndingDetails(String deliveryId) async { // Changed to String
    if (_endTime == null ||
        _endKmController.text.isEmpty ||
        double.tryParse(_endKmController.text) == null ||
        double.parse(_endKmController.text) <= double.parse(_startKmController.text)) {
      _showErrorSnackbar("Please enter valid Ending details with End KM greater than Start KM");
      return;
    }

    try {
      await _supabase.from('deliveries').update({
        'end_time': _endTime!.format(context),
        'end_km': double.parse(_endKmController.text),
        'is_completed': true,
      }).eq('id', deliveryId); // Use String

      _showSuccessSnackbar('Ending details updated successfully');
      await _fetchDeliveries();
      _resetForm();
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackbar("Failed to update Ending details: $e");
    }
  }

  void _resetForm() {
    _routeController.clear();
    _vehicleController.clear();
    _startKmController.clear();
    _endKmController.clear();
    _totalBillsController.clear();
    _helper1Controller.clear();
    _helper2Controller.clear();
    setState(() {
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
      _selectedDriverId = null;
      _selectVehicleId = null;
      _editingDeliveryId = null;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Deliveries")),
      body: _deliveries.isEmpty
          ? const Center(child: Text("No deliveries found"))
          : RefreshIndicator(
        onRefresh: _fetchDeliveries,
        child: ListView.builder(
          itemCount: _deliveries.length,
          itemBuilder: (context, index) {
            final delivery = _deliveries[index];
            return _buildDeliveryCard(delivery);
          },
        ),
      ),
      floatingActionButton: _isAdminOrManager
          ? FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    final driverName = delivery['drivers']?['driver_name']?.toString() ?? 'Unknown';
    final distance = delivery['end_km'] != null
        ? (double.parse(delivery['end_km'].toString()) - double.parse(delivery['start_km'].toString())).toStringAsFixed(1)
        : 'N/A';
    final formattedDate = delivery['date'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(delivery['date'].toString()))
        : 'Unknown date';
    final isCompleted = delivery['is_completed'] ?? false;
    final incompleteCount = _deliveries.where((d) => !(d['is_completed'] ?? false)).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _showDeliveryDetails(delivery),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    delivery['route']?.toString() ?? 'No route',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCompleted ? Colors.black : Colors.orange,
                    ),
                  ),
                  if (_isAdminOrManager && !isCompleted)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showAddEndingDetailsDialog(context, delivery),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Driver: $driverName'),
              Text('Date: $formattedDate'),
              if (delivery['helper1'] != null || delivery['helper2'] != null)
                Text('Helpers: ${[delivery['helper1']?.toString(), delivery['helper2']?.toString()].where((h) => h != null).join(', ')}'),
              Text('Distance: ${distance}km'),
              Text('Bills: ${(double.tryParse(delivery['total_bills']?.toString() ?? '0') ?? 0).toStringAsFixed(0)}'),
              if (!isCompleted)
                Text(
                  'Status: Pending Ending Details',
                  style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    final incompleteCount = _deliveries.where((d) => !(d['is_completed'] ?? false)).length;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Delivery Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.wb_sunny_outlined),
                  label: const Text("Add Starting Details"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddStartingDetailsDialog(context);
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.nightlight_round_outlined),
                  label: Text("Add Ending Details (${incompleteCount > 0 ? incompleteCount : 'No'} pending)"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: incompleteCount > 0 ? null : Colors.grey,
                  ),
                  onPressed: incompleteCount > 0
                      ? () {
                    Navigator.pop(context);
                    _showSelectDeliveryForEndingDialog(context);
                  }
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSelectDeliveryForEndingDialog(BuildContext context) async {
    final incompleteDeliveries = _deliveries.where((d) => !(d['is_completed'] ?? false)).toList();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Delivery to Complete"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: incompleteDeliveries.length,
              itemBuilder: (context, index) {
                final delivery = incompleteDeliveries[index];
                final driverName = delivery['drivers']?['driver_name']?.toString() ?? 'Unknown';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(delivery['route']?.toString() ?? 'No route'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(driverName),
                        Text(DateFormat('MMM dd, yyyy').format(DateTime.parse(delivery['date'].toString()))), // Changed date format
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddEndingDetailsDialog(context, delivery);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showDeliveryDetails(Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delivery Details - ${delivery['route']?.toString()}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow("Date", DateFormat('MMM dd, yyyy').format(DateTime.parse(delivery['date'].toString()))), // Changed date format
              _buildDetailRow("Driver", delivery['drivers']?['driver_name']?.toString() ?? 'Unknown'),
              _buildDetailRow("Start Time", delivery['start_time']?.toString()),
              if (delivery['end_time'] != null) _buildDetailRow("End Time", delivery['end_time']?.toString()),
              _buildDetailRow("Start KM", delivery['start_km']?.toString()),
              if (delivery['end_km'] != null) _buildDetailRow("End KM", delivery['end_km']?.toString()),
              if (delivery['end_km'] != null)
                _buildDetailRow("Distance",
                    (double.parse(delivery['end_km'].toString()) - double.parse(delivery['start_km'].toString())).toStringAsFixed(1) + " km"),
              _buildDetailRow("Vehicle", delivery['vehicles']?['plate_number']?.toString() ?? 'Unknown'),
              _buildDetailRow("Total Bills", "${(double.tryParse(delivery['total_bills']?.toString() ?? '0') ?? 0).toStringAsFixed(0)}"),
              if (delivery['helper1'] != null) _buildDetailRow("Helper 1", delivery['helper1']?.toString()),
              if (delivery['helper2'] != null) _buildDetailRow("Helper 2", delivery['helper2']?.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  Future<void> _showAddStartingDetailsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Starting Details"),
              content: SingleChildScrollView(
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDatePicker(setState),
                      const SizedBox(height: 12),
                      _buildVehicleDropdown(setState),
                      const SizedBox(height: 12),
                      _buildNumberField(_startKmController, "Start KM*", isRequired: true),
                      const SizedBox(height: 12),
                      _buildNumberField(_totalBillsController, "Total Bills"),
                      const SizedBox(height: 12),
                      _buildTimePicker("Start Time*", _startTime, (time) => setState(() => _startTime = time)),
                      const SizedBox(height: 12),
                      _buildDriverDropdown1(setState),
                      const SizedBox(height: 12),
                      _buildTextField(_helper1Controller, "Helper 1"),
                      const SizedBox(height: 12),
                      _buildTextField(_helper2Controller, "Helper 2"),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _resetForm();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => _submitStartingDetails(),
                  child: const Text("Submit Starting Details"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddEndingDetailsDialog(BuildContext context, Map<String, dynamic> delivery) async {
    // Ensure the delivery ID is a String
    final deliveryId = delivery['id'].toString();

    if (deliveryId == null || deliveryId.isEmpty) {
      _showErrorSnackbar("Invalid delivery ID received.");
      return;
    }
    // Pre-fill the form with existing Starting details
    _editingDeliveryId = deliveryId;
    _selectedDate = delivery['date'] != null ? DateTime.parse(delivery['date'].toString()) : null;
    _routeController.text = delivery['route']?.toString() ?? '';
    _startKmController.text = (delivery['start_km'] ?? 0.0).toString();
    _totalBillsController.text = (delivery['total_bills'] ?? 0.0).toString();
    _helper1Controller.text = delivery['helper1']?.toString() ?? '';
    _helper2Controller.text = delivery['helper2']?.toString() ?? '';
    _selectedDriverId = int.tryParse(delivery['driver_id'].toString());
    _selectVehicleId = int.tryParse(delivery['vehicle_id'].toString());

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Ending Details"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Route: ${delivery['route']?.toString()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Date: ${_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'N/A'}'),
                    Text('Start KM: ${(delivery['start_km'] ?? 0.0).toString()}'),
                    const SizedBox(height: 16),
                    _buildNumberField(_endKmController, "End KM*", isRequired: true),
                    const SizedBox(height: 12),
                    _buildTimePicker("End Time*", _endTime, (time) => setState(() => _endTime = time)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _resetForm();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_editingDeliveryId != null) {
                      _submitEndingDetails(_editingDeliveryId!); // Pass String
                    } else {
                      _showErrorSnackbar("Delivery ID is missing. Please try again.");
                    }
                  },
                  child: const Text("Submit Ending Details"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDatePicker(StateSetter setState) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Text(
        _selectedDate == null
            ? "Pick Date*"
            : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isRequired ? '*' : ''),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label + (isRequired ? '*' : ''),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, Function(TimeOfDay?) onTimeSelected) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) onTimeSelected(picked);
      },
      child: Text(
        time == null ? "$label*" : '$label: ${time.format(context)}',
      ),
    );
  }

  Widget _buildDriverDropdown1(StateSetter setState) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Driver*',
        border: OutlineInputBorder(),
      ),
      value: _selectedDriverId,
      onChanged: (int? newValue) => setState(() => _selectedDriverId = newValue),
      items: _drivers.map<DropdownMenuItem<int>>((driver) {
        return DropdownMenuItem<int>(
          value: int.tryParse(driver['id'].toString()),
          child: Text(driver['driver_name'].toString()),
        );
      }).toList(),
    );
  }

  Widget _buildVehicleDropdown(StateSetter setState) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Vehicle*',
        border: OutlineInputBorder(),
      ),
      value: _selectVehicleId,
      onChanged: (int? newValue) => setState(() => _selectVehicleId = newValue),
      items: _vehicles.map<DropdownMenuItem<int>>((vehicle) {
        return DropdownMenuItem<int>(
          value: int.tryParse(vehicle['id'].toString()),
          child: Text('${vehicle['model'].toString()} - ${vehicle['plate_number'].toString()}'),
        );
      }).toList(),
    );
  }

}