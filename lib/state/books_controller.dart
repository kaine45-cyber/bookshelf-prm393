import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/book.dart';
import '../services/book_repository.dart';

/// Holds the logged-in user's books plus the filter/search state.
/// It follows the signed-in user by itself: on logout or a different login
/// everything is cleared, so one account never sees another account's books.
class BooksController extends ChangeNotifier {
  BooksController(this._repo, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance {
    _authSub = _auth.authStateChanges().listen(_onUser);
  }

  final BookRepository _repo;
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Book>>? _booksSub;

  String? _uid;
  List<Book> _books = const [];
  bool _loading = false;
  String? _error;

  String? _genre; // null = All
  String? _status; // null = All
  bool _favoritesOnly = false;
  String _query = '';

  String? get uid => _uid;
  String? get error => _error;
  String? get genre => _genre;
  String? get status => _status;
  bool get favoritesOnly => _favoritesOnly;
  String get query => _query;

  /// True once the first snapshot for [uid] has arrived.
  bool isReadyFor(String uid) => _uid == uid && !_loading;

  void _onUser(User? user) {
    final uid = user?.uid;
    if (uid == _uid) return;
    _booksSub?.cancel();
    _booksSub = null;
    _uid = uid;
    _books = const [];
    _error = null;
    _resetFilters();
    _loading = uid != null;
    notifyListeners();

    if (uid == null) return;
    _booksSub = _repo.watchBooks(uid).listen(
      (books) {
        _books = [...books]..sort(Book.compare);
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = e is Exception ? e.toString() : '$e';
        notifyListeners();
      },
    );
  }

  /// The books currently shown: every active filter must match.
  List<Book> get visibleBooks {
    final q = _query.trim().toLowerCase();
    return _books.where((b) {
      if (_genre != null && b.genre != _genre) return false;
      if (_status != null && b.status != _status) return false;
      if (_favoritesOnly && !b.favorite) return false;
      if (q.isNotEmpty &&
          !b.title.toLowerCase().contains(q) &&
          !b.author.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  void setGenre(String? value) {
    _genre = value;
    notifyListeners();
  }

  void setStatus(String? value) {
    _status = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void clearFilters() {
    _resetFilters();
    notifyListeners();
  }

  void _resetFilters() {
    _genre = null;
    _status = null;
    _favoritesOnly = false;
    _query = '';
  }

  /// One entry per status that appears, most books first;
  /// equal counts keep the order To Read, Reading, Finished.
  static List<MapEntry<String, int>> statusBreakdown(List<Book> books) {
    final counts = <String, int>{};
    for (final b in books) {
      counts[b.status] = (counts[b.status] ?? 0) + 1;
    }
    final order = BookOptions.statuses;
    final entries = order
        .where(counts.containsKey)
        .map((s) => MapEntry(s, counts[s]!))
        .toList();
    entries.sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return order.indexOf(a.key).compareTo(order.indexOf(b.key));
    });
    return entries;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _booksSub?.cancel();
    super.dispose();
  }
}
