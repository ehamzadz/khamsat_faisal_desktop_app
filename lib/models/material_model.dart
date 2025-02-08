// 3. lib/models/material_model.dart
// ignore_for_file: non_constant_identifier_names

enum MaterialStatus { pending, inProgress, sdfsd, canceled, completed }

class MaterialModel {
  int? id;
  String name;
  String number;
  String serialNumber;
  String generalNumber;
  String beneficiary;
  MaterialStatus status;
  String created_at;
  String updated_at_transfert;
  String updated_at_exit;

  MaterialModel({
    this.id,
    required this.name,
    required this.number,
    required this.serialNumber,
    required this.generalNumber,
    required this.beneficiary,
    this.status = MaterialStatus.pending,
    required this.created_at,
    this.updated_at_transfert = '/',
    this.updated_at_exit = '/',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'number': number,
      'serialNumber': serialNumber,
      'generalNumber': generalNumber,
      'beneficiary': beneficiary,
      'status': status.index,
      'created_at': created_at,
      'updated_at_transfert': updated_at_transfert,
      'updated_at_exit': updated_at_exit,
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
      created_at: map['created_at'],
      updated_at_transfert: map['updated_at_transfert'],
      updated_at_exit: map['updated_at_exit'],
    );
  }
}
