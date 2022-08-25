
import 'dart:convert';

import 'package:learnings/models/user_contact.dart';
import 'package:http/http.dart' as http;


class UserService{
  final String api = "https://randomuser.me/api/";
  Future<UserContact> getRandomUser() async{
    final response = await http.get(Uri.parse(api));
    final jsonModel = json.decode(response.body) as Map<String, dynamic>;
    final result = jsonModel["results"].first;
    final firstName = result["name"]["first"];
    final lastName = result["name"]["last"];
    final email = result["email"];
    return UserContact(firstName: firstName, lastName: lastName, email: email);
  }
  Future<List<UserContact>> getRandomUsers(int count) async{
    List<UserContact> contacts = [];
    for(int i = 0; i < count; i++){
      contacts.add(await getRandomUser());
    }
    return contacts;
  }
}