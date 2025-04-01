import 'package:app/data/notifiers.dart';
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
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: AnimatedIcon(
                icon: AnimatedIcons.home_menu,
                progress: selectedPage == 0 ? _controller : AlwaysStoppedAnimation(0.0),
              ),
              label: 'Home',
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
              label: 'Sound',
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
              label: 'Pattern',
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
              label: 'Dictionary',
            ),
          ],
          currentIndex: selectedPage,
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.blueGrey,
          backgroundColor: Colors.black87,
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
