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
  PageController? _pageController; // recreated when viewport changes
  double _viewportFraction = -1; // track last used fraction
  final List<String> _categories = const ['All', 'Hot', 'Cold', 'Food'];
  String _selectedCategory = 'All';

  static final List<Widget> _widgetOptions = <Widget>[
    // Index 0 handled separately (menu carousel)
    const SizedBox.shrink(), // placeholder (unused)
    const MenuScreen(), // Orders / menu details
    const AccountScreen(), // Account
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

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

  List<Widget> _buildMenuCardsSliver(BuildContext context) {
    return [
      _buildCategoryChipsSliver(context),
      FutureBuilder<List<dynamic>>(
        future: _fetchMenu(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SliverFillRemaining(
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Text('No drinks available', style: Theme.of(context).textTheme.bodyLarge),
              ),
            );
          }
          final drinks = snapshot.data!;
          // Filter by selected category if available in data
          final String selected = _selectedCategory.toLowerCase();
          final List<dynamic> filtered = selected == 'all'
              ? drinks
              : drinks.where((d) {
                  final c = (d['category'] ?? d['type'] ?? '').toString().toLowerCase();
                  return c == selected;
                }).toList();
          // ----- Responsive sizing math -----
          final size = MediaQuery.of(context).size;
          final width = size.width;
          final bool isTablet = width >= 600;
          final bool isSmall = width < 350;
          final bool isLargePhone = width >= 430 && width < 600;
          double targetViewport = isTablet
              ? 0.42
              : (isSmall
                  ? 0.92
                  : (isLargePhone ? 0.70 : 0.78));

          if (targetViewport != _viewportFraction) {
            final previousPage = _pageController?.hasClients == true
                ? _pageController!.page?.round() ?? 0
                : 0;
            _pageController?.dispose();
            _pageController = PageController(
              viewportFraction: targetViewport,
              initialPage: previousPage,
            );
            _viewportFraction = targetViewport;
          }

          final imageDiameter = (width * (isTablet ? 0.20 : 0.34)).clamp(90.0, isTablet ? 180.0 : 150.0);
          final cardBodyHeightBase = isTablet ? 180.0 : 155.0;
          double cardHeight = (cardBodyHeightBase + imageDiameter * 0.9).clamp(230.0, 380.0);
          final topOffset = imageDiameter * 0.48; // space above card body for floating image
          final contentTopPadding = imageDiameter * 0.63; // internal padding so title below image
          // Prevent slight RenderFlex overflow by guaranteeing minimum usable body height
          final minContentBody = contentTopPadding + 140; // 140 ~= text + pills + spacing + price row
          final currentBody = cardHeight - topOffset;
          if (currentBody < minContentBody) {
            final delta = (minContentBody - currentBody).ceilToDouble();
            cardHeight += delta;
          }
          final carouselHeight = cardHeight + 20; // include external padding

          return SliverToBoxAdapter(
            child: SizedBox(
              height: carouselHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: filtered.length,
                padEnds: true,
                physics: const BouncingScrollPhysics(),
                pageSnapping: true,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController!,
                    builder: (context, child) {
                      double scale = 1.0;
                      double translateY = 0.0;
                      double relative = 0.0; // page - index
                      if (_pageController!.position.haveDimensions) {
                        final page = _pageController!.page ?? _pageController!.initialPage.toDouble();
                        relative = page - index;
                        final distance = relative.abs();
                        final d = distance.clamp(0.0, 1.0);
                        final curve = Curves.easeOutCubic.transform(1 - d);
                        const minScale = 0.82;
                        scale = (minScale + (1 - minScale) * curve).clamp(minScale, 1.0);
                        translateY = 24 * (1 - curve);
                      }
                      return Center(
                        child: Transform.translate(
                          offset: Offset(0, translateY),
                          child: Transform.scale(
                            scale: scale,
                            child: _DrinkCard(
                              drink: filtered[index],
                              pageOffset: relative,
                              imageDiameter: imageDiameter,
                              cardHeight: cardHeight,
                              topOffset: topOffset,
                              contentTopPadding: contentTopPadding,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    ];
  }

  // Category chips sliver shown above the carousel
  Widget _buildCategoryChipsSliver(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cat in _categories)
                ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (sel) async {
                    if (!sel) return;
                    setState(() => _selectedCategory = cat);
                    if (_pageController?.hasClients == true) {
                      await _pageController!.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: _selectedCategory == cat
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(.6),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: _selectedCategory == cat
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers = [
      SliverAppBar(
        pinned: true,
        floating: false,
        expandedHeight: 140.0,
        flexibleSpace: FlexibleSpaceBar(
          title: Text('${_getGreeting()}, User!'),
          background: Container(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    ];

    if (_selectedIndex == 0) {
      slivers.addAll(_buildMenuCardsSliver(context));
    } else {
      slivers.add(
        SliverFillRemaining(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: slivers,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 6, top: 6),
        child: GNav(
          gap: 8,
          hoverColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.secondary,
          activeColor: Theme.of(context).colorScheme.primary, // Use onSurface color for the active icon and label
          tabBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          tabBorderRadius: 60,
          haptic: true,
          tabs: 
          [
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
      )
              
    );
  }
}

/// Stylized drink card matching the provided mockup (gradient background, circular image, rating, volume, price, add button).
class _DrinkCard extends StatelessWidget {
  final Map<String, dynamic> drink;
  final double pageOffset; // negative if to right (next), positive if to left (previous)
  final double imageDiameter;
  final double cardHeight;
  final double topOffset;
  final double contentTopPadding;
  const _DrinkCard({
    required this.drink,
    this.pageOffset = 0,
    required this.imageDiameter,
    required this.cardHeight,
    required this.topOffset,
    required this.contentTopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = (drink['drink_name'] ?? drink['name'] ?? '').toString();
    final description = (drink['description'] ?? '').toString();
    final imageUrl = (drink['image_url'] ?? '').toString();
    final rating = _parseDouble(drink['rating']) ?? 4.3; // fallback
    final price = _parseDouble(drink['price'] ?? drink['cost']) ?? 0.0;
    final volume = drink['volume_ml'] ?? drink['volume'] ?? '160ml';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: SizedBox(
        height: cardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card background
            Positioned.fill(
              top: topOffset,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(.85),
                      theme.colorScheme.primary.withOpacity(.55),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(20, contentTopPadding, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Pill(
                          icon: Icons.star_rounded,
                          label: rating.toStringAsFixed(1),
                          background: Colors.white.withOpacity(.15),
                          foreground: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        _Pill(
                          label: volume.toString(),
                          background: Colors.white.withOpacity(.15),
                          foreground: theme.colorScheme.onPrimary,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          price > 0 ? '\$ ${price.toStringAsFixed(2)}' : '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            // TODO: add to cart
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(Icons.add, color: theme.colorScheme.primary),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            // Floating circular image
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Parallax: move image opposite scroll direction, max ~30px
                  final maxShift = (imageDiameter * 0.25).clamp(20.0, 42.0);
                  final shiftX = (-pageOffset * maxShift).clamp(-maxShift, maxShift);
                  return Transform.translate(
                    offset: Offset(shiftX, 0),
                    child: Center(
                      child: _DrinkImage(
                        imageUrl: imageUrl,
                        description: description,
                        diameter: imageDiameter,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class _DrinkImage extends StatelessWidget {
  final String imageUrl;
  final String description;
  final double diameter;
  const _DrinkImage({required this.imageUrl, required this.description, this.diameter = 120});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;
    final d = diameter;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
  child: CircleAvatar(
        backgroundColor: Colors.white,
        child: ClipOval(
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: d,
      height: d,
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40),
                )
              : Icon(Icons.local_drink, size: 48, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  const _Pill({required this.label, this.icon, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
