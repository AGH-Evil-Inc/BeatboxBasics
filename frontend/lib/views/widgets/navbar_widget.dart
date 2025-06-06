import 'package:app/main.dart';

import '../../data/notifiers.dart';
import 'package:flutter/material.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: selectedPage == 1
                    ? const Icon(Icons.home_outlined, key: ValueKey('selected'))
                    : const Icon(Icons.home, key: ValueKey('unselected')),
              ),
              label: 'Strona główna',
            ),
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: selectedPage == 1
                    ? const Icon(Icons.music_note, key: ValueKey('selected'))
                    : const Icon(Icons.music_note_outlined, key: ValueKey('unselected')),
              ),
              label: 'Dźwięki',
            ),
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: selectedPage == 2
                    ? const Icon(Icons.library_music, key: ValueKey('selected'))
                    : const Icon(Icons.library_music_outlined, key: ValueKey('unselected')),
              ),
              label: 'Patterny',
            ),
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: selectedPage == 3
                    ? const Icon(Icons.book, key: ValueKey('selected'))
                    : const Icon(Icons.book_outlined, key: ValueKey('unselected')),
              ),
              label: 'Słowniczek',
            ),

             BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: selectedPage == 3
                    ? const Icon(Icons.bar_chart, key: ValueKey('selected'))
                    : const Icon(Icons.bar_chart_outlined, key: ValueKey('unselected')),
              ),
              label: 'Statystyki',
            ),

          ],
          currentIndex: selectedPage,
          selectedItemColor: appColors.navSelectedColor,
          unselectedItemColor: appColors.navUnselectedColor,
          backgroundColor: appColors.backgroundColor,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (selectedPage != index) {
              _controller.reset();
              _controller.forward();
              selectedPageNotifier.value = index;
            }
          },
        );
      },
    );
  }
}
