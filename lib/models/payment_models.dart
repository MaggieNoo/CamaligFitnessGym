class PaymentHistoryModel {
  final String id;
  final String paid;
  final String apaid;
  final String dt;
  final String tin;
  final String tout;
  final String itoken;

  PaymentHistoryModel({
    required this.id,
    required this.paid,
    required this.apaid,
    required this.dt,
    required this.tin,
    required this.tout,
    required this.itoken,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      id: json['id']?.toString() ?? '',
      paid: json['paid']?.toString() ?? '0',
      apaid: json['apaid']?.toString() ?? '0',
      dt: json['dt']?.toString() ?? '',
      tin: json['tin']?.toString() ?? '--:--',
      tout: json['tout']?.toString() ?? '--:--',
      itoken: json['itoken']?.toString() ?? '',
    );
  }

  double get paidAmount => double.tryParse(paid) ?? 0.0;
  double get apaidAmount => double.tryParse(apaid) ?? 0.0;
}

class EnrollmentDetailModel {
  final String id;
  final String program;
  final String branch;
  final String trainor;
  final String type;
  final String exp;
  final String itoken;

  EnrollmentDetailModel({
    required this.id,
    required this.program,
    required this.branch,
    required this.trainor,
    required this.type,
    required this.exp,
    required this.itoken,
  });

  factory EnrollmentDetailModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentDetailModel(
      id: json['id']?.toString() ?? '',
      program: json['program']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      trainor: json['trainor']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      exp: json['exp']?.toString() ?? '',
      itoken: json['itoken']?.toString() ?? '',
    );
  }
}
