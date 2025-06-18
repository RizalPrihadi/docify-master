class MedicalRecordModel {
  String? id;
  String catatan;
  String file;
  DateTime? createdAt;

  MedicalRecordModel({
    this.id,
    required this.catatan,
    required this.file,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    String? dateString = createdAt?.toIso8601String();
    return {
      'id': id,
      'catatan': catatan,
      'file': file,
      'created_at': dateString,
    };
  }

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['created_at']);
    return MedicalRecordModel(
      id: json['id'],
      catatan: json['catatan'],
      file: json['file'],
      createdAt: dateTime,
    );
  }
}
