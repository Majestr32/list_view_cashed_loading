
import 'package:hive/hive.dart';

import 'models/user_contact.dart';

class Boxes{
  static Box<UserContact> getUsers() => Hive.box<UserContact>('users');
}