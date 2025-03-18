import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'colors.dart';
import 'homeadmin.dart';
import 'vehicle_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddDriverScreen extends StatefulWidget {
  @override
  _AddDriverScreenState createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();
  final TextEditingController dlNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController employeeidController = TextEditingController();


  int? selectedExperience;
  String? selectedDrinkingStatus;
  String? selectedDriveTruckBus;
  String? selectedDriveCarSuv;
  int? selectedLocationId;
  int? selectedCountryId;
  int? selectedStateId;
  int? selectedCityId;

  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> locations = [];
  List<File> _selectedImages = [];
  int _selectedIndex = 1;


  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageAdmin()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AddDriverScreen()),
      );
    }
    else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AddVehicleScreen()),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchCountries();
    fetchLocations();
  }

  // Fetch API Data (Countries, States, Cities, Locations)
  Future<void> fetchCountries() async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/GetAllCountries');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          countries = data.map((item) => {
            "id": item["countryId"],
            "name": item["countryName"]
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching countries: $e");
    }
  }

  Future<void> fetchStates(int countryId) async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/GetStates?countryId=$countryId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          states = data.map((item) => {
            "id": item["stateId"],
            "name": item["stateName"]
          }).toList();
          selectedStateId = null;
          cities = [];
          selectedCityId = null;
        });
      }
    } catch (e) {
      print("Error fetching states: $e");
    }
  }

  Future<void> fetchCities(int stateId) async {
    final url = Uri.parse('http://192.168.1.110:8081/api/Driver/GetCity?stateId=$stateId&cityId=1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        setState(() {
          cities = [{
            "id": data["cityId"],
            "name": data["cityName"]
          }];
          selectedCityId = null;
        });
      }
    } catch (e) {
      print("Error fetching cities: $e");
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

  // Function to select image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }



  Future<void> submitDriverDetails() async {
    if (!_formKey.currentState!.validate()) return;

    String apiUrl = "http://192.168.1.110:8081/api/Driver/AddDriver";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('admin_token');
    int? userId = prefs.getInt('admin_userId');

    if (authToken == null || userId == null) {
      print("Error: Token or User ID is missing.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Token or User ID is missing."), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // ✅ Add Authorization Header
      request.headers.addAll({
        "Authorization": "Bearer $authToken",
        "Content-Type": "multipart/form-data",
      });

      // ✅ Add Form Fields
      request.fields.addAll({
        "CreatedBy": userId.toString(),
        "fullName": fullNameController.text,
        "mobileNumber": mobileController.text,
        "email": emailController.text,
        "aadharNumber": aadharController.text,
        "dlNumber": dlNumberController.text,
        "employeeid": employeeidController.text,
        "experience": selectedExperience.toString(),
        "drinkingStatus": selectedDrinkingStatus.toString(),
        "driveTruckBus": selectedDriveTruckBus.toString(),
        "driveCarSuv": selectedDriveCarSuv.toString(),
        "countryId": selectedCountryId.toString(),
        "stateId": selectedStateId.toString(),
        "cityId": selectedCityId.toString(),
        "locationId": selectedLocationId.toString(),
        "address": addressController.text,
      });

      // ✅ Add Image Files (Check if List is not Empty)
      if (_selectedImages.isNotEmpty) {
        for (File file in _selectedImages) {
          if (await file.exists()) { // Ensure file exists
            request.files.add(
              await http.MultipartFile.fromPath(
                'driverDocument',  // 🔹 Check API Key for Image Upload
                file.path,
              ),
            );
          } else {
            print("Error: File not found -> ${file.path}");
          }
        }
      } else {
        print("No images selected.");
      }

      // ✅ Send the Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // ✅ Debug Response
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // ✅ Handle Response
      // ✅ Call showSuccessPopup() with context
      if (response.statusCode == 200) {
        // print("Driver added successfully!");
        showSuccessPopup(context); // Pass context here

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("Driver added successfully!"),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
      else {
        print("Failed to add driver: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to add driver: ${response.body}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("Error submitting driver details: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error submitting driver details: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double padding = screenWidth * 0.04;
    double fontSize = screenWidth * 0.04;


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            "Add New Driver",
            style: TextStyle(color: Colors.black, fontSize: fontSize * 1.2,fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
      color: Colors.white, // Set background color to white
    child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add a Driver to Your Fleet", style: TextStyle(fontSize: fontSize * 1.2, fontWeight: FontWeight.bold)),
            Text("Manage and track your vehicles efficiently."),
            SizedBox(height: screenHeight * 0.02),
            TextFormField(
              controller: fullNameController,
              decoration: InputDecoration(

                labelText: 'Full Name',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Enter Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),

            ),
            SizedBox(height: screenHeight * 0.01),
            TextFormField(
              controller: mobileController,
              decoration: InputDecoration(

                labelText: 'Mobile Number',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Enter Mobile Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),

            ),
            SizedBox(height: screenHeight * 0.01),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(

                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Enter Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),

            ),
            SizedBox(height: screenHeight * 0.01),
            TextFormField(
              controller: aadharController,
              decoration: InputDecoration(

                labelText: 'Aadhar Card Number',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Enter Aadhar Card Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),

            ),
            SizedBox(height: screenHeight * 0.01),
            TextFormField(
              controller: dlNumberController,
              decoration: InputDecoration(

                labelText: 'Dl Number',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Enter DL Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),

            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                // Experience Dropdown
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedExperience,
                    hint: Text("Select Experience"),
                    onChanged: (value) {
                      setState(() {
                        selectedExperience = value;
                      });
                    },
                    items: List.generate(21, (index) => index).map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text("$year years"),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                SizedBox(width: 10), // Space between dropdowns

                // Drinking Status Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDrinkingStatus,
                    hint: Text("Drinking Status"),
                    onChanged: (value) {
                      setState(() {
                        selectedDrinkingStatus = value;
                      });
                    },
                    items: ["Yes", "No"].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                // Drive Truck/Bus Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDriveTruckBus,
                    hint: Text("Drive Truck/Bus?"),
                    onChanged: (value) {
                      setState(() {
                        selectedDriveTruckBus = value;
                      });
                    },
                    items: ["Yes", "No"].map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                SizedBox(width: 10),


                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDriveCarSuv,
                    hint: Text("Drive Car/SUV?"),
                    onChanged: (value) {
                      setState(() {
                        selectedDriveCarSuv = value;
                      });
                    },
                    items: ["Yes", "No"].map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            TextFormField(
              controller: employeeidController,
              decoration: InputDecoration(

                labelText: 'Employee Id',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Enter Employee Id',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),

            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Drivers Address',
              style: TextStyle(
                fontFamily:'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Column(
              children: [
                // Row for Country & State
                Row(
                  children: [
                    // Country Dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedCountryId,
                        hint: Text("Select Country"),
                        onChanged: (value) {
                          setState(() {
                            selectedCountryId = value;
                            selectedStateId = null;
                            selectedCityId = null;
                            states.clear();
                            cities.clear();
                            fetchStates(value!);
                          });
                        },
                        items: countries.map((country) {
                          return DropdownMenuItem<int>(
                            value: country["id"],
                            child: Text(country["name"]),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.01),



                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedStateId,
                        hint: Text("Select State"),
                        onChanged: (states.isNotEmpty)
                            ? (value) {
                          setState(() {
                            selectedStateId = value;
                            selectedCityId = null;
                            cities.clear();
                            fetchCities(value!);
                          });
                        }
                            : null,
                        items: states.map((state) {
                          return DropdownMenuItem<int>(
                            value: state["id"],
                            child: Text(state["name"]),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02), // Space between rows


                Row(
                  children: [

                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedCityId,
                        hint: Text("Select City"),
                        onChanged: (cities.isNotEmpty)
                            ? (value) {
                          setState(() {
                            selectedCityId = value;
                          });
                        }
                            : null,
                        items: cities.map((city) {
                          return DropdownMenuItem<int>(
                            value: city["id"],
                            child: Text(city["name"]),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedLocationId,
                        hint: Text(" Base Location"),
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
                    ),





                  ],
                ),

              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(

                labelText: 'Enter Address',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Enter Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
            Text(
              'Upload Document',
              style: TextStyle(
                fontFamily:'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.image, color: Colors.grey),
                    SizedBox(width: 10),
                    Text("Add images of driver", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            _selectedImages.isNotEmpty
                ? Wrap(
              spacing: 10,
              children: _selectedImages.asMap().entries.map((entry) {
                int index = entry.key;
                File image = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
                : Container(),


            SizedBox(height: screenHeight * 0.03),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitDriverDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: fontSize)),
              ),
            ),
          ],
        ),
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
      bottomNavigationBar: _buildBottomNavigationBar(screenWidth, screenHeight),
    );
  }

  Widget _buildBottomNavigationBar(double screenWidth, double screenHeight) {
    return BottomAppBar(
      color: Colors.white,
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(

        height: screenHeight * 0.08,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: [],
        onChanged: (value) {},
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
          Text("Add images of driver", style: TextStyle(color: Colors.grey)),
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
