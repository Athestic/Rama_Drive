import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';
import 'package:http_parser/http_parser.dart';

void showMaintainTripBottomSheet(BuildContext context, int vehicleId, int driverId,  List<dynamic> fuelLogs, ) {
  File? _image;
  String? extractedText;
  bool isTripStarted = false;
  String? locationTripStatus;
  int? locationTripId;
  int? fuelId;
  bool hasFetchedStatus = false;

  final GlobalKey<SlideActionState> _key = GlobalKey();

  Future<void> _fetchTripStatus(StateSetter setModalState) async {
    final url = "http://192.168.1.110:8081/api/Admin/GetlastbyvehicleId?vehiclesId=$vehicleId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        locationTripStatus = data['status'];
        locationTripId = data['locationTripId'];
        if (fuelLogs.isNotEmpty && fuelLogs[0]['fuelId'] != null) {
          fuelId = fuelLogs[0]['fuelId'];
        } else {
          fuelId = null;
        }


        print("📡 Trip Status: $locationTripStatus, TripId: $locationTripId, FuelId: $fuelId");

        setModalState(() {
          isTripStarted = locationTripStatus == "P";
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (isTripStarted && locationTripId != null) {
          prefs.setInt('locationTripId', locationTripId!);
        } else {
          prefs.remove('locationTripId');
        }
      } else {
        print("❌ Failed to fetch trip status: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching trip status: $e");
    }
  }

  Future<void> _pickImageAndExtractText(StateSetter setModalState, ImageSource source) async {
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
      setModalState(() {
        _image = image;
        extractedText = null;
      });

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
            print("📄 Poll response: $pollData");

            final prediction = pollData['document']['inference']['prediction'];
            final odometerList = prediction['odometer_reading'];

            if (odometerList is List && odometerList.isNotEmpty) {
              final odometerVal = odometerList[0]['value'];
              setModalState(() => extractedText = odometerVal?.toString() ?? "Not found");
              return;
            } else {
              setModalState(() => extractedText = "Not found");
              return;
            }
          }
        }

        setModalState(() => extractedText = "OCR timeout");
      } else {
        setModalState(() => extractedText = "Error reading");
      }
    } catch (e) {
      print("❌ OCR error: $e");
      setModalState(() => extractedText = "Error reading");
    }
  }


  Future<void> _submitTrip(StateSetter setModalState) async {
    if (extractedText == null || extractedText == "Not found") {
      setModalState(() {
        extractedText = "Valid meter reading required.";
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String locationStr = "${position.latitude} ${position.longitude} 0 0 0";

      final bool isEndingTrip = isTripStarted;
      final uri = isEndingTrip
          ? "http://192.168.1.110:8081/api/Driver/DropDriverLocation"
          : "http://192.168.1.110:8081/api/Driver/PickRamaDriverLocation";

      final body = isEndingTrip
          ? {
        "locationTripId": locationTripId,
        "finalReading": extractedText,
        "location": locationStr,
      }
          : {
        "vehiclesId": vehicleId,
        "initialReading": extractedText,
        "location": locationStr,
        "fuelId": fuelId,
        "driverId": driverId,
      };

      print("📤 Submitting trip: $body");

      http.Response response;

      if (isEndingTrip) {
        // PATCH for ending the trip
        response = await http.patch(
          Uri.parse(uri),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      } else {
        // POST for starting the trip
        response = await http.post(
          Uri.parse(uri),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      }

      print("📬 API Response: ${response.statusCode} -> ${response.body}");

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (!isEndingTrip) {
          final responseJson = jsonDecode(response.body);
          await prefs.setInt('locationTripId', responseJson['locationTripId']);
        } else {
          await prefs.remove('locationTripId');
        }

        setModalState(() {
          _image = null;
          extractedText = null;
          isTripStarted = !isTripStarted;
        });

        if (isEndingTrip) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                Future.delayed(const Duration(seconds: 3), () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pop(context); // Close bottom sheet
                });

                return AlertDialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Lottie.asset(
                        'assets/Animation.json',
                        fit: BoxFit.cover,
                        animate: true,
                        repeat: true,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.check_circle, size: 80, color: Colors.green);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          });
        }
 else {
          Navigator.pop(context); // Close bottom sheet for start trip
        }
      } else {
        setModalState(() {
          extractedText = "Failed to submit trip";
        });
      }
    } catch (e) {
      print("❌ Error submitting trip: $e");
      setModalState(() {
        extractedText = "Submission error";
      });
    }
  }


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            if (!hasFetchedStatus) {
              _fetchTripStatus(setModalState);
              hasFetchedStatus = true;
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            isTripStarted ? "End Trip" : "Start Trip",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text("Cancel", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isTripStarted ? "Capture End Meter Reading" : "Capture Start Meter Reading",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 12),

                    _image != null
                        ? Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, height: 170),
                        ),
                        SizedBox(height: 10),
                        Text(
                          extractedText != null
                              ? "Detected Reading: $extractedText"
                              : "Extracting...",
                          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                        : GestureDetector(
                      onTap: () => _pickImageAndExtractText(setModalState, ImageSource.camera),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.teal.withOpacity(0.05),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt, size: 45, color: Colors.teal),
                              SizedBox(height: 8),
                              Text(
                                "Tap to Capture or Upload",
                                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),

                    SlideAction(
                      key: _key,
                      text: isTripStarted ? "Swipe to End Trip" : "Swipe to Start Trip",
                      outerColor: Colors.teal,
                      innerColor: Colors.white,
                      elevation: 4,
                      textStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      sliderButtonIcon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14),
                        child: Icon(Icons.arrow_back_ios, color: Colors.teal),
                      ),
                      onSubmit: () async {
                        await _submitTrip(setModalState);
                        setModalState(() {
                          _key.currentState?.reset();
                        });
                      },
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
}




