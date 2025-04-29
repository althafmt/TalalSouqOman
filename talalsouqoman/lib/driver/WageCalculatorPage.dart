import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WageCalculatorPage extends StatefulWidget {
  final Map<String, dynamic> driver;

  const WageCalculatorPage({super.key, required this.driver});

  @override
  State<WageCalculatorPage> createState() => _WageCalculatorPageState();
}

class _WageCalculatorPageState extends State<WageCalculatorPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _paymentStatus = 'pending';
  double _wagePerHour = 1.0;
  double _totalAmount = 0.0;

  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final result = await _supabase
        .from('users')
        .select('privilege')
        .eq('userid', user.id)
        .single();

    setState(() {
      _isAdmin = result['privilege'] == 'admin';
      _loading = false;
    });
  }

  String getWorkedHours() {
    if (_startTime == null || _endTime == null) return "";
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    final difference = endMinutes - startMinutes;

    if (difference <= 0) return "End time must be after start time";

    final hours = difference ~/ 60;
    final minutes = difference % 60;
    return "Worked Duration: $hours hours ${minutes > 0 ? '$minutes minutes' : ''}";
  }

  Future<void> _submitWage() async {
    if (!_isAdmin) return;

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all time fields")),
      );
      return;
    }

    final start = Duration(hours: _startTime!.hour, minutes: _startTime!.minute);
    final end = Duration(hours: _endTime!.hour, minutes: _endTime!.minute);
    final hoursWorked = end.inMinutes - start.inMinutes;

    if (hoursWorked <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }

    _totalAmount = (hoursWorked / 60.0) * _wagePerHour;

    await _supabase.from('driver_wages').insert({
      'driver_id': widget.driver['id'],
      'driver_name': widget.driver['driver_name'],
      'date': _selectedDate!.toIso8601String(),
      'start_time': '${_startTime!.hour}:${_startTime!.minute}',
      'end_time': '${_endTime!.hour}:${_endTime!.minute}',
      'wage_per_hour': _wagePerHour,
      'total_amount': _totalAmount,
      'payment_status': _paymentStatus,
      'created_at': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Wage record added")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text("Access Denied")),
        body: const Center(child: Text("Only Admin can access this page.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Wage Calculator - ${widget.driver['driver_name']}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Text(_selectedDate == null
                    ? "Pick Date"
                    : DateFormat.yMMMd().format(_selectedDate!)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _startTime = picked);
                },
                child: Text(_startTime == null
                    ? "Pick Start Time"
                    : "Start: ${_startTime!.format(context)}"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _endTime = picked);
                },
                child: Text(_endTime == null
                    ? "Pick End Time"
                    : "End: ${_endTime!.format(context)}"),
              ),
              if (_startTime != null && _endTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    getWorkedHours(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "Wage per hour"),
                initialValue: '1.0',
                keyboardType: TextInputType.number,
                onChanged: (val) => _wagePerHour = double.tryParse(val) ?? 1.0,
              ),
              DropdownButton<String>(
                value: _paymentStatus,
                onChanged: (val) => setState(() => _paymentStatus = val!),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitWage,
                child: const Text("Calculate and Save"),
              ),
              const SizedBox(height: 10),
              if (_totalAmount > 0)
                Text("Total Amount: $_totalAmount OMR"),
            ],
          ),
        ),
      ),
    );
  }
}
