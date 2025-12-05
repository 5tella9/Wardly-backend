// ignore_for_file: unnecessary_underscores, unnecessary_cast, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrendingIdea {
  final String id;
  final String imageUrl;
  final String title;
  final String category;
  final String description;
  final int saveCount;
  final int likeCount;

  TrendingIdea({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.description,
    required this.saveCount,
    required this.likeCount,
  });

  factory TrendingIdea.fromMap(Map<String, dynamic> map) {
    return TrendingIdea(
      id: map['id'].toString(),
      imageUrl: (map['image_url'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      saveCount: (map['save_count'] ?? 0) as int,
      likeCount: (map['like_count'] ?? 0) as int,
    );
  }
}

class TrendingIdeasPage extends StatefulWidget {
  const TrendingIdeasPage({super.key});

  @override
  State<TrendingIdeasPage> createState() => _TrendingIdeasPageState();
}

class _TrendingIdeasPageState extends State<TrendingIdeasPage> {
  final List<String> savedIds = [];
  final List<String> likedIds = [];
  List<TrendingIdea> _trendingIdeas = [];
  bool _loading = true;
  String? _error;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadTrendingIdeas();
  }

  Future<void> _loadTrendingIdeas() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _client
          .from('trending_items')
          .select()
          .eq('is_active', true)
          .order('like_count', ascending: false)
          .order('created_at', ascending: false);

      final list = (data as List<dynamic>)
          .map((row) => TrendingIdea.fromMap(row as Map<String, dynamic>))
          .toList();

      setState(() {
        _trendingIdeas = list;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load trending items: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _toggleLike(TrendingIdea idea, bool isCurrentlyLiked) async {
    final index = _trendingIdeas.indexWhere((i) => i.id == idea.id);
    if (index == -1) return;

    final delta = isCurrentlyLiked ? -1 : 1;
    final newCount =
        (idea.likeCount + delta).clamp(0, 1 << 30) as int; // cast to int

    // optimistic UI update
    final updated = TrendingIdea(
      id: idea.id,
      imageUrl: idea.imageUrl,
      title: idea.title,
      category: idea.category,
      description: idea.description,
      saveCount: idea.saveCount,
      likeCount: newCount,
    );

    setState(() {
      _trendingIdeas[index] = updated;
      if (isCurrentlyLiked) {
        likedIds.remove(idea.id);
      } else {
        likedIds.add(idea.id);
      }
    });

    try {
      await _client
          .from('trending_items')
          .update({'like_count': newCount})
          .eq('id', idea.id);

      // keep list sorted by like_count
      _trendingIdeas.sort((a, b) {
        final c = b.likeCount.compareTo(a.likeCount);
        if (c != 0) return c;
        return b.id.compareTo(a.id);
      });

      setState(() {});
    } catch (e) {
      // rollback on error
      final rolledBack = TrendingIdea(
        id: idea.id,
        imageUrl: idea.imageUrl,
        title: idea.title,
        category: idea.category,
        description: idea.description,
        saveCount: idea.saveCount,
        likeCount: idea.likeCount,
      );

      setState(() {
        _trendingIdeas[index] = rolledBack;
        if (isCurrentlyLiked) {
          likedIds.add(idea.id);
        } else {
          likedIds.remove(idea.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trending Outfits')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadTrendingIdeas,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

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
                  builder: (_) => SavedIdeasPage(
                    savedIds: savedIds,
                    allIdeas: _trendingIdeas,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _trendingIdeas.isEmpty
          ? const Center(child: Text('No trending items yet'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: _trendingIdeas.length,
              itemBuilder: (context, index) {
                final idea = _trendingIdeas[index];
                final isSaved = savedIds.contains(idea.id);
                final isLiked = likedIds.contains(idea.id);

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IdeaDetailPage(
                          idea: idea,
                          isSaved: isSaved,
                          isLiked: isLiked,
                        ),
                      ),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        final savedStatus = result['saved'] as bool;
                        final likedStatus = result['liked'] as bool;

                        if (savedStatus && !savedIds.contains(idea.id)) {
                          savedIds.add(idea.id);
                        } else if (!savedStatus) {
                          savedIds.remove(idea.id);
                        }

                        if (likedStatus && !likedIds.contains(idea.id)) {
                          likedIds.add(idea.id);
                        } else if (!likedStatus) {
                          likedIds.remove(idea.id);
                        }
                      });
                    }
                  },
                  child: _buildIdeaCard(idea, isSaved, isLiked),
                );
              },
            ),
    );
  }

  Widget _buildIdeaCard(TrendingIdea idea, bool isSaved, bool isLiked) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          idea.category,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.thumb_up,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${idea.likeCount}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // like button (top left)
            Positioned(
              top: 8,
              left: 8,
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
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? const Color(0xFFFFD700) : Colors.grey[700],
                    size: 20,
                  ),
                  onPressed: () async {
                    final wasLiked = isLiked;
                    await _toggleLike(idea, isLiked);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(wasLiked ? 'Like removed' : 'Liked!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            // save button (top right)
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
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isSaved) {
                        savedIds.remove(idea.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Removed from saved')),
                        );
                      } else {
                        savedIds.add(idea.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved!')),
                        );
                      }
                    });
                  },
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IdeaDetailPage extends StatefulWidget {
  final TrendingIdea idea;
  final bool isSaved;
  final bool isLiked;

  const IdeaDetailPage({
    super.key,
    required this.idea,
    required this.isSaved,
    required this.isLiked,
  });

  @override
  State<IdeaDetailPage> createState() => _IdeaDetailPageState();
}

class _IdeaDetailPageState extends State<IdeaDetailPage> {
  late bool _isSaved;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
    _isLiked = widget.isLiked;
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
                  child:
                      const Icon(Icons.image, size: 100, color: Colors.grey),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      icon:
                          const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context, {
                        'saved': _isSaved,
                        'liked': _isLiked,
                      }),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: _isLiked
                            ? const Color(0xFFFFD700)
                            : Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _isLiked = !_isLiked);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                _isLiked ? 'Liked!' : 'Like removed'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _isSaved = !_isSaved);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isSaved
                                  ? 'Saved!'
                                  : 'Removed from saved',
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
                          const SnackBar(
                              content: Text('Share coming soon!')),
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
                        color:
                            Colors.white.withValues(alpha: 0.8),
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

class SavedIdeasPage extends StatelessWidget {
  final List<String> savedIds;
  final List<TrendingIdea> allIdeas;

  const SavedIdeasPage({
    super.key,
    required this.savedIds,
    required this.allIdeas,
  });

  @override
  Widget build(BuildContext context) {
    final savedIdeas =
        allIdeas.where((idea) => savedIds.contains(idea.id)).toList();

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
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
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
                        builder: (_) => IdeaDetailPage(
                          idea: idea,
                          isSaved: true,
                          isLiked: false,
                        ),
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
