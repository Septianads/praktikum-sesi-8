
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserService {
  static const String baseUrl =
      'https://jsonplaceholder.typicode.com/users';

  static const String storageKey = 'users_local_data';

  static const int nimSuffix = 75;
  static const int userId = 1000 + nimSuffix;

  // ==========================================
  // GET USERS
  // ==========================================
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final localData = prefs.getString(storageKey);

    if (localData != null) {
      final decoded = jsonDecode(localData) as List;

      return decoded
          .map((item) => User.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList();
    }

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final users = data.map((item) {
        final json = Map<String, dynamic>.from(item);

        return User(
          id: json['id'],
          name: json['name'] ?? '',
          email: json['email'] ?? '',
          city: json['address']?['city'] ?? '',
        );
      }).toList();

      await _saveUsers(users);

      return users;
    }

    throw Exception('Gagal mengambil data User');
  }

  // ==========================================
  // GET USER BY ID
  // ==========================================
  static Future<User?> getUserById(int id) async {
    final users = await getUsers();

    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // POST USER
  // ==========================================
  static Future<User> createUser({
    required String name,
    required String email,
    required String city,
  }) async {
    final users = await getUsers();

    final newUser = User(
      id: userId,
      name: name,
      email: email,
      city: city,
    );

    users.removeWhere((user) => user.id == userId);
    users.add(newUser);

    await _saveUsers(users);

    return newUser;
  }

  // ==========================================
  // PUT USER
  // ==========================================
  static Future<User> updateUser({
    required int id,
    required String name,
    required String email,
  }) async {
    final users = await getUsers();

    final index = users.indexWhere((user) => user.id == id);

    if (index == -1) {
      throw Exception('User dengan ID $id tidak ditemukan');
    }

    final oldUser = users[index];

    final updatedUser = User(
      id: oldUser.id,
      name: name,
      email: email,
      city: oldUser.city,
    );

    users[index] = updatedUser;

    await _saveUsers(users);

    return updatedUser;
  }

  // ==========================================
  // PATCH USER
  // ==========================================
  static Future<User> patchUser({
    required int id,
    required String name,
  }) async {
    final users = await getUsers();

    final index = users.indexWhere((user) => user.id == id);

    if (index == -1) {
      throw Exception('User dengan ID $id tidak ditemukan');
    }

    final oldUser = users[index];

    final updatedName = '$name - Flutter Developer';

    final updatedUser = User(
      id: oldUser.id,
      name: updatedName,
      email: oldUser.email,
      city: oldUser.city,
    );

    users[index] = updatedUser;

    await _saveUsers(users);

    return updatedUser;
  }

  // ==========================================
  // DELETE USER
  // ==========================================
  static Future<bool> deleteUser(int id) async {
    final users = await getUsers();

    final initialLength = users.length;

    users.removeWhere((user) => user.id == id);

    if (users.length == initialLength) {
      throw Exception('User dengan ID $id tidak ditemukan');
    }

    await _saveUsers(users);

    return true;
  }

  // ==========================================
  // SAVE LOCAL DATA
  // ==========================================
  static Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();

    final data = users.map((user) => user.toJson()).toList();

    await prefs.setString(storageKey, jsonEncode(data));
  }

  // ==========================================
  // RESET DATA
  // ==========================================
  static Future<void> resetUsers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(storageKey);
  }
}
