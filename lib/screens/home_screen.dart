import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'content_screen.dart';
import 'profile_screen.dart';
import 'repository_screen.dart';
import 'admin_workspace_screen.dart';
import 'admin_user_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _getScreens(bool isAdmin) {
    if (isAdmin) {
      return const [
        AdminDashboardScreen(),
        AdminWorkspaceScreen(),
        AdminUserManagementScreen(),
        ProfileScreen(),
      ];
    } else {
      return const [
        DashboardScreen(),
        ContentScreen(),
        RepositoryScreen(),
        ProfileScreen(),
      ];
    }
  }

  List<String> _getTitles(bool isAdmin) {
    if (isAdmin) {
      return const [
        'Admin Dashboard',
        'Workspace',
        'User Management',
        'Profil',
      ];
    } else {
      return const [
        'Dashboard',
        'Content Planner',
        'Repository',
        'Profil',
      ];
    }
  }

  List<BottomNavigationBarItem> _getNavItems(bool isAdmin) {
    if (isAdmin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: 'Workspace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'User',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: 'Content',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: 'Repository',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isAdmin = appState.role == 'admin';
    final screens = _getScreens(isAdmin);
    final titles = _getTitles(isAdmin);
    final navItems = _getNavItems(isAdmin);

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          if (appState.currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text('${appState.currentUser!.name} • ${appState.role}'),
              ),
            ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.purple[100],
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: TextStyle(color: Colors.purple[100]),
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}
