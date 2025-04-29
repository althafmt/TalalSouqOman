import 'package:talalsouqoman/imports.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employee Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllEmployeesScreen()),
                );
              },
              child: Text('All Employees'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VisaEmployeesScreen()),
                );
              },
              child: Text('Visa Employees'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TemporaryEmployeesScreen()),
                );
              },
              child: Text('Temporary Employees'),
            ),
          ],
        ),
      ),
    );
  }
}
