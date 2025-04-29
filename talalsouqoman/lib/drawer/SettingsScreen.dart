import 'package:talalsouqoman/imports.dart';

class SettingsScreen extends StatelessWidget {
  // Function to log the user out
  Future<void> _logout(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut(); // Log out from Supabase
      // Navigate the user to the login page after logging out
      Navigator.pushReplacementNamed(context, '/login'); // Adjust based on your app's routing
    } catch (e) {
      // Handle errors if any (e.g., show an alert)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Logout Failed'),
          content: Text('An error occurred while logging out: $e'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              label: "Logout",
              borderRadius: 15.0,
              onPressed: () => _logout(context), // Logout button functionality
            ),
          ],
        ),
      ),
    );
  }
}
