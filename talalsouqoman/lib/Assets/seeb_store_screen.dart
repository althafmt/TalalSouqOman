import 'package:talalsouqoman/imports.dart';

class SeebStoreScreen extends StatefulWidget {
  const SeebStoreScreen({super.key});

  @override
  State<SeebStoreScreen> createState() => _SeebStoreScreenState();
}

class _SeebStoreScreenState extends State<SeebStoreScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _assets = [];
  Map<String, List<Map<String, dynamic>>> _groupedAssets = {};

  String _place = 'Seeb Store';
  String _type = 'Laptop';
  String _connectedDeviceName = '';
  String _brand = '';
  String _model = '';
  String _serialImei = '';
  String _assignedTo = '';
  String _department = '';

  @override
  void initState() {
    super.initState();
    _fetchUserPrivilege();
    _fetchAssets();
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
        _isAdmin = response['privilege'] == 'admin';
      });
    } catch (e) {
      _showSnackBar('Error fetching user privilege: $e');
    }
  }

  Future<void> _fetchAssets() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('SeebStoreassets').select();
      setState(() {
        _assets = List<Map<String, dynamic>>.from(response);
        _groupAssets();
      });
    } catch (e) {
      _showSnackBar('Error fetching assets: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _groupAssets() {
    _assets.sort((a, b) => (a['connected_device_name'] ?? '').compareTo(b['connected_device_name'] ?? ''));
    _groupedAssets = {};
    for (var asset in _assets) {
      final deviceName = asset['connected_device_name'] ?? 'Unknown';
      _groupedAssets.putIfAbsent(deviceName, () => []).add(asset);
    }
  }

  Future<void> _addAsset() async {
    if (!_isAdmin) {
      _showSnackBar('Only admins can add assets.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _supabase.from('SeebStoreassets').insert({
        'place': _place,
        'type': _type,
        'connected_device_name': _connectedDeviceName,
        'brand': _brand,
        'model': _model,
        'serial_imei': _serialImei,
        'assigned_to': _assignedTo,
        'department': _department,
        'created_at': DateTime.now().toIso8601String(),
      });
      _showSnackBar('Asset added successfully!');
      _fetchAssets();
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error adding asset: $e');
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
        title: const Text("Seeb Store Assets"),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAssets)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedAssets.isEmpty
          ? const Center(child: Text("No assets found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _groupedAssets.keys.length,
        itemBuilder: (context, index) {
          final deviceName = _groupedAssets.keys.elementAt(index);
          final assetsForDevice = _groupedAssets[deviceName]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  deviceName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...assetsForDevice.map((asset) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: const Icon(Icons.devices, color: Colors.blueAccent),
                    title: Text("${asset['id']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Type : ${asset['type'] ?? 'N/A'}"),
                        Text("Model : ${asset['model'] ?? 'N/A'}"),
                        Text("Assigned To : ${asset['assigned_to'] ?? 'N/A'}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showAssetInfoDialog(asset),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (context) => _buildAddAssetDialog()),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      )
          : null,
    );
  }

  Widget _buildAddAssetDialog() {
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
                const Text("Add New Asset",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                const SizedBox(height: 16),
                _buildDropdown('Place', _place, [
                  'Seeb Store',
                ], (val) => setState(() => _place = val)),

                const SizedBox(height: 16),
                _buildDropdown('Type', _type, [
                  'Laptop',
                  'Monitor',
                  'CPU',
                  'Keyboard',
                  'Mouse',
                  'Server',
                  'Firewall',
                  'Switch',
                  'Fingerprint Scanner',
                  'Modem'
                ], (val) => setState(() => _type = val)),
                _buildTextField('Connected Device Name', (val) => _connectedDeviceName = val),
                _buildTextField('Brand', (val) => _brand = val, required: true),
                _buildTextField('Model', (val) => _model = val, required: true),
                _buildTextField('Serial/IMEI', (val) => _serialImei = val, required: true),
                _buildTextField('Assigned To', (val) => _assignedTo = val),
                _buildTextField('Department', (val) => _department = val),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addAsset,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Add Asset'),
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

  void _showAssetInfoDialog(Map<String, dynamic> asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Asset Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${asset['id']}", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Type: ${asset['type']}"),
              Text("Connected Device: ${asset['connected_device_name']}"),
              Text("Brand: ${asset['brand']}"),
              Text("Model: ${asset['model']}"),
              Text("Serial/IMEI: ${asset['serial_imei']}"),
              Text("Assigned To: ${asset['assigned_to']}"),
              Text("Department: ${asset['department']}"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      Function(String) onChanged, {
        bool required = false,
      }) {
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

  Widget _buildDropdown(
      String label,
      String currentValue,
      List<String> options,
      Function(String) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        value: currentValue,
        items: options
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => value != null ? onChanged(value) : null,
      ),
    );
  }

}
