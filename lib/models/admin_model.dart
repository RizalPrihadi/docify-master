import 'package:docify/utilities/abstract_model.dart';

class AdminModel extends UserModel {
  String id;
  String email;
  String? token;

  AdminModel({
    required this.id,
    required this.email,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'token' : token
    };
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'],
      email: json['email'],
      token: json['token'],
    );
  }
}
