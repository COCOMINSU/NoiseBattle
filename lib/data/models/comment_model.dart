import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? parentCommentId; // 대댓글인 경우 부모 댓글 ID
  final String content;
  final int depth; // 댓글 깊이 (0: 댓글, 1: 대댓글)
  final List<String> imageUrls;
  final CommentMetrics metrics;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    this.depth = 0,
    this.imageUrls = const [],
    required this.metrics,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      parentCommentId: data['parentCommentId'],
      content: data['content'] ?? '',
      depth: data['depth'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      metrics: CommentMetrics.fromMap(data['metrics'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'parentCommentId': parentCommentId,
      'content': content,
      'depth': depth,
      'imageUrls': imageUrls,
      'metrics': metrics.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'isDeleted': isDeleted,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentCommentId,
    String? content,
    int? depth,
    List<String>? imageUrls,
    CommentMetrics? metrics,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isDeleted,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      depth: depth ?? this.depth,
      imageUrls: imageUrls ?? this.imageUrls,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // 대댓글인지 확인
  bool get isReply => parentCommentId != null && depth > 0;

  // 댓글인지 확인
  bool get isComment => parentCommentId == null && depth == 0;
}

// 댓글 지표
class CommentMetrics {
  final int likeCount;
  final int dislikeCount;
  final int reportCount;

  CommentMetrics({
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.reportCount = 0,
  });

  factory CommentMetrics.fromMap(Map<String, dynamic> map) {
    return CommentMetrics(
      likeCount: map['likeCount'] ?? 0,
      dislikeCount: map['dislikeCount'] ?? 0,
      reportCount: map['reportCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'reportCount': reportCount,
    };
  }

  CommentMetrics copyWith({
    int? likeCount,
    int? dislikeCount,
    int? reportCount,
  }) {
    return CommentMetrics(
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}

// 댓글 작성을 위한 DTO
class CreateCommentDto {
  final String postId;
  final String userId;
  final String? parentCommentId;
  final String content;
  final List<String> imageUrls;

  CreateCommentDto({
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    this.imageUrls = const [],
  });

  CommentModel toCommentModel({required String id}) {
    final now = DateTime.now();
    return CommentModel(
      id: id,
      postId: postId,
      userId: userId,
      parentCommentId: parentCommentId,
      content: content,
      depth: parentCommentId != null ? 1 : 0,
      imageUrls: imageUrls,
      metrics: CommentMetrics(),
      createdAt: now,
      updatedAt: now,
    );
  }
}

// 댓글 수정을 위한 DTO
class UpdateCommentDto {
  final String? content;
  final List<String>? imageUrls;

  UpdateCommentDto({this.content, this.imageUrls});

  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (content != null) map['content'] = content;
    if (imageUrls != null) map['imageUrls'] = imageUrls;
    map['updatedAt'] = FieldValue.serverTimestamp();
    return map;
  }
}
