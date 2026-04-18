import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(PostState.initial());

  static const int _pageSize = 10;
  static const int _maxPosts = 30;

  static const List<String> _allPosts = [
    'Marwan Pablo: The new album is finally here 🖤 |rapper|images/pp.jpg',
    'BMW: The new M5. 4.4L V8. 727 HP. Built for dominance on every road 🔥 #BMWM|car|images/b1.jfif',
    'Wegz: B.B. King Ft. dhom_altlasy 😉🔥 Out now!|rapper|images/we2.jfif',
    'Mercedes: The new S-Class. Next-level comfort, unmatched luxury, and cutting-edge tech ✨ #SClass|car|images/m2.jpg',
    'Afroto: We just hit 100M streams 🎵 Thank you all ❤️|rapper|',
    'Porsche: 911 GT3 RS. Precision engineering made for the track 🏁 #GT3RS|car|images/p1.jpg',
    'Double Zuksh: New track with Marwan dropping soon 🔥 Stay tuned|rapper|',
    'Ferrari: SF90 XX Stradale. Hybrid power meets extreme performance ⚡🏎️ #Ferrari|car|images/f1.jfif',
    'Marwan Pablo: Tickets for Alexandria concert are live now 🖤🔥|rapper|images/pp2.jfif',
    'Abyusif: New music loading... Stay tuned 🎶|rapper|images/aa.jfif',
    'BMW: XM Label Red. 748 HP of pure aggressive performance 🚀 #BMWXM|car|images/b2.jfif',
    'Wegz: making it spicy 🔥|rapper|images/nn.jfif',
    'Mercedes: AMG GT 63. Power, speed, and luxury in one machine 💨 #AMG|car|images/m2.jpg',
    'Afroto: New album on the way — coming soon 🎵|rapper|',
    'Porsche: Taycan Turbo GT. 1092 HP electric monster ⚡ redefining speed|car|images/p3.jpg',
    'Marwan Pablo: Studio sessions 🎙️|rapper|images/pp.jpg',
    'BMW: i7 M70. Electric luxury with unmatched smoothness and power ⚡ #BMWi7|car|images/b3.jfif',
    'Double Zuksh: 50M streams on the first track 🎵🔥|rapper|',
    'Wegz: The next concert will be bigger than ever 🎤🔥|rapper|images/mm.jfif',
    'Marwan Pablo: N3ml ehh gded? 🤔|rapper|',
    'Porsche: 911 Carrera GTS. Perfect balance between daily drive and sport performance 🏎️ #Porsche|car|images/p2.jpg',
    'Afroto: 200K followers and counting ❤️ Thank you!|rapper|',
    'BMW: M4 Competition. Ultimate driving machine with track-ready attitude 🏁 #BMWM4|car|images/b3.jfif',
    'Marwan Mousa: Fi El Gdid meno ✊🔥|rapper|images/mmm.jpg',
    'Wegz: اركب بورش مبتصبورش 🚗🔥|rapper|',
    'Porsche: Macan EV. Smart electric SUV built for the future ⚡ #Porsche|car|images/p1.jpg',
    'Marwan Pablo: نعمل حفلة في القاهرة؟|rapper|',
  ];

  static const List<List<String>> _newPostsRounds = [
    // Round 1
    [
      'Marwan Pablo: حفلة اسكندرية sold out في ساعات 😈🔥|rapper|',
      'BMW: M3 Touring. Everyday practicality meets track performance 🔥 #BMWM3|car|images/b4.jfif',
      'Abyusif: New track, new vibe 🎶|rapper|',
    ],
    // Round 2
    [
      'Wegz: شكراً على 10M على الأغنية الجديدة 🔥|rapper|images/we2.jfif',
      'Ferrari: LaFerrari returns. Limited edition. #Ferrari|car|images/f1.jfif',
    ],
    // Round 3
    [
      'Marwan Pablo: حاسس اني عايز انزل تراك...!👀|rapper|',
      'BMW: The new M2. Small but deadly. #BMWM2|car|images/b1.jfif',
      'Double Zuksh: في حاجة جديدة قريباً 👀|rapper|',
      'Marwan Mousa: Ra2s Mal is on spotify |rapper|images/ma1.jfif',
    ],
  ];

  int _currentRound = 0;
  List<String> _pendingNewPosts = [];
  Future<void> loadMore() async {
    if (state.isLoading || state.hasReachedMax) return;

    emit(state.copyWith(isLoading: true));

    await Future.delayed(const Duration(seconds: 1));

    final currentLength = state.posts.length;

    if (currentLength >= _maxPosts) {
      emit(state.copyWith(isLoading: false, hasReachedMax: true));
      return;
    }

    final remaining = _maxPosts - currentLength;
    final take = remaining >= _pageSize ? _pageSize : remaining;

    final newPosts = _allPosts.skip(currentLength).take(take).toList();

    final updatedPosts = [...state.posts, ...newPosts];
    final reachedMax = updatedPosts.length >= _maxPosts;

    emit(
      state.copyWith(
        posts: updatedPosts,
        isLoading: false,
        hasReachedMax: reachedMax,
      ),
    );
  }

  Future<void> checkForNewPosts() async {
    if (_currentRound >= _newPostsRounds.length) return;

    await Future.delayed(const Duration(seconds: 7));

    _pendingNewPosts = List.from(_newPostsRounds[_currentRound]);

    emit(state.copyWith(newPostsCount: _pendingNewPosts.length));
  }

  void loadNewPosts() {
    if (_pendingNewPosts.isEmpty) return;

    final updated = [..._pendingNewPosts, ...state.posts];
    _pendingNewPosts = [];
    _currentRound++;

    emit(state.copyWith(posts: updated, newPostsCount: 0));

    checkForNewPosts();
  }
}
