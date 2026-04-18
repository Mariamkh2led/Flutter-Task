import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_cubit.dart';
import 'post_state.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostCubit()
        ..loadMore()
        ..checkForNewPosts(),
      child: const _PostsView(),
    );
  }
}

class _PostsView extends StatefulWidget {
  const _PostsView();

  @override
  State<_PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<_PostsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluxy'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(
        children: [
          // banner
          BlocSelector<PostCubit, PostState, int>(
            selector: (s) => s.newPostsCount,
            builder: (context, count) {
              if (count == 0) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  context.read<PostCubit>().loadNewPosts();
                  _scrollToTop();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F1FB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFB5D4F4),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$count new posts — tap to load',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0C447C),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if (state.posts.isEmpty && state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 150) {
                      context.read<PostCubit>().loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        state.posts.length + (state.hasReachedMax ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index < state.posts.length) {
                        return _PostCard(postData: state.posts[index]);
                      }
                      if (state.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final String postData;
  const _PostCard({required this.postData});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final parts = widget.postData.split('|');
    final text = parts[0];
    final type = parts.length > 1 ? parts[1] : '';
    final imagePath = parts.length > 2 ? parts[2] : '';

    final isRapper = type == 'rapper';

    final userName = text.contains(':') ? text.split(':')[0].trim() : text;
    final postText = text.contains(':')
        ? text.split(':').skip(1).join(':').trim()
        : text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isRapper
                    ? Colors.amber.shade100
                    : Colors.blue.shade100,
                child: Text(
                  userName[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isRapper
                        ? Colors.amber.shade900
                        : Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: Color(0xFF378ADD),
                      ),
                    ],
                  ),
                  Text(
                    isRapper ? 'Rapper' : 'Official',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(
            postText,
            style: const TextStyle(fontSize: 14, height: 1.55),
          ),
        ),

        if (imagePath.isNotEmpty)
          Image.asset(
            imagePath,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 220,
              color: Colors.grey.shade100,
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _liked = !_liked),
                child: Row(
                  children: [
                    Icon(
                      _liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 22,
                      color: _liked ? Colors.pink : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _liked ? '21K' : '20K',
                      style: TextStyle(
                        fontSize: 13,
                        color: _liked ? Colors.pink : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 5),
              Text(
                '12K',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Icon(Icons.share_outlined, size: 20, color: Colors.grey.shade500),
            ],
          ),
        ),

        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}
