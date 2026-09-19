class NisitRecordModel {
  String nisitId;
  String nisitFirstName;
  String nisitLastName;
  String nisitEmail;
  int phoneNumber;
  String? referenceId;

  static const collectionName = 'nisit_records';

  NisitRecordModel({
    required this.nisitId,
    required this.nisitFirstName,
    required this.nisitLastName,
    required this.nisitEmail,
    required this.phoneNumber,
    this.referenceId,
  });

  factory NisitRecordModel.fromJson(Map<String, dynamic> json) {
    return NisitRecordModel(
      nisitId: json['nisitId'] ?? '',
      nisitFirstName: json['nisitFirstName'] ?? '',
      nisitLastName: json['nisitLastName'] ?? '',
      nisitEmail: json['nisitEmail'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nisitId' : nisitId,
      'nisitFirstName' : nisitFirstName,
      'nisitLastName' : nisitLastName,
      'nisitEmail' : nisitEmail,
      'PhoneNumber' : phoneNumber,
    };
  }
}