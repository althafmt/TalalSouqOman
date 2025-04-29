import 'package:talalsouqoman/imports.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  _AssetsScreenState createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
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
          _buildAssetsScreen(),
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

  Widget _buildAssetsScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildButtonRow(
              [
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => SeebOfficeScreen())),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => SeebShopScreen())),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => SeebStoreScreen())),
              ],
              ["Seeb Office", "Seeb Shop", "Seeb Store"],
              ["assets/image/bt1.png", "assets/image/bt2.png", "assets/image/bt3.png"]
          ),
          const SizedBox(height: 40),
          _buildButtonRow(
              [
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => HalbanStoreScreen())),
                    // () {},
                    // () {},
              ],
              ["Halban Store"],
              ["assets/image/bt4.png"]
          ),
        ],
      ),
    );
  }
}
