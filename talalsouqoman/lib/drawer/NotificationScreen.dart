// notification_screen.dart
import 'package:talalsouqoman/imports.dart';

class NotificationScreen extends StatelessWidget {
  final List<String> notifications;

  const NotificationScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Notifications"),
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text("No new  notifications."),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(notification),
            ),
          );
        },
      ),
    );
  }
}