import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClothingDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onDelete;

  const ClothingDetailPage({
    super.key,
    required this.item,
    this.onDelete,
  });

  @override
  State<ClothingDetailPage> createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasBytes = item.containsKey('bytes');
    final isFavorite = item['fav'] ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen image
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: hasBytes
                  ? Image.memory(
                      item['bytes'] as Uint8List,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _deleting
                          ? null
                          : () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _deleting
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                {'action': 'toggleFavorite'},
                              );
                            },
                    ),
                    if (widget.onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed:
                            _deleting ? null : () => _showDeleteConfirmation(context),
                      ),
                    if (_deleting)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom info card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      if (item['name'] != null &&
                          item['name'].toString().isNotEmpty)
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Info grid
                      Row(
                        children: [
                          // Category
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.category,
                              label: 'Category',
                              value: item['type'] ??
                                  item['category'] ??
                                  'N/A',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Size
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.straighten,
                              label: 'Size',
                              value: item['size'] ?? 'N/A',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Brand
                      if (item['brand'] != null &&
                          item['brand'].toString().isNotEmpty)
                        _buildInfoCard(
                          icon: Icons.business,
                          label: 'Brand',
                          value: item['brand'],
                          color: Colors.orange,
                          fullWidth: true,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content:
              const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _deleting
                  ? null
                  : () async {
                      Navigator.pop(dialogContext); // close dialog
                      await _handleDelete();         // delete in supabase
                    },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _deleting = true);

    final client = Supabase.instance.client;
    final item = widget.item;

    final id = item['id'];
    // Adjust this: use the column you actually store the path in
    final dynamic rawPath = item['image_path'] ?? item['image_url'];
    final String? imagePath =
        rawPath != null ? rawPath.toString() : null;

    try {
      // 1) Delete image from Storage (if we have a path)
      if (imagePath != null && imagePath.isNotEmpty) {
        await client.storage.from('wardrobe').remove([imagePath]);
      }

      // 2) Delete DB row from wardrobe_items
      if (id != null) {
        await client
            .from('wardrobe_items')
            .delete()
            .eq('id', id);
      }

      // 3) Notify parent + pop page
      widget.onDelete?.call();

      if (!mounted) return;

      Navigator.pop(context, {
        'action': 'deleted',
        'id': id,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete item: $e'),
        ),
      );
    }
  }
}
