import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'colors.dart';
import 'home.dart';
import 'homeadmin.dart';
import 'user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';


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
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> locations = [];
  List<String> colors = ["Red", "Blue", "Black", "White", "Silver", "Green", "Yellow"];
  File? selectedImage;
  TextEditingController yearController = TextEditingController();
  final TextEditingController yearofmodelController = TextEditingController();
  final TextEditingController yearofpurchaseController = TextEditingController();
  final TextEditingController enginetypeController = TextEditingController();
  final TextEditingController enginepowerController = TextEditingController();
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
  }

  Future<void> fetchManufacturers() async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/manufacturers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          manufacturers = data.map((item) => {
            "id": item["vM_Id"],
            "name": item["vM_Name"]
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching manufacturers: $e");
    }
  }
  Future<void> addVehicle() async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/AddVehicle');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['CategoryId'] = selectedCategoryId.toString();
      request.fields['Average'] = averageController.text;
      request.fields['NumberPlate'] = numberplateController.text;
      request.fields['RC_Number'] = registrationController.text;
      request.fields['LocationId'] = selectedLocationId.toString();
      request.fields['VM_Id'] = selectedManufacturerId.toString();
      request.fields['ModelId'] = selectedModelId.toString();
      request.fields['ModelYear'] = yearofmodelController.text;
      request.fields['PurchaseYear'] = yearofpurchaseController.text;
      request.fields['Color'] = selectedColor ?? "Unknown";
      request.fields['EngineType'] = enginetypeController.text;
      request.fields['EnginePower'] = enginepowerController.text;


      if (selectedImage != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'file',                                // Field name in the API
          selectedImage!.path,                    // Image file path
          filename: selectedImage!.path.split('/').last, // Filename for the image
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
          models = data.map((item) => {
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
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/GetActiveVehicleCategories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((item) => {
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
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/GetAllLocation');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          locations = data.map((item) => {
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            "Add New Vehicle",
            style: TextStyle(color: Colors.black, fontSize: 18 * textScale, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: GestureDetector(
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                        child: selectedImage == null
                            ? Icon(Icons.camera_alt, color: Colors.grey[600], size: 40)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              DropdownButtonFormField<int>(
                value: selectedManufacturerId,
                hint: Text("Select Manufacturer"),
                onChanged: (value) {
                  setState(() {
                    selectedManufacturerId = value;
                    fetchModels(value!);
                  });
                },
                items: manufacturers.map((manufacturer) {
                  return DropdownMenuItem<int>(
                    value: manufacturer["id"],
                    child: Text(manufacturer["name"]),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              DropdownButtonFormField<int>(
                value: selectedModelId,
                hint: Text("Select Model"),
                onChanged: (value) {
                  setState(() {
                    selectedModelId = value;
                  });
                },
                items: models.map((model) {
                  return DropdownMenuItem<int>(
                    value: model["id"],
                    child: Text(model["name"]),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                controller: yearofmodelController,
                decoration: InputDecoration(

                  labelText: 'Year of Model',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  hintText: 'Year of Model',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),

              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                controller: yearofpurchaseController,
                decoration: InputDecoration(

                  labelText: 'Year of Purchase',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  hintText: 'Year of Purchase',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),

              ),
              SizedBox(height: screenHeight * 0.01),
              DropdownButtonFormField<String>(
                value: selectedColor,
                hint: Text("Select Vehicle Color"),
                onChanged: (value) {
                  setState(() {
                    selectedColor = value;
                  });
                },
                items: colors.map((color) {
                  return DropdownMenuItem<String>(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              DropdownButtonFormField<int>(
                value: selectedLocationId,
                hint: Text("Select Base Location"),
                onChanged: (value) {
                  setState(() {
                    selectedLocationId = value;
                  });
                },
                items: locations.map((location) {
                  return DropdownMenuItem<int>(
                    value: location["id"],
                    child: Text(location["name"]),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                controller: enginetypeController,
                decoration: InputDecoration(

                  labelText: 'Vehicle Engine Type',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  hintText: 'Vehicle Engine Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),

              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                controller: enginepowerController,
                decoration: InputDecoration(

                  labelText: 'Vehicle Engine Power',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  hintText: 'Vehicle Engine Power',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),

              ),
              SizedBox(height: screenHeight * 0.01),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                hint: Text("Select Vehicle Category"),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
                items: categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category["id"],
                    child: Text(category["name"]),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                controller: averageController,
                decoration: InputDecoration(

                  labelText: 'Average km/L',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  hintText: 'Average km/L',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),

              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                controller: numberplateController,
                decoration: InputDecoration(

                  labelText: 'Number Plate',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  hintText: 'Number Plate',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),

              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                controller: registrationController,
                decoration: InputDecoration(

                  labelText: 'Registration Number',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  hintText: 'Registration Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),

              ),
              SizedBox(height: screenHeight * 0.03),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addVehicle,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 16 * textScale),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),

            _buildNavItem(Icons.approval, "Approvals", 1),
            SizedBox(width: screenWidth * 0.1),
            _buildNavItem(Icons.directions_car, "Vehicles", 2),
            _buildNavItem(Icons.person, "Me", 3)
          ],
        ),
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



  Widget _buildTextField(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImageUploadButton() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.image, color: Colors.grey),
          SizedBox(width: 10),
          Text("Add images of vehicle", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _selectedIndex == index ? Colors.black : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.black : Colors.grey,
              fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,

            ),
          ),
        ],
      ),
    );
  }
}
void showSuccessPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Done!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                      backgroundColor: AppColors.primaryColor2, // Maroon Button Color
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text("View Vehicle", style: TextStyle(fontSize: 16, color: Colors.white)),
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
