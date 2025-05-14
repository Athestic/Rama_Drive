import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'colors.dart';

late List<Map<String, dynamic>> maintenanceTypes;
int? selectedMaintenanceTypeId;
File? _selectedFile;

TextEditingController serviceCostController = TextEditingController();
TextEditingController remarkController = TextEditingController();
TextEditingController meterreadingController = TextEditingController();

Future<void> fetchMaintenanceTypes() async {
  final url = "http://192.168.1.110:8081/api/Driver/GetAllMaintenanceTypes";
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      maintenanceTypes = data.map((item) {
        return {
          "id": item["maintenancTypeId"],
          "name": item["maintenancType"]
        };
      }).toList();
    }
  } catch (e) {
    print("Error fetching maintenance types: $e");
  }
}

Future<void> createVehicleMaintenance({
  required int maintenanceTypeId,
  required int serviceCost,
  required int vehicleId,
  required int driverId,
  String? remark,
  File? receiptImage,
}) async {
  final String apiUrl = "http://192.168.1.110:8081/api/Driver/CreateVehicleMaintenance";

  var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
  request.fields["VehicleId"] = vehicleId.toString();
  request.fields["DriverId"] = driverId.toString();
  request.fields["MaintenancTypeId"] = maintenanceTypeId.toString();
  request.fields["ServiceCost"] = serviceCost.toString();
  request.fields["Remark"] = remark ?? "";

  if (receiptImage != null) {
    request.files.add(await http.MultipartFile.fromPath("ServiceRecieptImage", receiptImage.path));
  }

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      print("✅ Maintenance record added successfully");
    } else {
      print("❌ Failed. Code: ${response.statusCode}");
    }
  } catch (e) {
    print("🔥 Error: $e");
  }
}

void showMaintenanceBottomSheet(BuildContext context, Map<String, dynamic>? vehicleData, int vehicleId, int driverId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Add Service Record", style: TextStyle(fontSize:  18)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text("Cancel", style: TextStyle(color: Colors.teal, fontSize: 16)),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildVehicleCard(vehicleData ?? {}),
                    SizedBox(height: 16),
                    TextField(
                      controller: meterreadingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Meter Reading", border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
                    ),
                    SizedBox(height: 12),
                    _buildMaintenanceDropdown(setModalState),
                    SizedBox(height: 12),
                    TextField(
                      controller: serviceCostController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Service Cost(₹)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: remarkController,
                      decoration: InputDecoration(labelText: "Remarks (Optional)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    _buildUploadImageButton(setModalState),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        if (selectedMaintenanceTypeId == null || serviceCostController.text.trim().isEmpty) return;

                        int? cost = int.tryParse(serviceCostController.text.trim());
                        if (cost == null || cost <= 0) return;

                        await createVehicleMaintenance(
                          maintenanceTypeId: selectedMaintenanceTypeId!,
                          serviceCost: cost,
                          remark: remarkController.text,
                          receiptImage: _selectedFile,
                          driverId: driverId,
                          vehicleId: vehicleId,
                        );

                        setModalState(() {
                          serviceCostController.clear();
                          remarkController.clear();
                          meterreadingController.clear();
                          _selectedFile = null;
                          selectedMaintenanceTypeId = null;
                        });

                        Navigator.pop(context);
                      },
                      child: Text("Submit", style: TextStyle(color: Colors.white)),

                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildMaintenanceDropdown(void Function(void Function()) setModalState) {
  return FutureBuilder(
    future: fetchMaintenanceTypes(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(
          hintText: "Select Maintenance Type",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        value: selectedMaintenanceTypeId,
        items: maintenanceTypes.map((type) {
          return DropdownMenuItem<int>(value: type["id"], child: Text(type["name"]));
        }).toList(),
        onChanged: (value) {
          setModalState(() => selectedMaintenanceTypeId = value);
        },
      );
    },
  );
}

Widget _buildUploadImageButton(void Function(void Function()) setModalState) {
  return GestureDetector(
    onTap: () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setModalState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(Icons.image_outlined, color: Colors.grey.shade600),
            SizedBox(width: 10),
            Text(
              _selectedFile != null ? _selectedFile!.path.split('/').last : "Upload Receipt Image",
              style: TextStyle(color: Colors.black87),
            ),
          ]),
          Icon(Icons.upload, color: Colors.grey.shade600),
        ],
      ),
    ),
  );
}

Widget _buildVehicleCard(Map<String, dynamic> vehicleData) {
  final imageUrl = vehicleData["vehicleImage"] ?? "";
  return Card(
    color: Colors.grey.shade200,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl.startsWith("http") ? imageUrl : "http://192.168.1.110:8081$imageUrl",
              height: 50,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.car_repair, size: 50, color: Colors.grey),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicleData["numberPlate"] ?? "N/A", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(vehicleData["vM_Name"] ?? "Unknown", style: TextStyle(color: Colors.grey.shade800)),
              ],
            ),
          ),
          Chip(
            label: Text("12-Mar-2025", style: TextStyle(color: Colors.white, fontSize: 10)),
            backgroundColor: AppColors.secondaryColor,
          ),
        ],
      ),
    ),
  );
}
