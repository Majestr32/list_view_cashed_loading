import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:learnings/boxes.dart';
import 'package:learnings/services/user_service.dart';

import 'models/user_contact.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserContactAdapter());
  await Hive.openBox<UserContact>('users');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  List<UserContact> users = [];
  final int itemsCount = 30;

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    UserService userService = UserService();
    final connectivity = (Connectivity().checkConnectivity());
    connectivity.then((connResult){
      if(connResult == ConnectivityResult.none){
        return;
      }
      userService.getRandomUsers(itemsCount).then((value) {
        users = value;
        final box = Boxes.getUsers();
        box.clear().then((_){
          box.addAll(value);
          setState((){

          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cached Network Image'),
      ),
      body: RefreshIndicator(
        onRefresh: () async{
          final connectivity = await (Connectivity().checkConnectivity());
          if(connectivity == ConnectivityResult.none){
            return;
          }
          await DefaultCacheManager().emptyCache();
          imageCache.clear();
          imageCache.clearLiveImages();
          UserService userService = UserService();
          final newUsers = await userService.getRandomUsers(itemsCount);
          await Boxes.getUsers().clear();
          Boxes.getUsers().addAll(newUsers);
          await Future.delayed(Duration(seconds: 1));
          setState((){

          });
        },
        child: ValueListenableBuilder<Box<UserContact>>(
          valueListenable: Boxes.getUsers().listenable(),
          builder: (context, box, _) {
            final users = box.values.toList();
            return ListView.builder(
            physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(8),
              itemCount: itemsCount,
              itemBuilder: (context, i){
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 18),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedNetworkImage(
                        key: UniqueKey(),
                          imageUrl: 'https://source.unsplash.com/random?sig=$i',
                        placeholder: (context, url) => Center(child: Container(color: Colors.black12,)),
                        maxHeightDiskCache: 100,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      box.isNotEmpty ? "${users[i].firstName} ${users[i].lastName}" : 'Image ${i+1}',
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      box.isNotEmpty ? users[i].email : 'Subtitle'
                    ),
                  ),
                );
          });
          },
        ),
      )
    );
  }
}
