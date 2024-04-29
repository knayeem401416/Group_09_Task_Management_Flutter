class FormValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a name';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an email address';
    RegExp emailRegex = RegExp('^[a-zA-Z0-9_.-]+@[a-zA-Z0-9.-]+.[a-z]');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a phone number';
    RegExp phoneRegex = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
    if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

}
