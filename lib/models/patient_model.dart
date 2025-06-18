import 'package:docify/utilities/abstract_model.dart';

class PatientModel extends UserModel {
  String? id;
  String email;
  String nama;
  String nomorTelepon;
  String jenisKelamin;
  String? password;
  String? foto;
  DateTime? createdAt;
  String? token;

  PatientModel({
    this.id,
    this.password,
    required this.email,
    required this.nama,
    required this.nomorTelepon,
    required this.jenisKelamin,
    this.foto,
    this.createdAt,
    this.token,
  });

  Map<String, dynamic> toJson() {
    String? dateString = createdAt?.toIso8601String();
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'nomor_telepon': nomorTelepon,
      'jenis_kelamin': jenisKelamin,
      'password': password,
      'foto': foto,
      'created_at': dateString,
      'token': token,
    };
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'nama': nama,
      'nomor_telepon': nomorTelepon,
      'jenis_kelamin': jenisKelamin,
      'foto': foto,
      'password': password,
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['created_at']);
    return PatientModel(
      id: json['id'],
      email: json['email'],
      nama: json['nama'],
      password: json['password'],
      nomorTelepon: json['nomor_telepon'],
      jenisKelamin: json['jenis_kelamin'],
      foto: json['foto'],
      createdAt: dateTime,
      token: json['token'],
    );
  }
}
