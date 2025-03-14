import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addForm.dart';
import 'updateForm.dart';

class ShowVehicles extends StatefulWidget {
  const ShowVehicles({super.key});

  @override
  State<ShowVehicles> createState() => _ShowVehiclesState();
}

class _ShowVehiclesState extends State<ShowVehicles> {
  CollectionReference vehiclesCollection = FirebaseFirestore.instance.collection('Vehicles');

  void deleteVehicles(String documentId) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this vehicle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await vehiclesCollection.doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle deleted successfully'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 129, 129, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(213, 0, 0, 1),
        title: Text(
          'Show Vehicles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: vehiclesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No vehicles data available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          var documents = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;
              String brand = data['brand'] ?? 'No Brand Name';
              String model = data['model'] ?? 'No Model';
              
              String documentId = documents[index].id;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Icon(Icons.directions_car, color: Colors.blue, size: 30),
                  title: Text(
                    brand,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Model: $model', style: TextStyle(fontSize: 16)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateForm(documentId: documentId),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit, color: Colors.amber),
                        tooltip: 'Edit Vehicle',
                      ),
                      IconButton(
                        onPressed: () => deleteVehicles(documentId),
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Vehicle',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddForm()),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: Colors.amber,
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
