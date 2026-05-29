String? validateSearchQuery(String? input) {
  if (input == null || input.trim().isEmpty) {
    return null; // this is for showing all countries when search is cleared
  }
  final trimmed = input.trim();
  if (trimmed.length < 2) {
    return 'Please enter at least 2 characters';
  }
  final validPattern = RegExp(r'^[a-zA-Z\s]+$');
  if (!validPattern.hasMatch(trimmed)) {
    return 'Only letters and spaces are allowed';
  }
  return null;
}
