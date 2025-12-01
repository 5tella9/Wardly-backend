import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String password; // plain text for demo only

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'password': password,
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'],
    username: m['username'],
    email: m['email'],
    password: m['password'],
  );
}

class AuthService {
  static const String _usersKey = 'wardly_users';
  static const String _loggedKey = 'wardly_logged';

  // get all users
  static Future<List<UserModel>> _getUsers() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_usersKey);
    if (raw == null) return [];
    final List data = jsonDecode(raw);
    return data
        .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> _saveUsers(List<UserModel> users) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(users.map((u) => u.toMap()).toList());
    await sp.setString(_usersKey, raw);
  }

  // signup
  // returns null on success, or error message string
  static Future<String?> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    // simple validations
    if (username.trim().isEmpty) return 'Username kosong';
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Email not valid';
    }
    if (password.length < 4) return 'Password minimal 4 karakter';

    // unique username/email check (case-insensitive)
    final existsUsername = users.any(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );
    if (existsUsername) return 'Username sudah dipakai';

    final existsEmail = users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (existsEmail) return 'Email sudah dipakai';

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      password: password,
    );
    users.insert(0, newUser);
    await _saveUsers(users);
    // auto login
    await loginWithEmail(email: email, password: password);
    return null;
  }

  // login with email+password
  static Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    final u = users.firstWhere(
      (x) =>
          x.email.toLowerCase() == email.toLowerCase() &&
          x.password == password,
      orElse: () => UserModel(id: '', username: '', email: '', password: ''),
    );
    if (u.id == '') return 'Wrong Email or password';
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_loggedKey, jsonEncode(u.toMap()));
    return null;
  }

  // login with username+password (resolve to email then login)
  static Future<String?> loginWithUsername({
    required String username,
    required String password,
  }) async {
    final users = await _getUsers();
    final u = users.firstWhere(
      (x) =>
          x.username.toLowerCase() == username.toLowerCase() &&
          x.password == password,
      orElse: () => UserModel(id: '', username: '', email: '', password: ''),
    );
    if (u.id == '') return 'Wrong Username or password';
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_loggedKey, jsonEncode(u.toMap()));
    return null;
  }

  // unified login: accept usernameOrEmail and password
  static Future<String?> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    if (usernameOrEmail.contains('@')) {
      return await loginWithEmail(email: usernameOrEmail, password: password);
    } else {
      return await loginWithUsername(
        username: usernameOrEmail,
        password: password,
      );
    }
  }

  // get current logged user
  static Future<UserModel?> currentUser() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_loggedKey);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(jsonDecode(raw));
    return UserModel.fromMap(map);
  }

  static Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_loggedKey);
  }

  // delete account (by id)
  static Future<void> deleteAccount(String id) async {
    final users = await _getUsers();
    users.removeWhere((u) => u.id == id);
    await _saveUsers(users);
    await logout();
  }
}
