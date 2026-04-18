class PostState {
  final List<String> posts;
  final bool isLoading;
  final bool hasReachedMax;
  final int newPostsCount;

  const PostState({
    required this.posts,
    required this.isLoading,
    required this.hasReachedMax,
    required this.newPostsCount,
  });

  factory PostState.initial() {
    return const PostState(
      posts: [],
      isLoading: false,
      hasReachedMax: false,
      newPostsCount: 0,
    );
  }

  PostState copyWith({
    List<String>? posts,
    bool? isLoading,
    bool? hasReachedMax,
    int? newPostsCount,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      newPostsCount: newPostsCount ?? this.newPostsCount,
    );
  }
}
