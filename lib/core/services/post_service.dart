import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/post_model.dart';
import '../../data/models/comment_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자 ID 가져오기
  String? get currentUserId => _auth.currentUser?.uid;

  // ============= 게시글 관련 메서드 =============

  /// 게시글 생성
  Future<String> createPost(CreatePostDto dto) async {
    try {
      final docRef = await _firestore
          .collection('posts')
          .add(dto.toPostModel(id: '').toFirestore());

      // 사용자 통계 업데이트
      await _updateUserPostCount(dto.userId, 1);

      return docRef.id;
    } catch (e) {
      throw Exception('게시글 생성 실패: $e');
    }
  }

  /// 게시글 목록 조회 (페이지네이션 지원)
  Stream<List<PostModel>> getPosts({
    String? boardType,
    String? category,
    String? apartmentId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
    bool includeDeleted = false,
  }) {
    Query query = _firestore.collection('posts');

    // 필터링
    if (boardType != null) {
      query = query.where('boardType', isEqualTo: boardType);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (apartmentId != null) {
      query = query.where('apartmentId', isEqualTo: apartmentId);
    }
    if (!includeDeleted) {
      query = query.where('isDeleted', isEqualTo: false);
    }

    // 정렬 및 제한
    query = query.orderBy('createdAt', descending: true).limit(limit);

    // 페이지네이션
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
    );
  }

  /// 베스트 게시글 조회 (주간/월간)
  Stream<List<PostModel>> getBestPosts({
    required String period, // 'weekly' or 'monthly'
    int limit = 10,
  }) {
    final now = DateTime.now();
    DateTime startDate;

    if (period == 'weekly') {
      startDate = now.subtract(Duration(days: 7));
    } else {
      startDate = DateTime(now.year, now.month - 1, now.day);
    }

    return _firestore
        .collection('posts')
        .where('boardType', isEqualTo: BoardType.noiseReview)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(startDate))
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt')
        .orderBy('metrics.likeCount', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  /// 게시글 상세 조회
  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        // 조회수 증가
        await _incrementViewCount(postId);
        return PostModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('게시글 조회 실패: $e');
    }
  }

  /// 사용자의 게시글 조회
  Stream<List<PostModel>> getUserPosts(String userId, {int limit = 20}) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  /// 게시글 수정
  Future<void> updatePost(String postId, UpdatePostDto dto) async {
    try {
      final post = await getPost(postId);
      if (post == null) {
        throw Exception('게시글을 찾을 수 없습니다.');
      }

      if (post.userId != currentUserId) {
        throw Exception('수정 권한이 없습니다.');
      }

      await _firestore
          .collection('posts')
          .doc(postId)
          .update(dto.toUpdateMap());
    } catch (e) {
      throw Exception('게시글 수정 실패: $e');
    }
  }

  /// 게시글 삭제 (소프트 삭제)
  Future<void> deletePost(String postId) async {
    try {
      final post = await getPost(postId);
      if (post == null) {
        throw Exception('게시글을 찾을 수 없습니다.');
      }

      if (post.userId != currentUserId) {
        throw Exception('삭제 권한이 없습니다.');
      }

      await _firestore.collection('posts').doc(postId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 사용자 통계 업데이트
      await _updateUserPostCount(post.userId, -1);
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }

  /// 게시글 좋아요
  Future<void> likePost(String postId) async {
    if (currentUserId == null) throw Exception('로그인이 필요합니다.');

    try {
      final batch = _firestore.batch();

      // 좋아요 문서 추가
      final likeRef = _firestore
          .collection('post_likes')
          .doc('${postId}_${currentUserId}');

      batch.set(likeRef, {
        'postId': postId,
        'userId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 게시글 좋아요 수 증가
      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {
        'metrics.likeCount': FieldValue.increment(1),
        'engagement.score': FieldValue.increment(5), // 좋아요는 5점
        'engagement.lastEngagementAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      if (e.toString().contains('already exists')) {
        throw Exception('이미 좋아요를 눌렀습니다.');
      }
      throw Exception('좋아요 실패: $e');
    }
  }

  /// 게시글 좋아요 취소
  Future<void> unlikePost(String postId) async {
    if (currentUserId == null) throw Exception('로그인이 필요합니다.');

    try {
      final batch = _firestore.batch();

      // 좋아요 문서 삭제
      final likeRef = _firestore
          .collection('post_likes')
          .doc('${postId}_${currentUserId}');

      batch.delete(likeRef);

      // 게시글 좋아요 수 감소
      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {
        'metrics.likeCount': FieldValue.increment(-1),
        'engagement.score': FieldValue.increment(-5),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('좋아요 취소 실패: $e');
    }
  }

  /// 게시글 좋아요 여부 확인
  Future<bool> isPostLiked(String postId) async {
    if (currentUserId == null) return false;

    try {
      final doc = await _firestore
          .collection('post_likes')
          .doc('${postId}_${currentUserId}')
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ============= 댓글 관련 메서드 =============

  /// 댓글 작성
  Future<String> createComment(CreateCommentDto dto) async {
    try {
      final batch = _firestore.batch();

      // 댓글 추가
      final commentRef = _firestore.collection('comments').doc();
      batch.set(
        commentRef,
        dto.toCommentModel(id: commentRef.id).toFirestore(),
      );

      // 게시글 댓글 수 증가
      final postRef = _firestore.collection('posts').doc(dto.postId);
      batch.update(postRef, {
        'metrics.commentCount': FieldValue.increment(1),
        'engagement.score': FieldValue.increment(3), // 댓글은 3점
        'engagement.lastEngagementAt': FieldValue.serverTimestamp(),
      });

      // 사용자 통계 업데이트
      final userRef = _firestore.collection('users').doc(dto.userId);
      batch.update(userRef, {
        'statistics.commentCount': FieldValue.increment(1),
      });

      await batch.commit();
      return commentRef.id;
    } catch (e) {
      throw Exception('댓글 작성 실패: $e');
    }
  }

  /// 댓글 목록 조회
  Stream<List<CommentModel>> getComments(String postId, {int limit = 50}) {
    return _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// 댓글 수정
  Future<void> updateComment(String commentId, UpdateCommentDto dto) async {
    try {
      final comment = await _getComment(commentId);
      if (comment == null) {
        throw Exception('댓글을 찾을 수 없습니다.');
      }

      if (comment.userId != currentUserId) {
        throw Exception('수정 권한이 없습니다.');
      }

      await _firestore
          .collection('comments')
          .doc(commentId)
          .update(dto.toUpdateMap());
    } catch (e) {
      throw Exception('댓글 수정 실패: $e');
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment(String commentId) async {
    try {
      final comment = await _getComment(commentId);
      if (comment == null) {
        throw Exception('댓글을 찾을 수 없습니다.');
      }

      if (comment.userId != currentUserId) {
        throw Exception('삭제 권한이 없습니다.');
      }

      final batch = _firestore.batch();

      // 댓글 소프트 삭제
      final commentRef = _firestore.collection('comments').doc(commentId);
      batch.update(commentRef, {
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 게시글 댓글 수 감소
      final postRef = _firestore.collection('posts').doc(comment.postId);
      batch.update(postRef, {
        'metrics.commentCount': FieldValue.increment(-1),
        'engagement.score': FieldValue.increment(-3),
      });

      // 사용자 통계 업데이트
      final userRef = _firestore.collection('users').doc(comment.userId);
      batch.update(userRef, {
        'statistics.commentCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('댓글 삭제 실패: $e');
    }
  }

  /// 댓글 좋아요
  Future<void> likeComment(String commentId) async {
    if (currentUserId == null) throw Exception('로그인이 필요합니다.');

    try {
      final batch = _firestore.batch();

      // 좋아요 문서 추가
      final likeRef = _firestore
          .collection('comment_likes')
          .doc('${commentId}_${currentUserId}');

      batch.set(likeRef, {
        'commentId': commentId,
        'userId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 댓글 좋아요 수 증가
      final commentRef = _firestore.collection('comments').doc(commentId);
      batch.update(commentRef, {'metrics.likeCount': FieldValue.increment(1)});

      await batch.commit();
    } catch (e) {
      if (e.toString().contains('already exists')) {
        throw Exception('이미 좋아요를 눌렀습니다.');
      }
      throw Exception('댓글 좋아요 실패: $e');
    }
  }

  // ============= 신고 관련 메서드 =============

  /// 게시글 신고
  Future<void> reportPost(String postId, String reason) async {
    if (currentUserId == null) throw Exception('로그인이 필요합니다.');

    try {
      final batch = _firestore.batch();

      // 신고 문서 추가
      final reportRef = _firestore.collection('post_reports').doc();
      batch.set(reportRef, {
        'postId': postId,
        'reporterId': currentUserId,
        'reason': reason,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 게시글 신고 수 증가
      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {
        'metrics.reportCount': FieldValue.increment(1),
        'moderation.isReported': true,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('신고 실패: $e');
    }
  }

  // ============= 유틸리티 메서드 =============

  /// 조회수 증가 (중복 방지)
  Future<void> _incrementViewCount(String postId) async {
    if (currentUserId == null) return;

    final viewKey = 'post_view_${postId}_${currentUserId}';

    try {
      // 24시간 내 중복 조회 방지 (캐시 사용 권장)
      await _firestore.collection('posts').doc(postId).update({
        'metrics.viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      // 조회수 증가 실패는 무시
    }
  }

  /// 사용자 게시글 수 업데이트
  Future<void> _updateUserPostCount(String userId, int increment) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'statistics.postCount': FieldValue.increment(increment),
      });
    } catch (e) {
      // 통계 업데이트 실패는 무시
    }
  }

  /// 댓글 조회 (내부용)
  Future<CommentModel?> _getComment(String commentId) async {
    try {
      final doc = await _firestore.collection('comments').doc(commentId).get();
      if (doc.exists) {
        return CommentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 아파트 인증 사용자 게시글 필터링
  Stream<List<PostModel>> getVerifiedApartmentPosts({
    String? boardType,
    String? category,
    int limit = 20,
  }) {
    Query query = _firestore.collection('posts');

    if (boardType != null) {
      query = query.where('boardType', isEqualTo: boardType);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query
        .where('isDeleted', isEqualTo: false)
        .where('location.apartmentName', isNotEqualTo: null)
        .orderBy('location.apartmentName')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  /// 검색 기능
  Stream<List<PostModel>> searchPosts({
    required String keyword,
    String? boardType,
    String? category,
    int limit = 20,
  }) {
    Query query = _firestore.collection('posts');

    if (boardType != null) {
      query = query.where('boardType', isEqualTo: boardType);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    // Firestore의 제한된 검색 기능으로 인해 클라이언트 필터링 필요
    return query
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit * 2) // 필터링을 고려해 더 많이 가져옴
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs
              .map((doc) => PostModel.fromFirestore(doc))
              .where(
                (post) =>
                    post.title.toLowerCase().contains(keyword.toLowerCase()) ||
                    post.content.toLowerCase().contains(keyword.toLowerCase()),
              )
              .take(limit)
              .toList();
          return posts;
        });
  }
}
