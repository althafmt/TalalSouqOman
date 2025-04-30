import 'package:talalsouqoman/imports.dart';


class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isAdminOrManager = false;
  List<Map<String, dynamic>> _drivers = [];

  String _driverName = '';
  String _route = '';
  String _phone = '';
  String _oid = '';
  String _page = '';

  @override
  void initState() {
    super.initState();
    _fetchUserPrivilege();
    _fetchDrivers();
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

  Future<void> _fetchDrivers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('drivers').select();
      setState(() {
        _drivers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showSnackBar('Error fetching drivers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addDriver() async {
    if (!_isAdminOrManager) {
      _showSnackBar('Only admins can add drivers.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _supabase.from('drivers').insert({
        'driver_name': _driverName,
        'route': _route,
        'phone': _phone,
        'oid': _oid,
        'page': _page,
        'created_at': DateTime.now().toIso8601String(),
      });
      _showSnackBar('Driver added successfully!');
      _fetchDrivers();
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error adding driver: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drivers"),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchDrivers)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drivers.isEmpty
          ? const Center(child: Text("No Drivers found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _drivers.length,
        itemBuilder: (context, index) {
          final driver = _drivers[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${driver['driver_name']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Route: ${driver['route'] ?? 'N/A'}"),
                Text("Phone: ${driver['phone'] ?? 'N/A'}"),
                Text("OID: ${driver['oid'] ?? 'N/A'}"),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calculate),
                      label: const Text('Wages'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WageCalculatorPage(driver: driver),
                          ),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.payment),
                      label: const Text('Payments'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentListPage(driver: driver),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },

      ),
      floatingActionButton: _isAdminOrManager
          ? FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (context) => _buildAddDriverDialog()),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      )
          : null,
    );
  }

  Widget _buildAddDriverDialog() {
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
                const Text("Add New Driver", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField('Driver Name', (val) => _driverName = val, required: true),
                _buildTextField('Route', (val) => _route = val, required: true),
                _buildTextField('Phone', (val) => _phone = val, required: true),
                _buildTextField('OID', (val) => _oid = val, required: true),
                // _buildTextField('Page Label', (val) => _page = val, required: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addDriver,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Add Driver'),
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

  Widget _buildTextField(String label, Function(String) onChanged, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => required && (value == null || value.isEmpty)
            ? 'This field is required'
            : null,
        onChanged: onChanged,
      ),
    );
  }
}
