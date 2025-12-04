// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'opening_page.dart'; // Import IntroScreen

class ProfilePage extends StatefulWidget {
  final List<Map<String, dynamic>> wardrobeItems;

  const ProfilePage({super.key, required this.wardrobeItems});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  SupabaseClient get _client => Supabase.instance.client;
  User? get currentUser => _client.auth.currentUser;

  // Hitung statistik wardrobe
  int get totalItems => widget.wardrobeItems.length;
  int get favoriteItems =>
      widget.wardrobeItems.where((item) => item['fav'] == true).length;

  Map<String, int> get itemsByCategory {
    final Map<String, int> categoryCount = {};
    for (var item in widget.wardrobeItems) {
      final category = item['type'] ?? item['category'] ?? 'Other';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    return categoryCount;
  }

  Future<void> _signOut() async {
    try {
      await _client.auth.signOut();
      if (!mounted) return;

      // ========== UBAH: Navigate ke IntroScreen (Opening Page) ==========
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
        (route) => false, // Hapus semua route sebelumnya
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal,
            child: Text(
              user?.email?.substring(0, 1).toUpperCase() ?? 'G',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User Info
          if (user != null) ...[
            Text(
              user.email ?? 'Guest User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Member since ${_formatDate(user.createdAt)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ] else ...[
            const Text(
              'Guest User',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to save your wardrobe',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],

          const SizedBox(height: 32),

          // Wardrobe Statistics Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wardrobe Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.checkroom,
                        label: 'Total Items',
                        value: totalItems.toString(),
                        color: Colors.teal,
                      ),
                      _buildStatItem(
                        icon: Icons.favorite,
                        label: 'Favorites',
                        value: favoriteItems.toString(),
                        color: Colors.red,
                      ),
                      _buildStatItem(
                        icon: Icons.category,
                        label: 'Categories',
                        value: itemsByCategory.length.toString(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category Breakdown
          if (itemsByCategory.isNotEmpty) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...itemsByCategory.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              '${entry.value} items',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Sign Out Button
          if (user != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Recently';
    }
  }
}
