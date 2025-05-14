import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

class RefuellingBottomSheet {
  static String? selectedFuelType;
  static File? _receiptImage;


  static Future<void> _pickImageAndExtractText(
      StateSetter setModalState,
      ImageSource source,
      TextEditingController controller,
      ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [AndroidUiSettings(toolbarTitle: 'Crop Image')],
      );
      if (croppedFile == null) return;

      File image = File(croppedFile.path);
      setModalState(() => _receiptImage = image);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.mindee.net/v1/products/Athestic/car_meter_reading/v1/predict_async'),
      );
      request.headers['Authorization'] = 'Token 58f7ae84007f9343b706fd21bdbb4681';
      request.files.add(await http.MultipartFile.fromPath(
        'document',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 202) {
        final jobId = jsonResponse['job']['id'];

        for (int i = 0; i < 5; i++) {
          await Future.delayed(Duration(seconds: 2));
          final poll = await http.get(
            Uri.parse('https://api.mindee.net/v1/products/Athestic/car_meter_reading/v1/documents/queue/$jobId'),
            headers: {'Authorization': 'Token 58f7ae84007f9343b706fd21bdbb4681'},
          );

          if (poll.statusCode == 200) {
            final pollData = jsonDecode(poll.body);
            final prediction = pollData['document']['inference']['prediction'];
            final odometerList = prediction['odometer_reading'];

            if (odometerList is List && odometerList.isNotEmpty) {
              final odometerVal = odometerList[0]['value'];
              setModalState(() => controller.text = odometerVal?.toString() ?? "");
              return;
            } else {
              setModalState(() => controller.text = "Not found");
              return;
            }
          }
        }

        setModalState(() => controller.text = "OCR timeout");
      } else {
        setModalState(() => controller.text = "Error reading");
      }
    } catch (e) {
      print("❌ OCR error: $e");
      setModalState(() => controller.text = "Error reading");
    }
  }

  static void show({
    required BuildContext context,
    required Map<String, dynamic> vehicleData,
    required int selectedVehicleId,
    required int driverId,
  }) {
    final meterReadingController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    // String? selectedFuelType;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final media = MediaQuery.of(context);
        final isLandscape = media.orientation == Orientation.landscape;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 600;

            return Padding(
              padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  bool _isSubmitting = false;

                  return Container(
                    padding: EdgeInsets.all(16),
                    height: media.size.height * (isLandscape ? 1.0 : 0.70),
                    child: SingleChildScrollView(
                      child: _isSubmitting
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Lottie.asset(
                                'assets/Animation.json',
                                fit: BoxFit.cover,
                                repeat: false,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.check_circle, size: 80, color: Colors.green);
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Fuel Record Added!",
                                style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                          : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Add Fuel Record", style: TextStyle(fontSize: isTablet ? 20 : 18)),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text("Cancel",
                                    style: TextStyle(color: Colors.teal, fontSize: isTablet ? 18 : 16)),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          _buildVehicleCard(vehicleData),
                          SizedBox(height: 15),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            children: ["Petrol", "Diesel", "CNG", "Electric"].map((type) {
                              return ChoiceChip(
                                label: Text(type, style: TextStyle(fontSize: isTablet ? 16 : 14)),
                                selected: selectedFuelType == type,
                                onSelected: (isSelected) {
                                  if (isSelected) setModalState(() => selectedFuelType = type);
                                },
                                selectedColor: Colors.teal,
                                labelStyle: TextStyle(
                                  color: selectedFuelType == type ? Colors.white : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Add Details",
                                style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: meterReadingController,
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            onTap: () => _pickImageAndExtractText(setModalState, ImageSource.camera, meterReadingController),
                            decoration: InputDecoration(
                              labelText: "Current meter reading",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Quantity",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Price(₹)",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Upload Receipt",
                                style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _showImagePicker(setModalState),
                            child: Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.teal, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.file_upload, color: Colors.teal),
                                  SizedBox(width: 10),
                                  Text(
                                    _receiptImage != null ? "File Selected" : "Upload here",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor, fontSize: isTablet ? 16 : 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text("JPG, PNG, PDF Supported",
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryColor,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              minimumSize: Size(double.infinity, 50),
                            ),
                              onPressed: () async {
                                if (meterReadingController.text.isNotEmpty &&
                                    quantityController.text.isNotEmpty &&
                                    priceController.text.isNotEmpty &&
                                    _receiptImage != null &&
                                    selectedFuelType != null) {
                                  try {
                                    setModalState(() => _isSubmitting = true);

                                    Position position = await Geolocator.getCurrentPosition(
                                      desiredAccuracy: LocationAccuracy.high,
                                    );

                                    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                                    final locationString =
                                        "${position.latitude} ${position.longitude} ${position.altitude} ${position.accuracy} $timestamp";

                                    var request = http.MultipartRequest(
                                      'POST',
                                      Uri.parse('http://192.168.1.110:8081/api/Driver/FuelDetailInsert'),
                                    );

                                    request.fields['DriverId'] = driverId.toString();
                                    request.fields['VehiclesId'] = selectedVehicleId.toString();
                                    request.fields['FuelPrice'] = priceController.text.trim();
                                    request.fields['MeterReading'] = meterReadingController.text.trim();
                                    request.fields['FuelQuantity'] = quantityController.text.trim();
                                    request.fields['location'] = locationString;

                                    request.files.add(await http.MultipartFile.fromPath(
                                      'ReceiptImage',
                                      _receiptImage!.path,
                                      contentType: MediaType('image', 'jpeg'),
                                    ));

                                    final response = await request.send();
                                    final respStr = await response.stream.bytesToString();

                                    if (response.statusCode == 200) {
                                      print("✅ Fuel record submitted: $respStr");
                                      await Future.delayed(Duration(seconds: 2));
                                      Navigator.pop(context);
                                    } else {
                                      setModalState(() => _isSubmitting = false);
                                      print("❌ Submission failed: ${response.statusCode}, $respStr");
                                    }
                                  } catch (e) {
                                    setModalState(() => _isSubmitting = false);
                                    print("❌ Submission error: $e");
                                  }
                                } else {
                                  print("⚠️ Please fill all fields and upload a receipt");
                                  print("Meter Reading: ${meterReadingController.text}");
                                  print("Quantity: ${quantityController.text}");
                                  print("Price: ${priceController.text}");
                                  print("Receipt Image: ${_receiptImage != null}");
                                  print("Fuel Type: $selectedFuelType");
                                }
                              },

                              child: Text("Submit", style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  static void _showImagePicker(StateSetter setModalState) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setModalState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }


  static Widget _buildVehicleCard(Map<String, dynamic> vehicleData) {
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
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.car_repair, size: 50, color: Colors.grey),
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
}
