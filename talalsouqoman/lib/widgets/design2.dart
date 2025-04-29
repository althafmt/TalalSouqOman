import 'package:talalsouqoman/imports.dart';

typedef SelectedCallback = void Function(int index);

class Design2 extends StatefulWidget {
  const Design2({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<CustomBottomNavigationItem> items;
  final int selectedIndex;
  final SelectedCallback onSelected;

  @override
  State<Design2> createState() => _Design2State();
}

class _Design2State extends State<Design2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2),
        ],
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.items.map((item) {
          var index = widget.items.indexOf(item);
          return Expanded(
            flex: 1,
            child: Material(
              child: InkWell(
                onTap: () => widget.onSelected(index),
                child: Ink(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 2,
                        color: widget.selectedIndex == index
                            ? Colors.blue
                            : Colors.transparent,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              item.iconPath,
                              height: 24,
                              width: 24,
                              colorFilter: ColorFilter.mode(
                                widget.selectedIndex == index
                                    ? Colors.blue
                                    : Colors.black,
                                BlendMode.srcATop,
                              ),
                            ),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: widget.selectedIndex == index
                                    ? Colors.blue
                                    : Colors.black,
                                fontSize: 10,
                                fontWeight: widget.selectedIndex == index
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
