import 'dart:convert';

import 'package:docify/utilities/abstract_model.dart';

class DoctorLocation {
  double latitude;
  double longitude;

  DoctorLocation({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  factory DoctorLocation.fromJson(Map<String, dynamic> json) {
    return DoctorLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class DoctorModel extends UserModel {
  String? id;
  String email;
  String nama;
  String spesialisasi;
  String rumahSakit;
  String biodata;
  String nomorTelepon;
  String? foto;
  String? password;
  DateTime? createdAt;
  DoctorLocation? lokasi;
  String? token;

  DoctorModel({
    this.id,
    required this.email,
    required this.nama,
    required this.spesialisasi,
    required this.rumahSakit,
    required this.biodata,
    required this.nomorTelepon,
    this.foto,
    this.password,
    this.createdAt,
    this.lokasi,
    this.token,
  });

  Map<String, dynamic> toJson() {
    String? dateString = createdAt?.toIso8601String();
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'spesialisasi': spesialisasi,
      'rumah_sakit': rumahSakit,
      'biodata': biodata,
      'password': password,
      'nomor_telepon': nomorTelepon,
      'foto': foto,
      'created_at': dateString,
      'lokasi': lokasi?.toJson(),
      'token': token,
    };
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'nama': nama,
      'spesialisasi': spesialisasi,
      'rumah_sakit': rumahSakit,
      'biodata': biodata,
      'password': password,
      'nomor_telepon': nomorTelepon,
      'foto': foto,
    };
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['created_at']);
    return DoctorModel(
      id: json['id'],
      email: json['email'],
      nama: json['nama'],
      spesialisasi: json['spesialisasi'],
      rumahSakit: json['rumah_sakit'],
      biodata: json['biodata'],
      password: json['password'],
      nomorTelepon: json['nomor_telepon'],
      foto: json['foto'],
      createdAt: dateTime,
      lokasi:
          json['lokasi'] != null
              ? DoctorLocation.fromJson(jsonDecode(json['lokasi']))
              : null,
      token: json['token'],
    );
  }
}
