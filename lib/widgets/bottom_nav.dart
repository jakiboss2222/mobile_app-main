import 'package:flutter/material.dart';
import '../pages/profile_pages.dart';
import '../pages/dashboard_pages.dart';
import '../pages/search_page.dart'; // ✔ perbaikan nama file

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1C2A4D),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.blue.shade100,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(color: Colors.white54),

      currentIndex: index,
      onTap: (i) {
        setState(() => index = i);

        switch (i) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPages()),
            );
            break;

          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchPage()), // ✔ perbaikan const
            );
            break;

          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePages()),
            );
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Pencarian",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
