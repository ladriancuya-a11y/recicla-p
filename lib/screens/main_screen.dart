import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recicla_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    ScanScreen(),
    MapScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReciclaProvider>();
    final currentIndex = provider.selectedTabIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Inicio',
                  index: 0,
                  currentIndex: currentIndex,
                ),
                _NavItem(
                  icon: Icons.document_scanner_outlined,
                  activeIcon: Icons.document_scanner_rounded,
                  label: 'Clasificar',
                  index: 1,
                  currentIndex: currentIndex,
                  isSpecial: true,
                ),
                _NavItem(
                  icon: Icons.location_on_outlined,
                  activeIcon: Icons.location_on_rounded,
                  label: 'Mapa',
                  index: 2,
                  currentIndex: currentIndex,
                ),
                _NavItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history_rounded,
                  label: 'Historial',
                  index: 3,
                  currentIndex: currentIndex,
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Perfil',
                  index: 4,
                  currentIndex: currentIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final bool isSpecial;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final provider = context.read<ReciclaProvider>();

    if (isSpecial) {
      return GestureDetector(
        onTap: () => provider.setSelectedTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppColors.darkGreen : AppColors.lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.white : AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.darkGreen : AppColors.mediumGray,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => provider.setSelectedTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.darkGreen : AppColors.mediumGray,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.darkGreen : AppColors.mediumGray,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 1),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 20 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
