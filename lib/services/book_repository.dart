import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import '../models/book.dart';

/// All Firestore access for the `books` collection.
///
/// Document ids are deterministic (see firestore.rules):
///   `<uid>_<sha256(lower(trim(title)) + "|" + lower(trim(author)))>`
/// so the database itself refuses a second copy of the same title + author.
///
/// Add / edit go through transactions: a transaction is not shown locally
/// before the server accepts it, so a refused book never flashes in the list.
class BookRepository {
  BookRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _books =>
      _db.collection('books');

  static String docIdFor(String uid, String title, String author) {
    final key = '${title.trim().toLowerCase()}|${author.trim().toLowerCase()}';
    return '${uid}_${sha256.convert(utf8.encode(key))}';
  }

  Stream<List<Book>> watchBooks(String uid) {
    return _books
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map(Book.fromDoc).toList());
  }

  Stream<Book?> watchBook(String id) {
    return _books
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Book.fromDoc(doc) : null);
  }

  Future<void> addBook(String uid, BookInput input) async {
    final id = docIdFor(uid, input.title, input.author);
    final ref = _books.doc(id);
    await _db.runTransaction<void>((tx) async {
      tx.set(ref, {
        'id': id,
        'userId': uid,
        ...input.toFields(),
        'favorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Returns the book's id after saving (it changes when title/author change).
  Future<String> updateBook(Book old, BookInput input) async {
    final newId = docIdFor(old.userId, input.title, input.author);

    if (newId == old.id) {
      await _db.runTransaction<void>((tx) async {
        tx.update(_books.doc(old.id), input.toFields());
      });
      return old.id;
    }

    // Title/author changed: the id changes too, so move the book.
    await _db.runTransaction<void>((tx) async {
      tx.set(_books.doc(newId), {
        'id': newId,
        'userId': old.userId,
        ...input.toFields(),
        'favorite': old.favorite,
        'createdAt': old.createdAt ?? FieldValue.serverTimestamp(),
      });
      tx.delete(_books.doc(old.id));
    });
    return newId;
  }

  Future<void> toggleFavorite(Book book) {
    return _books.doc(book.id).update({'favorite': !book.favorite});
  }

  Future<void> deleteBook(String id) => _books.doc(id).delete();
}
