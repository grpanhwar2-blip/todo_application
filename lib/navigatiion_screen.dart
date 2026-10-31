import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'rewards.dart';
import 'settings_screen.dart';

// ======================================================
// MAIN NAVIGATION SCREEN
// ======================================================

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  // All main screens
  final List<Widget> _screens = const [
    HomeScreen(),
    RewardsScreen(),
    SettingsScreen(),
  ];

  // Navigation items
  final List<_NavItem> _items = const [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      colors: [Color(0xFFB18AFF), Color(0xFF7045E8)],
    ),
    _NavItem(
      label: 'Rewards',
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      colors: [Color(0xFFFFC45C), Color(0xFFFF783F)],
    ),
    _NavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      colors: [Color(0xFF58D8E5), Color(0xFF2585D8)],
    ),
  ];

  // ======================================================
  // TAB SELECTION
  // ======================================================

  Future<void> _selectTab(int index) async {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('settings_haptics') ?? true;

      if (enabled) {
        HapticFeedback.selectionClick();
      }
    } catch (_) {
      // Navigation continues even if preferences are unavailable.
    }
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF30234A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF30234A).withValues(alpha: 0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(_items.length, (index) {
                    return Expanded(
                      child: _AnimatedNavButton(
                        item: _items[index],
                        selected: _selectedIndex == index,
                        onTap: () => _selectTab(index),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// NAVIGATION ITEM MODEL
// ======================================================

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final List<Color> colors;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.colors,
  });
}

// ======================================================
// ANIMATED NAVIGATION BUTTON
// ======================================================

class _AnimatedNavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _AnimatedNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: item.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(19),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: item.colors.last.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.12 : 1,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  color: selected ? Colors.white : Colors.white70,
                  size: 23,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : const SizedBox(height: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
