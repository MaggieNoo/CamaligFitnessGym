class UserModel {
  final String id;
  final String status;
  final String firstName;
  final String middleName;
  final String lastName;
  final String birthday;
  final String gender;
  final String email;
  final String phone;
  final String? phone2;
  final String address;
  final String? company;
  final String lastUpdated;
  final String token;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.status,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.birthday,
    required this.gender,
    required this.email,
    required this.phone,
    this.phone2,
    required this.address,
    this.company,
    required this.lastUpdated,
    required this.token,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '0',
      firstName: json['fn'] ?? '',
      middleName: json['mn'] ?? '',
      lastName: json['ln'] ?? '',
      birthday: json['bday'] ?? '',
      gender: json['gender']?.toString() ?? '0',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      phone2: json['phone2'],
      address: json['address'] ?? '',
      company: json['company'],
      lastUpdated: json['last_updated'] ?? '',
      token: json['token'] ?? '',
      profileImage: json['profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'fn': firstName,
      'mn': middleName,
      'ln': lastName,
      'bday': birthday,
      'gender': gender,
      'email': email,
      'phone': phone,
      'phone2': phone2,
      'address': address,
      'company': company,
      'last_updated': lastUpdated,
      'token': token,
      'profile': profileImage,
    };
  }

  String get fullName => '$firstName $middleName $lastName'.trim();
}
