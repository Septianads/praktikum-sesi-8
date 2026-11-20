
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin.dart';

class AdminService {
  static const String storageKey = 'admins_local_data';

  static const int nimSuffix = 75;
  static const int adminId = 2000 + nimSuffix;

  // ==========================================
  // DATA ADMIN DEFAULT
  // ==========================================
  static List<Admin> _defaultAdmins() {
    return [
      Admin(
        id: adminId,
        name: 'Admin Praktikum',
        email: 'admin075@example.com',
        department: 'Information Technology',
      ),
      Admin(
        id: 2001,
        name: 'Admin Support',
        email: 'support@example.com',
        department: 'Support',
      ),
      Admin(
        id: 2002,
        name: 'Admin Manager',
        email: 'manager@example.com',
        department: 'Management',
      ),
    ];
  }

  // ==========================================
  // GET ADMINS
  // ==========================================
  static Future<List<Admin>> getAdmins() async {
    final prefs = await SharedPreferences.getInstance();

    final localData = prefs.getString(storageKey);

    if (localData == null) {
      final admins = _defaultAdmins();

      await _saveAdmins(admins);

      return admins;
    }

    final decoded = jsonDecode(localData) as List;

    return decoded
        .map((item) => Admin.fromJson(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }

  // ==========================================
  // GET ADMIN BY ID
  // ==========================================
  static Future<Admin?> getAdmin(int id) async {
    final admins = await getAdmins();

    try {
      return admins.firstWhere((admin) => admin.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // DELETE ADMIN
  // ==========================================
  static Future<bool> deleteAdmin(int id) async {
    final admins = await getAdmins();

    final initialLength = admins.length;

    admins.removeWhere((admin) => admin.id == id);

    if (admins.length == initialLength) {
      throw Exception('Admin dengan ID $id tidak ditemukan');
    }

    await _saveAdmins(admins);

    return true;
  }

  // ==========================================
  // SAVE ADMIN LOCAL
  // ==========================================
  static Future<void> _saveAdmins(List<Admin> admins) async {
    final prefs = await SharedPreferences.getInstance();

    final data = admins.map((admin) => admin.toJson()).toList();

    await prefs.setString(storageKey, jsonEncode(data));
  }

  // ==========================================
  // RESET ADMIN
  // ==========================================
  static Future<void> resetAdmins() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(storageKey);
  }
}
