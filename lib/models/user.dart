import 'package:sungoods/models/user_role.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

// Helper function to safely parse int, returns 0 if null or invalid
int _safeParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0; // Handle booleans
  if (value is String) {
    if (value.isEmpty) return 0;
    try {
      return int.parse(value);
    } catch (_) {
      return 0;
    }
  }
  return 0;
}

class User {
  final int id;
  final String name;
  final String? father_name;
  final String? address;
  final String? bkash_number;
  final String? dob;
  final String? blood_group;
  final String email;
  final String? image;
  final String? short_bio;
  final String? mobile;
  final String? present_address;
  final String? permanent_address;
  final String? nid;
  final String? tin_number;
  final String? ssc_passing;
  final String? ssc_registration;
  final String? health_history;
  final UserRole role;
  final String? user_type;
  final bool is_admin;
  final int is_approve; // Added is_approve field

  User({
    required this.id,
    required this.name,
    this.father_name,
    this.address,
    this.bkash_number,
    this.dob,
    this.blood_group,
    required this.email,
    this.image,
    this.short_bio,
    this.mobile,
    this.present_address,
    this.permanent_address,
    this.nid,
    this.tin_number,
    this.ssc_passing,
    this.ssc_registration,
    this.health_history,
    required this.role,
    this.user_type,
    required this.is_admin,
    required this.is_approve, // Added to constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('User.fromJson received JSON: $json'); // Debug print
    final Map<String, dynamic> userData = json['data'] ?? json; // Handle nested 'data' key

    return User(
      id: _safeParseInt(userData['id']), // Safe parsing for id
      name: userData['name'],
      father_name: userData['father_name'],
      address: userData['address'],
      bkash_number: userData['bkash_number'],
      dob: userData['dob'],
      blood_group: userData['blood'], // Correctly map 'blood' to 'blood_group'
      email: userData['email'],
      image: userData['image'],
      short_bio: userData['short_bio'],
      mobile: userData['mobile'],
      present_address: userData['present_address'],
      permanent_address: userData['permanent_address'],
      nid: userData['nid'],
      tin_number: userData['tin_number'],
      ssc_passing: userData['ssc_passing'],
      ssc_registration: userData['ssc_registration'],
      health_history: userData['health_history'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == userData['role'],
        orElse: () =>
            UserRole.seller, // Default to seller if role not found or null
      ),
      user_type: userData['user_type'],
      is_admin: userData['is_admin'] ?? false, // Default to false if not provided
      is_approve: _safeParseInt(userData['is_approve']), // Safely parse to int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'father_name': father_name,
      'address': address,
      'bkash_number': bkash_number,
      'dob': dob,
      'blood_group': blood_group,
      'email': email,
      'image': image,
      'short_bio': short_bio,
      'mobile': mobile,
      'present_address': present_address,
      'permanent_address': permanent_address,
      'nid': nid,
      'tin_number': tin_number,
      'ssc_passing': ssc_passing,
      'ssc_registration': ssc_registration,
      'health_history': health_history,
      'role': role.toString().split('.').last, // Convert enum to string
      'user_type': user_type,
      'is_admin': is_admin,
      'is_approve': is_approve, // Added to toJson
    };
  }
}
