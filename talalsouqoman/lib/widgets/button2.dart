import 'package:talalsouqoman/imports.dart';

class CustomButton2 extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final double borderRadius; // Added parameter for shape control

  const CustomButton2({
    super.key,
    required this.label,
    this.onPressed,
    this.borderRadius = 0.0, // Default to square
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius), // Apply border radius
          ),
          backgroundColor: Colors.green, // Example color
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
