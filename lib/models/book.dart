import 'package:cloud_firestore/cloud_firestore.dart';

/// What the user typed in the Add / Edit form (already trimmed).
class BookInput {
  const BookInput({
    required this.title,
    required this.author,
    required this.genre,
    required this.status,
    required this.rating,
    required this.notes,
  });

  final String title;
  final String author;
  final String genre;
  final String status;
  final int? rating;
  final String notes;

  Map<String, dynamic> toFields() => {
        'title': title,
        'author': author,
        'genre': genre,
        'status': status,
        'rating': rating,
        'notes': notes,
      };
}

class Book {
  const Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.genre,
    required this.status,
    required this.rating,
    required this.favorite,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String author;
  final String genre;
  final String status;
  final int? rating;
  final bool favorite;
  final String notes;
  final Timestamp? createdAt;

  factory Book.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    String str(Object? v) => v is String ? v : '';
    final rating = d['rating'];
    final createdAt = d['createdAt'];
    return Book(
      id: doc.id,
      userId: str(d['userId']),
      title: str(d['title']),
      author: str(d['author']),
      genre: str(d['genre']),
      status: str(d['status']),
      rating: rating is num ? rating.toInt() : null,
      favorite: d['favorite'] == true,
      notes: str(d['notes']),
      createdAt: createdAt is Timestamp ? createdAt : null,
    );
  }

  Book copyWithInput(BookInput input, {required String id}) => Book(
        id: id,
        userId: userId,
        title: input.title,
        author: input.author,
        genre: input.genre,
        status: input.status,
        rating: input.rating,
        favorite: favorite,
        notes: input.notes,
        createdAt: createdAt,
      );

  /// Alphabetical by title (ignoring case), then by author.
  static int compare(Book a, Book b) {
    final byTitle = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    if (byTitle != 0) return byTitle;
    final byAuthor = a.author.toLowerCase().compareTo(b.author.toLowerCase());
    if (byAuthor != 0) return byAuthor;
    return a.id.compareTo(b.id);
  }
}
