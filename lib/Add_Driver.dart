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
import 'upload_document.dart';

class AddDriverScreen extends StatefulWidget {
  @override
  _AddDriverScreenState createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController currentaddressController = TextEditingController();
  final TextEditingController PermanentAddressController = TextEditingController();



  int? selectedExperience;
  int? selectedLocationId;
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
    fetchLocations();
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

    String apiUrl = "http://192.168.1.110:8081/api/Driver/AddDriverOutSource";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers.addAll({"Content-Type": "multipart/form-data"});

      // ✅ Add Form Fields
      request.fields.addAll({
        "FullName": fullNameController.text,
        "MobileNumber": mobileController.text,
        "StateId": selectedLocationId.toString(),
        "Address": currentaddressController.text,
        "PermanentAddress": PermanentAddressController.text,
        "DrivingExperience": selectedExperience.toString(),
      });

      // ✅ Add Driver Image
      if (_selectedImages.isNotEmpty) {
        File file = _selectedImages.first;
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'DriverImage',
              file.path,
            ),
          );
        }
      }

      // ✅ Send the Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // ✅ Extract driverId from response
        var responseData = json.decode(response.body);
        int driverId = responseData['driverId']; // Ensure API returns this

        // ✅ Navigate to UploadIdentityScreen with driverId
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UploadIdentityScreen(driverId: driverId)),
        );
      } else {
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
      backgroundColor: Colors.white ,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor1),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            "Add New Driver",
            style: TextStyle(color: AppColors.primaryColor1, fontSize: fontSize * 1.2,fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
        // backgroundColor: AppColors.primaryColor,
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
                        child: Text("$year"), // Removed "years" text
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

              ],
            ),
            SizedBox(height: screenHeight * 0.01),


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
                Row(
                  children: [

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
              controller: currentaddressController,
              decoration: InputDecoration(

                labelText: 'Current Address',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Current Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextFormField(
              controller: PermanentAddressController,
              decoration: InputDecoration(

                labelText: 'Permanent Address',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                hintText: 'Permanent Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
            Text(
              'Upload Profile ',
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
                  backgroundColor: AppColors.primaryColor1,
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
                    "Driver has been registered successfully",
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
                    child: Text("View Drivers", style: TextStyle(fontSize: 16, color: Colors.white)),
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
