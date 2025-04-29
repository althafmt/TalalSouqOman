import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentListPage extends StatefulWidget {
  final Map<String, dynamic> driver;

  const PaymentListPage({super.key, required this.driver});

  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _wageRecords = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchWages();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final result = await _supabase
        .from('users')
        .select('privilege')
        .eq('userid', user.id)
        .single();

    setState(() {
      _isAdmin = result['privilege'] == 'admin';
    });
  }

  Future<void> _fetchWages() async {
    final data = await _supabase
        .from('driver_wages')
        .select()
        .eq('driver_id', widget.driver['id'])
        .order('date', ascending: false);

    setState(() {
      _wageRecords = List<Map<String, dynamic>>.from(data);
    });
  }

  void _updatePaymentStatus(int recordId, String newStatus) async {
    await _supabase
        .from('driver_wages')
        .update({'payment_status': newStatus})
        .eq('id', recordId);

    _fetchWages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payments - ${widget.driver['driver_name']}")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _wageRecords.length,
        itemBuilder: (context, index) {
          final record = _wageRecords[index];
          return Card(
            child: ListTile(
              title: Text("Date: ${DateFormat.yMMMd().format(DateTime.parse(record['date']))}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Amount: ${record['total_amount']} OMR"),
                  Row(
                    children: [
                      const Text("Status: "),
                      _isAdmin
                          ? DropdownButton<String>(
                        value: record['payment_status'],
                        onChanged: (val) => _updatePaymentStatus(record['id'], val!),
                        items: const [
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'done', child: Text('Done')),
                        ],
                      )
                          : Text(record['payment_status']),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
