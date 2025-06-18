import 'package:docify/utilities/user_roles.dart';

class StoredUser {
  dynamic data;
  UserRole role;

  StoredUser({required this.data, required this.role});

  Map<String, dynamic> toJson() {
    return {'data': data, 'role': role.name};
  }

  factory StoredUser.fromJson(Map<String, dynamic> json) {
    return StoredUser(
      data: json['data'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.pasien,
      ),
    );
  }
}
