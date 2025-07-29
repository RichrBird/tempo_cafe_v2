import 'package:flutter/material.dart';
import 'package:tempo_cafe_v2/screens/account_screen.dart';
import 'package:tempo_cafe_v2/screens/menu_screen.dart';
//import 'package:tempo_cafe_v2/services/auth/auth_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0; // Set the initial index to 3 for 'Account'

  // Add your other screens here later
  static final List<Widget> _widgetOptions = <Widget>[
    const Center(child: Text('Home Screen')), // Placeholder for Home
    const MenuScreen(),   // Placeholder for Menu
    const Center(child: Text('Order Screen')),  // Placeholder for Order
    const AccountScreen(),                      // Your Account Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final authServices = AuthServices();

    return Scaffold(
      /* appBar: AppBar(
        title: const Text('Tempo Cafe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authServices.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ), */
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        // Use your theme colors
        //selectedItemColor: colors.primary,
        //unselectedItemColor: colors.onSurface.withOpacity(0.6),
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
