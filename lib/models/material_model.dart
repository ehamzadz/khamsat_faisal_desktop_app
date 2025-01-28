// 3. lib/models/material_model.dart
enum MaterialStatus { pending, inProgress, sdfsd, canceled, completed }

class MaterialModel {
  int? id;
  String name;
  String number;
  String serialNumber;
  String generalNumber;
  String beneficiary;
  MaterialStatus status;

  MaterialModel({
    this.id,
    required this.name,
    required this.number,
    required this.serialNumber,
    required this.generalNumber,
    required this.beneficiary,
    this.status = MaterialStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'numver': number,
      'serialNumber': serialNumber,
      'generalNumber': generalNumber,
      'beneficiary': beneficiary,
      'status': status.index,
    };
  }

  static MaterialModel fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'],
      name: map['name'],
      number: map['number'],
      serialNumber: map['serialNumber'],
      generalNumber: map['generalNumber'],
      beneficiary: map['beneficiary'],
      status: MaterialStatus.values[map['status']],
    );
  }
}
