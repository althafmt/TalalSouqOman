import 'package:talalsouqoman/imports.dart';

class TemporaryEmployeesScreen extends StatefulWidget {
  @override
  _TemporaryEmployeesScreenState createState() =>
      _TemporaryEmployeesScreenState();
}

class _TemporaryEmployeesScreenState extends State<TemporaryEmployeesScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  List<dynamic> _employees = [];
  String _name = '';
  String _position = '';
  String _department = '';
  String _email = '';
  String _phone = '';
  String _passportNumber = '';
  String _visaStatus = '';
  String _visaType = 'Visa'; // Default to Visa
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    final response = await _supabase.from('employees').select('*');
    setState(() {
      _employees = response;
    });
  }

  Future<void> _addEmployee() async {
    if (_name.isEmpty || _position.isEmpty || _email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    String? photoUrl;
    if (_imageFile != null) {
      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'employees/$fileName';

      final response = await _supabase.storage.from('employee_photos').upload(
        filePath,
        _imageFile!,
      );

      if (response.error == null) {
        photoUrl = _supabase.storage.from('employee_photos').getPublicUrl(filePath);
      }
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

    Navigator.of(context).pop();
    _fetchEmployees();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _buildAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Name', _name, (val) => setState(() => _name = val)),
                _buildTextField('Position', _position, (val) => setState(() => _position = val)),
                _buildTextField('Department', _department, (val) => setState(() => _department = val)),
                _buildTextField('Email', _email, (val) => setState(() => _email = val)),
                _buildTextField('Phone', _phone, (val) => setState(() => _phone = val)),
                _buildTextField('Passport Number', _passportNumber, (val) => setState(() => _passportNumber = val)),
                _buildDropdown('Visa Status', _visaStatus, ['Pending', 'Approved', 'Rejected'],
                        (val) => setState(() => _visaStatus = val ?? '')),
                SizedBox(height: 10),
                _imageFile != null
                    ? Image.file(_imageFile!, height: 100)
                    : SizedBox(),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Pick Employee Photo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addEmployee,
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value.isNotEmpty ? value : null,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employee Management')),
      body: ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return ListTile(
            leading: employee['photo_url'] != null
                ? Image.network(employee['photo_url'], width: 50, height: 50)
                : Icon(Icons.person),
            title: Text(employee['name']),
            subtitle: Text(employee['position']),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _buildAddEmployeeDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

extension on String {
  get error => null;
}
