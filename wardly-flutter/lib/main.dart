import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'add_clothing_page.dart';
import 'pages/opening_page.dart';
import 'pages/profile_page.dart';
import 'pages/trending_ideas_page.dart';
import 'pages/clothing_detail_page.dart'; // ← TAMBAHAN: Import detail page
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const WardlyApp());
}

class WardlyApp extends StatelessWidget {
  const WardlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WARDLY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const IntroScreen(), // Start dengan opening page
      routes: {'/home': (context) => const WardlyHome()},
    );
  }
}

class WardlyHome extends StatefulWidget {
  const WardlyHome({super.key});

  @override
  State<WardlyHome> createState() => _WardlyHomeState();
}

class _WardlyHomeState extends State<WardlyHome> {
  int _index = 0;
  final List<Map<String, dynamic>> items = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WARDLY'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F3FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _index,
            children: [
              buildHome(),
              buildAdd(),
              const TrendingIdeasPage(), // Trending tab
              ProfilePage(wardrobeItems: items), // ← UBAH: Kirim data items
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed, // Biar bisa lebih dari 3 tabs
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Trending',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // ---------- HOME TAB ----------
  Widget buildHome() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Ganti Wrap jadi SingleChildScrollView biar bisa slide horizontal
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // ← INI YANG BIKIN HORIZONTAL
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children:
                  [
                        'All',
                        'Pants',
                        'Skirts',
                        'Dress',
                        'Shirts',
                        'Outer',
                        'T-Shirt',
                        'Hoodie',
                        'Shoes',
                        'Accessories',
                      ]
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(label: Text(e)),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No items yet. Add some clothes!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8, // ← TAMBAHAN: Biar card lebih tinggi
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    final hasBytes = it.containsKey('bytes');

                    // ========== UBAH: Wrap dengan GestureDetector ==========
                    return GestureDetector(
                      onTap: () async {
                        // Buka detail page
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClothingDetailPage(
                              item: it,
                              onDelete: () {
                                setState(() {
                                  items.removeAt(i);
                                });
                              },
                             
                            ),
                          ),
                        );

                        // Handle action dari detail page
                        if (result != null && result is Map<String, dynamic>) {
                          if (result['action'] == 'toggleFavorite') {
                            setState(() {
                              items[i]['fav'] = !(items[i]['fav'] ?? false);
                            });
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              // Image
                              Positioned.fill(
                                child: hasBytes
                                    ? Image.memory(
                                        it['bytes'] as Uint8List,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),

                              // Favorite button overlay
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      it['fav']
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: it['fav']
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        items[i]['fav'] =
                                            !(items[i]['fav'] ?? false);
                                      });
                                    },
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ),

                              // Info label di bawah
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (it['name'] != null &&
                                          it['name'].toString().isNotEmpty)
                                        Text(
                                          it['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (it['type'] != null ||
                                          it['category'] != null)
                                        Text(
                                          it['type'] ?? it['category'] ?? '',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------- ADD TAB ----------
  Widget buildAdd() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: pickImageGallery,
            icon: const Icon(Icons.photo),
            label: const Text('Pick from gallery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: pickImageCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- PROFILE TAB + AUTH ----------
  // DIHAPUS - Sekarang pake ProfilePage terpisah dari profile_page.dart

  // ---------- STORAGE + DB HELPERS ----------
  Future<String?> uploadImageToSupabase(Uint8List bytes) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first to save items')),
      );
      return null;
    }
    final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await _client.storage.from('wardrobe').uploadBinary(fileName, bytes);
      final imageUrl = _client.storage.from('wardrobe').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
      return null;
    }
  }

  Future<void> insertWardrobeItem({
    required String imageUrl,
    String category = 'Top',
    String? title,
    String? brand,
    String? size,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in first')));
      return;
    }
    try {
      await _client.from('wardrobe_items').insert({
        'user_id': user.id,
        'image_url': imageUrl,
        'category': category,
        'title': title ?? 'Untitled item',
        'brand': brand,
        'size': size,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Insert error: $e')));
    }
  }

  // ---------- IMAGE PICKERS ----------
  Future<void> pickImageGallery() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo == null) return;

    // Navigate ke AddClothingPage
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddClothingPage(initialImage: File(photo.path)),
      ),
    );

    // Kalau ada result (user save), tambahkan ke list
    if (result != null) {
      final bytes = await photo.readAsBytes();

      // Upload ke Supabase kalau user login
      if (_client.auth.currentUser != null) {
        final imageUrl = await uploadImageToSupabase(bytes);
        if (imageUrl != null) {
          await insertWardrobeItem(
            imageUrl: imageUrl,
            category: result['category'] ?? 'Top',
            title: result['name'] ?? 'New item',
            brand: result['brand'],
            size: result['size'],
          );
        }
      }

      setState(() {
        items.insert(0, {
          'bytes': bytes,
          'fav': false,
          'type': result['category'] ?? 'Top',
          'name': result['name'],
          'brand': result['brand'],
          'size': result['size'],
        });
        _index = 0; // Balik ke Home tab
      });
    }
  }

  Future<void> pickImageCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;

    // Navigate ke AddClothingPage
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddClothingPage(initialImage: File(photo.path)),
      ),
    );

    // Kalau ada result (user save), tambahkan ke list
    if (result != null) {
      final bytes = await photo.readAsBytes();

      // Upload ke Supabase kalau user login
      if (_client.auth.currentUser != null) {
        final imageUrl = await uploadImageToSupabase(bytes);
        if (imageUrl != null) {
          await insertWardrobeItem(
            imageUrl: imageUrl,
            category: result['category'] ?? 'Top',
            title: result['name'] ?? 'New item',
            brand: result['brand'],
            size: result['size'],
          );
        }
      }

      setState(() {
        items.insert(0, {
          'bytes': bytes,
          'fav': false,
          'type': result['category'] ?? 'Top',
          'name': result['name'],
          'brand': result['brand'],
          'size': result['size'],
        });
        _index = 0; // Balik ke Home tab
      });
    }
  }
}
