import 'package:talalsouqoman/imports.dart';

// Add the BottomNavigationBarProvider class
class BottomNavigationBarProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mqyfhymgjnvkjvlttsfa.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xeWZoeW1nam52a2p2bHR0c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzNzY4MzEsImV4cCI6MjA1Nzk1MjgzMX0.kEtLuVZWY-MAOdwEPUAj_CHHwHsAxRnEsq1bYcDvoS4',
  );

  await restoreSession();

  runApp(
    // Wrap your app with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (_) => BottomNavigationBarProvider(),
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

Future<void> saveSession(String session) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('supabase_session', session);
}

Future<void> restoreSession() async {
  final prefs = await SharedPreferences.getInstance();
  final session = prefs.getString('supabase_session');
  if (session != null) {
    // await supabase.auth.restoreSession(session);
  }
}

Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('supabase_session');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = supabase.auth.currentSession != null;

    return MaterialApp(
      title: 'Talal Souq Oman',
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}