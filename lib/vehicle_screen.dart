import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'colors.dart';
import 'home.dart';
import 'homeadmin.dart';
import 'Add_Driver.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'admingetalldriver.dart';


class AddVehicleScreen extends StatefulWidget {
  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  int? selectedManufacturerId;
  int? selectedModelId;
  List<Map<String, dynamic>> manufacturers = [];
  List<Map<String, dynamic>> models = [];
  int? selectedCategoryId;
  int? selectedLocationId;
  String? selectedColor;
  List<Map<String, dynamic>> Vehiclegroup = [];
  int? selectedVehiclegroupId;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> locations = [];
  List<String> colors = [
    "Red",
    "Blue",
    "Black",
    "White",
    "Silver",
    "Green",
    "Yellow"
  ];
  File? selectedImage;
  TextEditingController yearController = TextEditingController();
  final TextEditingController yearofmodelController = TextEditingController();
  final TextEditingController yearofpurchaseController = TextEditingController();
  final TextEditingController enginetypeController = TextEditingController();
  final TextEditingController fuelcapacityController = TextEditingController();
  final TextEditingController averageController = TextEditingController();
  final TextEditingController numberplateController = TextEditingController();
  final TextEditingController registrationController = TextEditingController();


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  int _selectedIndex = 2;


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchLocations();
    fetchManufacturers();
    fetchVehiclegroup();
  }

  Future<void> fetchManufacturers() async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/manufacturers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          manufacturers = data.map((item) =>
          {
            "id": item["vM_Id"],
            "name": item["vM_Name"]
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching manufacturers: $e");
    }
  }

  Future<void> fetchVehiclegroup() async {
    final url = Uri.parse(
        'http://192.168.1.110:8081/api/Driver/GetVehicleGroups');
    try {
      final response = await http.get(url);
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Decoded Data: $data");

        setState(() {
          Vehiclegroup = data.map<Map<String, dynamic>>((item) =>
          {
            "id": item["vehicleGroupId"],
            "name": item["vehicleGroup"]
          }).toList();
        });
      } else {
        print("Failed to fetch vehicle groups");
      }
    } catch (e) {
      print("Error fetching Vehicle Group: $e");
    }
  }

  Future<void> addVehicle() async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/AddVehicle');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['CategoryId'] = selectedCategoryId.toString();
      request.fields['Average'] = averageController.text;
      request.fields['NumberPlate'] = numberplateController.text;
      request.fields['RegistrationNumber'] = registrationController.text;
      request.fields['LocationId'] = selectedLocationId.toString();
      request.fields['VM_Id'] = selectedManufacturerId.toString();
      request.fields['ModelId'] = selectedModelId.toString();
      request.fields['ModelYear'] = yearofmodelController.text;
      request.fields['FuelCapacity'] = yearofpurchaseController.text;
      request.fields['Color'] = selectedColor ?? "Unknown";
      request.fields['EngineType'] = enginetypeController.text;
      // request.fields['EnginePower'] = enginepowerController.text;


      if (selectedImage != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'VehicleImage', // Field name in the API
          selectedImage!.path, // Image file path
          filename: selectedImage!
              .path
              .split('/')
              .last, // Filename for the image
          contentType: MediaType('image', 'jpeg'), // Set content type correctly
        );
        request.files.add(imageFile);

        // Also add the image path as a form field
        request.fields['ImagePath'] = selectedImage!.path;
      }


      // Sending the request
      var response = await request.send();

      // Printing the payload to the terminal
      print("Request Payload:");
      print(request.fields);


      // Handling the response
      if (response.statusCode == 200) {
        // print("Driver added successfully!");
        showSuccessPopup(context); // Pass context here
        // print("Response: $responseData");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("Driver added successfully!"),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      } else {
        print("Failed to add vehicle. Status code: ${response.statusCode}");
        var responseData = await response.stream.bytesToString();
        print("Error: $responseData");
      }
    } catch (e) {
      print("Error adding vehicle: $e");
    }
  }

  Future<void> fetchModels(int manufacturerId) async {
    final url = Uri.parse(
        'http://192.168.1.110:8081/api/Driver/GetVehicleModelsByManufacturer?vmId=$manufacturerId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          models = data.map((item) =>
          {
            "id": item["modelId"],
            "name": item["modelName"]
          }).toList();
          selectedModelId = null;
        });
      }
    } catch (e) {
      print("Error fetching models: $e");
    }
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse(
        'http://192.168.1.110:8081/api/Driver/GetActiveVehicleCategories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((item) =>
          {
            "id": item["categoryId"],
            "name": item["categoryName"]
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchLocations() async {
    final url = Uri.parse(
        'http://192.168.1.110:8081/api/Driver/GetAllLocation');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          locations = data.map((item) =>
          {
            "id": item["locationId"],
            "name": item["locationName"]
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double textScale = MediaQuery
        .of(context)
        .textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add New Vehicle",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18 * textScale,
            fontWeight: FontWeight.bold,
          ),
        ),

        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: screenHeight * 0.02),
              //
              // // Vehicle Image Section
              // Center(
              //   child: GestureDetector(
              //     onTap: () {
              //       showModalBottomSheet(
              //         context: context,
              //         builder: (context) => buildImagePickerBottomSheet(),
              //       );
              //     },
              //     child: Stack(
              //       alignment: Alignment.center,
              //       children: [
              //         Container(
              //           width: 130,
              //           height: 130,
              //           decoration: BoxDecoration(
              //             shape: BoxShape.circle,
              //             gradient: LinearGradient(
              //               colors: [Colors.teal, Colors.blueAccent],
              //               begin: Alignment.topLeft,
              //               end: Alignment.bottomRight,
              //             ),
              //             boxShadow: [
              //               BoxShadow(
              //                 color: Colors.black26,
              //                 blurRadius: 8,
              //                 offset: Offset(0, 4),
              //               ),
              //             ],
              //           ),
              //         ),
              //         CircleAvatar(
              //           radius: 60,
              //           backgroundColor: Colors.white,
              //           backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
              //           child: selectedImage == null
              //               ? Icon(Icons.camera_alt, color: Colors.grey[600], size: 35)
              //               : null,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // SizedBox(height: screenHeight * 0.03),

              // --- Vehicle Details Section ---
              sectionTitle("Vehicle Details"),
              buildDropdown("Select Manufacturer", manufacturers, selectedManufacturerId, (val) {
                setState(() {
                  selectedManufacturerId = val;
                  fetchModels(val!);
                });
              }),
              buildDropdown("Select Model", models, selectedModelId, (val) {
                setState(() => selectedModelId = val);
              }),
              buildTextField("Year of Model", yearofmodelController),

              // SizedBox(height: screenHeight * 0.02),

              // --- Location Section ---
              sectionTitle("Location Details"),
              buildDropdown("Select Base Location", locations, selectedLocationId, (val) {
                setState(() => selectedLocationId = val);
              }),
              buildDropdown("Select Vehicle Group", Vehiclegroup, selectedVehiclegroupId, (val) {
                setState(() => selectedVehiclegroupId = val);
              }),

              // SizedBox(height: screenHeight * 0.02),

              // --- Specifications Section ---
              sectionTitle("Specifications"),
              buildTextField("Vehicle Engine Type", enginetypeController),
              buildTextField("Fuel Capacity", fuelcapacityController),
              buildDropdown("Select Vehicle Category", categories, selectedCategoryId, (val) {
                setState(() => selectedCategoryId = val);
              }),
              buildTextField("Average km/L", averageController),
              //
              // SizedBox(height: screenHeight * 0.02),

              // --- Registration Section ---
              sectionTitle("Registration Details"),
              buildTextField("Number Plate", numberplateController),
              buildTextField("Registration Number", registrationController),

              SizedBox(height: screenHeight * 0.02),
              Text(
                "Vehicle Image",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * textScale,
                  color: AppColors.primaryColor
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text("Take Photo"),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text("Choose from Gallery"),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: selectedImage != null
                    ? Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    : Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),


              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 16 * textScale),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),



    );
  }

  Widget buildDropdown(String hint, List<Map<String, dynamic>> items, int? selectedValue, Function(int?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        hint: Text(hint),
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<int>(
            value: item["id"],
            child: Text(item["name"]),
          );
        }).toList(),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black, fontSize: 16.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.white,
        ),
        style: TextStyle(color: Colors.black, fontSize: 18.0),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 20),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget buildImagePickerBottomSheet() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Take Photo"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYearTextField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            yearController.text = pickedDate.year.toString();
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: yearController,
          decoration: InputDecoration(
            hintText: "Year of Model",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }





  // Widget _buildImageUploadButton() {
  //   return Container(
  //     padding: EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.image, color: Colors.grey),
  //         SizedBox(width: 10),
  //         Text("Add images of vehicle", style: TextStyle(color: Colors.grey)),
  //       ],
  //     ),
  //   );
  // }


  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent, // Transparent for full effect
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White Card Background
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.only(
                    top: 60, left: 20, right: 20, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Done!", style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      "Vehicle has been registered successfully",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // Close popup
                        // Add navigation if needed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor2,
                        // Maroon Button Color
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: Text("View Vehicle",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -30, // Floating Icon
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 30,
                  child: Icon(Icons.check, color: Colors.white, size: 35),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}