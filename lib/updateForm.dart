import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpdateForm extends StatefulWidget {
  final String documentId;
  const UpdateForm({super.key, required this.documentId});
  
  @override
  State<UpdateForm> createState() => _UpdateFormState();
}

class _UpdateFormState extends State<UpdateForm> {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final CollectionReference vehiclesCollection = FirebaseFirestore.instance.collection('Vehicles');

  bool isLoading = false;

  Future<void> _pickYear(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900), 
      lastDate: DateTime(2500),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: "Select Vehicle Year",
      fieldLabelText: "Enter Year",
      fieldHintText: "e.g. 2022",
    );

    if (pickedDate != null) {
      setState(() {
        yearController.text = DateFormat('yyyy').format(pickedDate);
      });
    }
  }

  void updateVehicles() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        await vehiclesCollection.doc(widget.documentId).update({
          'brand': brandController.text.trim(),
          'model': modelController.text.trim(),
          'year': int.parse(yearController.text),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle updated successfully!'), backgroundColor: Colors.green),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating vehicle: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExistingVehicles();
  }

  void _loadExistingVehicles() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot docSnapshot = await vehiclesCollection.doc(widget.documentId).get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          brandController.text = data['brand'] ?? '';
          modelController.text = data['model'] ?? '';
          yearController.text = data['year']?.toString() ?? '';
        });
      }
    } catch (e) {
      print('Error loading vehicle data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(213, 0, 0, 1),
        title: Text(
          'Update Vehicle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Vehicle Details",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: brandController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Brand Name',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a brand name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: modelController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Model',
                          prefixIcon: Icon(Icons.directions_car),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a car model';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: yearController,
                        readOnly: true, // ป้องกันการพิมพ์
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Year',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onTap: () => _pickYear(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the car year';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : updateVehicles,
                          icon: Icon(Icons.update, color: Colors.white),
                          label: Text('Update Vehicle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
