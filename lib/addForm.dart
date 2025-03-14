import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddForm extends StatefulWidget {
  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final _yearController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final CollectionReference vehiclesCollection = FirebaseFirestore.instance.collection('Vehicles');

  Future<void> _pickYear(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),  // ปรับให้เลือกได้ตั้งแต่ปี 1900
      lastDate: DateTime(2500),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: "Select Vehicle Year",
      fieldLabelText: "Enter Year",
      fieldHintText: "e.g. 2022",
    );

    if (pickedDate != null) {
      setState(() {
        _yearController.text = DateFormat('yyyy').format(pickedDate);  // แสดงแค่ปี
      });
    }
  }

  void addVehicle() async {
    if (_formKey.currentState?.validate() ?? false) {
      await vehiclesCollection.add({
        'brand': brandController.text.trim(),
        'model': modelController.text.trim(),
        'year': int.parse(_yearController.text),
      });

      brandController.clear();
      modelController.clear();
      _yearController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle added successfully!'), backgroundColor: Colors.green),
      );

      Navigator.pop(context); // ปิดหน้าหลังจากเพิ่มข้อมูล
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(213, 0, 0, 1),
        title: Text(
          'Add Vehicle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Vehicle Information",
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
                      return 'Please enter the brand name';
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
                      return 'Please enter the car model';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _yearController,
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
                    onPressed: addVehicle,
                    icon: Icon(Icons.add_circle_outline, color: Colors.white),
                    label: Text(
                      'Add Vehicle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
