import 'package:talalsouqoman/imports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService auth = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;
  int selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Talal Souq Oman"),  // Use custom app bar
      bottomNavigationBar: CustomBottomNavigationBar(  // Use custom bottom navigation bar
        selectedIndex: selectedIndex,
        onSelected: (index) {
          setState(() {
            selectedIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomeScreen(),
          ProfileScreen(),
          AboutAppPage(),
          NotificationScreen(notifications: [],),
          SettingsScreen(),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<VoidCallback> actions, List<String> labels, List<String> imagePaths) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          labels.length,
              (index) => _buildCustomButtonWithLabel(actions[index], labels[index], imagePaths[index])
      ),
    );
  }

  Widget _buildCustomButtonWithLabel(VoidCallback onPressed, String label, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildButtonRow(
              [
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetsScreen())),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeDetailsScreen())),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverHomePage())),
              ],
              ["Assets", "Staff", "Drivers"],
              ["assets/image/bt1.png", "assets/image/bt2.png", "assets/image/bt3.png"]
          ),
          const SizedBox(height: 40),
          _buildButtonRow(
              [
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeliveriesPage())),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => VehiclesSDetails())),
                    () {},
              ],
              ["Deliveries", "Vehicles", "Button"],
              ["assets/image/bt4.png", "assets/image/bt5.png", "assets/image/bt6.png"]
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    await auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }
}
