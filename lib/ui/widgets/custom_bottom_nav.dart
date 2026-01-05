import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      // This creates the semi-circle cutout for the FAB
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.bar_chart, 1),
            
            // This empty space allows the FAB to sit in the notch without overlapping icons
            const SizedBox(width: 48), 
            
            _buildNavItem(Icons.history, 2),
            _buildNavItem(Icons.settings, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = currentIndex == index;
    return IconButton(
      icon: Icon(
        icon, 
        size: 28,
        color: isSelected ? const Color(0xFF2AAAAD) : Colors.grey.shade400,
      ),
      onPressed: () => onTap(index),
    );
  }
}