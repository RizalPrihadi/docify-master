class MetaModel {
  int currentPage;
  int perPage;
  int total;
  int lastPage;

  MetaModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
    };
  }

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
    );
  }
}

class PaginationModel {
  List<dynamic> data;
  MetaModel meta;

  PaginationModel({required this.data, required this.meta});
}
