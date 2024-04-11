// ignore_for_file: avoid_print, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  void approveSeller(String email) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Users")
        .where("email", isEqualTo: email)
        .get();
    var sellerDoc = snapshot.docs.first;
    sellerDoc.reference.update({"approved": true});
    QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection("admin_request_database")
        .where("email", isEqualTo: email)
        .get();
    var adminDoc = adminSnapshot.docs.first;
    adminDoc.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("admin_request_database")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: ListView.builder(
              itemCount: data!.docs.length,
              itemBuilder: (context, index) {
                final userData = data.docs[index];
                final userId = userData.id;

                Map<String, dynamic> map =
                    userData.data() as Map<String, dynamic>;
                print(map['userType']);

                return Card(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Users")
                        .doc(map['Id'])
                        .snapshots(),
                    builder: (context, usnapshot) {
                      if (usnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }
                      return ListTile(
                        title: Text(map["name"]),
                        subtitle: Text(usnapshot.data!['userType'] == 1
                            ? "Doctor Id: ${usnapshot.data!["doctorId"]}"
                            : "Store Id: ${usnapshot.data!["storeId"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                approveSeller(map["email"] as String);
                              },
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                                weight: 10,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                // await FirebaseFirestore.instance
                                //     .collection("denied_admin")
                                //     .add(
                                //   {
                                //     "username": map["username"],
                                //     "email": map["email"],
                                //     "password": map["password"],
                                //   },
                                // );

                                await FirebaseFirestore.instance
                                    .collection("admin_request_database")
                                    .doc(userId)
                                    .delete();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                weight: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/*

 Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: const Text("Company Name"),
                  subtitle: const Text("companyemail@gmail.com"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                          weight: 10,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          weight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

*/