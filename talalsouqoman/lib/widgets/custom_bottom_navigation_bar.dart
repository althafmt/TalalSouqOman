import 'package:talalsouqoman/imports.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelected;

  const CustomBottomNavigationBar({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final List<CustomBottomNavigationItem> navigationBarItems = [
      CustomBottomNavigationItem(iconPath: Constants.home, label: "Home"),
      CustomBottomNavigationItem(iconPath: Constants.profile, label: "Profile"),
      CustomBottomNavigationItem(iconPath: Constants.about, label: "About"),
      CustomBottomNavigationItem(iconPath: Constants.notification, label: "Notification"),
      CustomBottomNavigationItem(iconPath: Constants.settings, label: "Settings"),
    ];

    return Design2(
      items: navigationBarItems,
      selectedIndex: selectedIndex,
      onSelected: onSelected,
    );
  }
}

class CustomBottomNavigationItem {
  final String label;
  final String iconPath;

  CustomBottomNavigationItem({required this.iconPath, required this.label});
}
