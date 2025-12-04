// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

// Data dummy untuk trending ideas
class TrendingIdea {
  final String id;
  final String imageUrl;
  final String title;
  final String category;
  final String description;

  TrendingIdea({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.description,
  });
}

// Dummy data
final List<TrendingIdea> trendingIdeasData = [
  TrendingIdea(
    id: '1',
    imageUrl:
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
    title: 'Summer Vibes Outfit',
    category: 'Casual',
    description: 'Perfect summer look with light fabrics and vibrant colors',
  ),
  TrendingIdea(
    id: '2',
    imageUrl:
        'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800',
    title: 'Street Style Essential',
    category: 'Street',
    description: 'Urban street style with oversized jacket and sneakers',
  ),
  TrendingIdea(
    id: '3',
    imageUrl:
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
    title: 'Minimalist Aesthetic',
    category: 'Minimal',
    description: 'Clean and simple wardrobe essentials',
  ),
  TrendingIdea(
    id: '4',
    imageUrl:
        'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=800',
    title: 'Y2K Fashion Revival',
    category: 'Y2K',
    description: 'Nostalgic 2000s fashion making a comeback',
  ),
  TrendingIdea(
    id: '5',
    imageUrl:
        'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?w=800',
    title: 'Formal Business Look',
    category: 'Formal',
    description: 'Professional attire for important meetings',
  ),
  TrendingIdea(
    id: '6',
    imageUrl:
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
    title: 'Bohemian Chic',
    category: 'Boho',
    description: 'Free-spirited bohemian style with flowing fabrics',
  ),
  TrendingIdea(
    id: '7',
    imageUrl: 'https://images.unsplash.com/photo-1558769132-cb1aea1c8f25?w=800',
    title: 'Athleisure Comfort',
    category: 'Sport',
    description: 'Comfortable activewear for everyday style',
  ),
  TrendingIdea(
    id: '8',
    imageUrl:
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800',
    title: 'Vintage Inspired',
    category: 'Vintage',
    description: 'Timeless vintage pieces with modern twist',
  ),
];

// ============================================
// TRENDING IDEAS PAGE (Pinterest Style)
// ============================================
class TrendingIdeasPage extends StatefulWidget {
  const TrendingIdeasPage({super.key});

  @override
  State<TrendingIdeasPage> createState() => _TrendingIdeasPageState();
}

class _TrendingIdeasPageState extends State<TrendingIdeasPage> {
  final List<String> savedIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trending Ideas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavedIdeasPage(savedIds: savedIds),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: trendingIdeasData.length,
        itemBuilder: (context, index) {
          final idea = trendingIdeasData[index];
          final isSaved = savedIds.contains(idea.id);

          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IdeaDetailPage(idea: idea, isSaved: isSaved),
                ),
              );

              if (result != null && result is bool) {
                setState(() {
                  if (result && !savedIds.contains(idea.id)) {
                    savedIds.add(idea.id);
                  } else if (!result) {
                    savedIds.remove(idea.id);
                  }
                });
              }
            },
            child: _buildIdeaCard(idea, isSaved),
          );
        },
      ),
    );
  }

  Widget _buildIdeaCard(TrendingIdea idea, bool isSaved) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              idea.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idea.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      idea.category,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Colors.teal : Colors.grey[700],
                  ),
                  onPressed: () {
                    setState(() {
                      if (isSaved) {
                        savedIds.remove(idea.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Removed from saved')),
                        );
                      } else {
                        savedIds.add(idea.id);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Saved!')));
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// DETAIL PAGE (Close Up View)
// ============================================
class IdeaDetailPage extends StatefulWidget {
  final TrendingIdea idea;
  final bool isSaved;

  const IdeaDetailPage({super.key, required this.idea, required this.isSaved});

  @override
  State<IdeaDetailPage> createState() => _IdeaDetailPageState();
}

class _IdeaDetailPageState extends State<IdeaDetailPage> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.idea.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
              ),
            ),
          ),
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
                      onPressed: () => Navigator.pop(context, _isSaved),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _isSaved = !_isSaved);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isSaved ? 'Saved!' : 'Removed from saved',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.idea.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.idea.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.idea.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// SAVED IDEAS PAGE
// ============================================
class SavedIdeasPage extends StatelessWidget {
  final List<String> savedIds;

  const SavedIdeasPage({super.key, required this.savedIds});

  @override
  Widget build(BuildContext context) {
    final savedIdeas = trendingIdeasData
        .where((idea) => savedIds.contains(idea.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Ideas'),
        backgroundColor: Colors.teal,
      ),
      body: savedIdeas.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No saved ideas yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Save ideas by tapping the bookmark icon',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: savedIdeas.length,
              itemBuilder: (context, index) {
                final idea = savedIdeas[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            IdeaDetailPage(idea: idea, isSaved: true),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            idea.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(12),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    idea.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    idea.category,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 12,
                                    ),
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
    );
  }
}
