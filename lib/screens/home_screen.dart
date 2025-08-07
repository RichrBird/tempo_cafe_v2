import 'package:flutter/material.dart';
import 'package:tempo_cafe_v2/screens/account_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tempo_cafe_v2/screens/menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    // Home tab will show drink menu cards
    // Placeholder for Order
    const HomeScreen(),
    const MenuScreen(),
    // Account Screen
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<List<dynamic>> _fetchMenu() async {
    final response = await Supabase.instance.client.from('drink_menu').select();
    return response; // response is already a List
  }

  Widget _buildMenuCards(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchMenu(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SliverFillRemaining(
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final drinks = snapshot.data!;
        return SliverList.builder(
          itemCount: drinks.length,
          itemBuilder: (sliverContext, index) {
            final drink = drinks[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child:
                        drink['image_url'] != null &&
                            drink['image_url'].toString().isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: drink['image_url'],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image, size: 48),
                          )
                        : Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.local_drink, size: 48),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      drink['drink_name'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      drink['description'] ?? 'Delicious drink',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: () {
                        // Add your action here
                      },
                      child: const Text('Order now'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = _selectedIndex == 0
        ? _buildMenuCards(context)
        : SliverFillRemaining(child: _widgetOptions[_selectedIndex]);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: false,
            //expandedHeight: 140.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('${_getGreeting()}, User!'),
              /* background: Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ), */
            ),
          ),
          bodyContent,
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 6, top: 6),
        child: GNav(
          gap: 8,
          hoverColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.secondary,
          activeColor: Theme.of(context)
              .colorScheme
              .primary, // Use onSurface color for the active icon and label
          tabBackgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          tabBorderRadius: 60,
          haptic: true,
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Menu',
              //iconColor: Theme.of(context).colorScheme.primary,
              //textColor: Theme.of(context).colorScheme.primary,
            ),
            GButton(
              icon: Icons.shopping_bag,
              text: 'Orders',
              //iconColor: Theme.of(context).colorScheme.primary,
              //textColor: Theme.of(context).colorScheme.primary,
            ),
            GButton(
              icon: Icons.person,
              text: 'Account',
              //iconColor: Theme.of(context).colorScheme.primary,
              //textColor: Theme.of(context).colorScheme.primary,
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,

          //backgroundColor: Theme.of(context).colorScheme.surface, // Use surface color for the background
          //color: Theme.of(context).colorScheme.onSurface, // Use onSurface color for the icon and label
          //tabBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1,)
        ),
      ),
    );
  }
}
