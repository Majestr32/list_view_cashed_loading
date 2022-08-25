

import 'package:hive/hive.dart';

part 'user_contact.g.dart';

@HiveType(typeId: 0)
class UserContact extends HiveObject{
  @HiveField(0)
  final String firstName;
  @HiveField(1)
  final String lastName;
  @HiveField(2)
  final String email;

  UserContact({
    required this.firstName,
    required this.lastName,
    required this.email,
  });
}