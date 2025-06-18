import 'package:docify/models/doctor_model.dart';
import 'package:docify/models/medical_record_model.dart';
import 'package:docify/models/patient_model.dart';
import 'package:docify/utilities/appointment_status.dart';

class AppointmentModel {
  String? id;
  DoctorModel? doctor;
  String? doctorId;
  PatientModel? patient;
  AppointmentStatus status;
  DateTime waktu;
  DateTime? createdAt;
  MedicalRecordModel? medicalRecord;

  AppointmentModel({
    this.id,
    required this.status,
    required this.waktu,
    this.createdAt,
    this.doctor,
    this.patient,
    this.doctorId,
    this.medicalRecord,
  });

  Map<String, dynamic> toJson() {
    String? timeString = waktu.toIso8601String();
    String? createdAtString = createdAt?.toIso8601String();

    return {
      'id': id,
      'status': status.name,
      'waktu': timeString,
      'created_at': createdAtString,
      'dokter': doctor?.toJson(),
      'id_dokter': doctorId,
      'pasien': patient?.toJson(),
      'rekam_medis': medicalRecord?.toJson(),
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    DateTime timeString = DateTime.parse(json['waktu']);
    DateTime createdAtString = DateTime.parse(json['created_at']);
    AppointmentStatus parsedStatus = AppointmentStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => AppointmentStatus.belum,
    );

    return AppointmentModel(
      id: json['id'],
      status: parsedStatus,
      waktu: timeString,
      createdAt: createdAtString,
      patient:
          json['pasien'] != null
              ? PatientModel.fromJson(json['pasien'] as Map<String, dynamic>)
              : null,
      doctor:
          json['dokter'] != null
              ? DoctorModel.fromJson(json['dokter'] as Map<String, dynamic>)
              : null,
      medicalRecord:
          json['rekam_medis'] != null
              ? MedicalRecordModel.fromJson(json['rekam_medis'])
              : null,
    );
  }
}
