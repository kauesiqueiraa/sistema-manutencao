class UserModel {
  final String id;
  final String formattedName;
  final String givenName;
  final String familyName;
  final String userName;
  final String department;

  UserModel({
    required this.id,
    required this.formattedName,
    required this.givenName,
    required this.familyName,
    required this.userName,
    required this.department,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>;
    return UserModel(
      id: json['id'],
      formattedName: name['formatted'],
      givenName: name['givenName'],
      familyName: name['familyName'],
      userName: json['userName'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {
        'formatted': formattedName,
        'givenName': givenName,
        'familyName': familyName,
      },
      'userName': userName,
      'department': department,
    };
  }
} 