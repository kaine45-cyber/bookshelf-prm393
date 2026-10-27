/// Every text the exam checks lives here, so the wording stays exact.
class Strings {
  Strings._();

  // App
  static const appName = 'BookShelf';
  static const appDescription =
      'Keep your own private list of the books you own or want to read. '
      'Sort them by status and genre, rate them and star your favorites.';

  // Auth
  static const login = 'Login';
  static const register = 'Register';
  static const logout = 'Logout';
  static const email = 'Email';
  static const password = 'Password';
  static const confirmPassword = 'Confirm password';
  static const registrationSuccessful = 'Registration successful';

  static const emailRequired = 'Email is required';
  static const emailInvalid = 'Please enter a valid email address';
  static const passwordRequired = 'Password is required';
  static const passwordTooShort = 'Password must be at least 6 characters';
  static const confirmRequired = 'Confirm password is required';
  static const passwordsDoNotMatch = 'Passwords do not match';

  // Book form
  static const title = 'Title';
  static const author = 'Author';
  static const genre = 'Genre';
  static const status = 'Status';
  static const rating = 'Rating';
  static const notes = 'Notes';
  static const chooseGenre = 'Choose genre';
  static const chooseStatus = 'Choose status';

  static const titleRequired = 'Title is required';
  static const titleTooLong = 'Title must be at most 100 characters';
  static const authorRequired = 'Author is required';
  static const authorTooLong = 'Author must be at most 60 characters';
  static const genreRequired = 'Please choose a genre';
  static const statusRequired = 'Please choose a status';
  static const ratingInvalid = 'Rating must be a whole number from 0 to 5';
  static const notesTooLong = 'Notes must be at most 300 characters';

  static const addBook = 'Add a book';
  static const addBookButton = 'Add book';
  static const bookAdded = 'Book added';

  // List
  static const noBooksFound = 'No books found';
  static const all = 'All';
  static const clear = 'Clear';
  static const favoritesOnly = 'favorites only';
  static const search = 'Search';
  static const searchHint = 'Title or author';
  static const filters = 'Filter & search';
  static const summary = 'Summary';

  // Detail
  static const detail = 'Detail';
  static const edit = 'Edit';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const delete = 'Delete';
}

class BookOptions {
  BookOptions._();

  static const genres = ['Fiction', 'Non-Fiction', 'Academic', 'Other'];

  /// Order also used to break ties in the status breakdown.
  static const statuses = ['To Read', 'Reading', 'Finished'];
}

class Limits {
  Limits._();

  static const titleMax = 100;
  static const authorMax = 60;
  static const notesMax = 300;
  static const ratingMin = 0;
  static const ratingMax = 5;
  static const passwordMin = 6;
}
