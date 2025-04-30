import 'package:talalsouqoman/imports.dart';

class VisaEmployeesScreen extends StatefulWidget {
  const VisaEmployeesScreen({super.key});

  @override
  State<VisaEmployeesScreen> createState() => _VisaEmployeesScreenState();
}

class _VisaEmployeesScreenState extends State<VisaEmployeesScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isAdminOrManager = false;
  List<Map<String, dynamic>> _employees = [];

  String _name = '';
  String _position = '';
  String _department = '';
  String _email = '';
  String _phone = '';
  String _passportNumber = '';
  String _visaType = 'Visa'; // Default to Visa
  String _visaStatus = '';
  File? _employeePhoto;

  @override
  void initState() {
    super.initState();
    _fetchUserPrivilege();
    _fetchEmployees();
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

  // Fetch only employees with visa_type = 'Visa'
  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('employees')
          .select('*')
          .eq('visa_type', 'Visa'); // Only fetch Visa employees


    } catch (e) {
      _showSnackBar('Error fetching employees: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addEmployee() async {
    if (!_isAdminOrManager) {
      _showSnackBar('Only admins can add employees.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? photoUrl;

      if (_employeePhoto != null) {
        final fileName = 'employee_photos/${DateTime.now().millisecondsSinceEpoch}.png';
        await _supabase.storage
            .from('employee-photos')
            .upload(fileName, _employeePhoto!);

        photoUrl = _supabase.storage.from('employee-photos').getPublicUrl(fileName);
      }

      await _supabase.from('employees').insert({
        'name': _name,
        'position': _position,
        'department': _department,
        'email': _email,
        'phone': _phone,
        'passport_number': _passportNumber,
        'visa_type': 'Visa', // Force Visa Type
        'visa_status': _visaStatus,
        'photo_url': photoUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      _showSnackBar('Employee added successfully!');
      _fetchEmployees();
      Navigator.pop(context);
      _resetForm();
    } catch (e) {
      _showSnackBar('Error adding employee: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _name = '';
      _position = '';
      _department = '';
      _email = '';
      _phone = '';
      _passportNumber = '';
      _visaType = '';
      _visaStatus = '';
      _employeePhoto = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visa Employees"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEmployees,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
          ? const Center(child: Text("No employees found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return EmployeeCard(
            employee: employee,
            onPressed: () => _showEmployeeInfoDialog(employee),
          );
        },
      ),
      floatingActionButton: _isAdminOrManager
          ? FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => _buildAddEmployeeDialog(),
        ),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      )
          : null,
    );
  }

  Widget _buildAddEmployeeDialog() {
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
                  "Add New Employee",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField('Name', (val) => _name = val, required: true),
                _buildDropdown('Position', _position, [
                  'IT Support',
                  'Manager',
                  'Operation Manager',
                ], (val) => setState(() => _position = val ?? '')),
                _buildDropdown('Department', _department, [
                  'IT',
                  'Manager',
                  'Sales',
                ], (val) => setState(() => _department = val ?? '')),
                _buildTextField('Email', (val) => _email = val, required: true),
                _buildTextField('Phone', (val) => _phone = val, required: true),
                _buildTextField('Passport Number', (val) => _passportNumber = val),
                _buildDropdown('Visa Status', _visaStatus, [
                  'Active',
                  'Inactive',
                ], (val) => setState(() => _visaStatus = val ?? '')),
                const SizedBox(height: 16),
                _buildPhotoPicker(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addEmployee,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Add Employee'),
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

  Widget _buildDropdown(
      String label,
      String currentValue,
      List<String> options,
      Function(String?) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: currentValue.isEmpty ? null : currentValue,
        items: options
            .map((value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select a $label' : null,
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      children: [
        if (_employeePhoto != null)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_employeePhoto!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Pick a Photo'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _employeePhoto = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  void _showEmployeeInfoDialog(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee['name'] ?? 'Employee Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (employee['photo_url'] != null)
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(employee['photo_url']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildInfoRow('Position:', employee['position']),
              _buildInfoRow('Department:', employee['department']),
              _buildInfoRow('Email:', employee['email']),
              _buildInfoRow('Phone:', employee['phone']),
              _buildInfoRow('Passport Number:', employee['passport_number']),
              _buildInfoRow('Visa Type:', employee['visa_type']),
              _buildInfoRow('Visa Status:', employee['visa_status']),
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

class EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onPressed;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: employee['photo_url'] != null
            ? CircleAvatar(
          backgroundImage: NetworkImage(employee['photo_url']),
          radius: 20,
        )
            : const CircleAvatar(
          child: Icon(Icons.person),
          radius: 20,
        ),
        title: Text(
          employee['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Position: ${employee['position'] ?? 'N/A'}"),
            Text("Department: ${employee['department'] ?? 'N/A'}"),
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