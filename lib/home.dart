import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'vehicle_details_screen.dart';
import 'colors.dart';
import 'package:ramadrive/FuelLogScreen.dart';
import 'MaintenanceScreen.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'maintaintrip.dart';
import 'package:ramadrive/MaintenanceScreen.dart';
import 'refeulling.dart';
import 'maintenanceallrecord.dart';
import 'driverprofile.dart';
import 'driverfuelMaintenance.dart';
class HomePage extends StatefulWidget {
  final int driverId;
  const HomePage({Key? key, required this.driverId}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? vehicleData;
  List<dynamic> fuelLogs = [];
  List<dynamic> recentTrips = [];
  bool isLoading = true;
  int _selectedIndex = 0;
  String selectedOption = "Add Trip";
  List<Map<String, dynamic>> maintenanceTypes = [];
  int? selectedMaintenanceTypeId;
  File? _selectedFile;
  int? selectedVehicleId;
  TextEditingController serviceCostController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController meterreadingController = TextEditingController();
  File? _image;
  String? extractedText;
  List<dynamic> maintenanceHistory = [];
  bool _showAllRecords = false;


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _screens() => [
    _buildHomeView(), // Index 0: Home
    DriverFuelMaintenance(driverId: widget.driverId), // Index 1: Approvals
    _buildRecordsView(), // Index 2: Records
    DriverProfileScreen(driverId: widget.driverId), // Index 3: Me
  ];


  @override
  void initState() {
    super.initState();
    fetchVehicleDetails();
    fetchFuelLogs();
    fetchTrips();
    checkSession();
    fetchRecentMaintenanceHistory(); //
    fetchMaintenanceTypes();
  }

  Future<bool> isTokenValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return false;

    // Check if token is still valid (optional: make API call to verify)
    // If API returns an unauthorized response, return false

    return true;
  }

  void checkSession() async {
    bool valid = await isTokenValid();
    if (!valid) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear session data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<void> fetchVehicleDetails() async {
    final String apiUrl =
        "http://192.168.1.110:8081/api/Driver/getVehicledetailfordashboard?DriverId=${widget.driverId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        setState(() {
          vehicleData = responseData.isNotEmpty ? responseData.first : null;
          selectedVehicleId = vehicleData?["vehiclesId"]; // Save vehiclesId
          isLoading = false;
        });
      } else {
        setState(() {
          vehicleData = null;
          selectedVehicleId = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        vehicleData = null;
        selectedVehicleId = null;
        isLoading = false;
      });
    }
  }
  Future<void> fetchFuelLogs() async {
    final String apiUrl = "http://192.168.1.110:8081/api/Driver/GetFuelDetails?driverId=${widget
        .driverId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          fuelLogs = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load fuel logs");
      }
    } catch (e) {
      print("Error fetching fuel logs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
    } catch (e) {
      return dateTime; // Fallback in case of error
    }
  }

  Future<void> fetchTrips() async {
    final String apiUrl = "http://192.168.1.110:8081/api/Driver/GetDriverWorkingDetails?Driver=${widget
        .driverId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          recentTrips = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load trips");
      }
    } catch (e) {
      print("Error fetching trips: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchRecentMaintenanceHistory() async {
    final url =
        'http://192.168.1.110:8081/api/Driver/GetVehicleMaintenanceByDriver?driverId=${widget.driverId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          maintenanceHistory = jsonDecode(response.body);
        });
      } else {
        print('Failed to load maintenance history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching maintenance history: $e');
    }
  }


  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }


  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Add a New Request", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOption(
                        title: "Add Trip",
                        icon: Icons.map,
                        isSelected: selectedOption == "Add Trip",
                        onTap: () {
                          setModalState(() => selectedOption = "Add Trip");
                        },
                        width: 190,
                        height: 150,
                      ),
                      SizedBox(width: 12),
                      Column(
                        children: [
                          _buildOption(
                            title: "Refuelling",
                            icon: Icons.local_gas_station,
                            isSelected: selectedOption == "Refuelling",
                            onTap: () {
                              setModalState(() => selectedOption = "Refuelling");
                            },
                            width: 150,
                            height: 70,
                          ),
                          SizedBox(height: 10),
                          _buildOption(
                            title: "Maintenance",
                            icon: Icons.settings,
                            isSelected: selectedOption == "Maintenance",
                            onTap: () {
                              setModalState(() => selectedOption = "Maintenance");
                            },
                            width: 150,
                            height: 70,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (selectedOption == "Add Trip") {
                        Navigator.pop(context);
                        showMaintainTripBottomSheet(context, selectedVehicleId!, widget.driverId, fuelLogs);

                      }
                      else if (selectedOption == "Maintenance") {
                        Navigator.pop(context);
                        showMaintenanceBottomSheet(context, vehicleData, selectedVehicleId!, widget.driverId);
                      }
                      else if (selectedOption == "Refuelling") {
                        Navigator.pop(context);
                        RefuellingBottomSheet.show(
                          context: context,
                          vehicleData: vehicleData!,
                          selectedVehicleId: selectedVehicleId!,
                          driverId: widget.driverId,
                        );

                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Continue",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor2 : Colors.brown.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildHeaderSection(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade800],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(screenWidth * 0.1),
          bottomRight: Radius.circular(screenWidth * 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today Assigned Vehicle", style: TextStyle(
              color: Colors.white70, fontSize: screenWidth * 0.04)),
          SizedBox(height: screenWidth * 0.03),
          if (vehicleData != null)
            LayoutBuilder(
              builder: (context, constraints) {
                String imageUrl = vehicleData!["vehicleImage"]
                    ?.toString()
                    .trim() ?? "";

                if (!imageUrl.startsWith("http")) {
                  imageUrl = "http://192.168.1.110:8081$imageUrl";
                }

                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              vehicleData!["numberPlate"] ?? "N/A",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.02),

                          // Model Name & Year
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${vehicleData!["vM_Name"]} (${vehicleData!["modelYear"]})",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Row(
                            children: [

                              Icon(Icons.speed, color: Colors.white,
                                  size: screenWidth * 0.05),

                              SizedBox(width: screenWidth * 0.01),
                              Text("${vehicleData!["finalReading"]} km",
                                  style: TextStyle(color: Colors.white,
                                      fontSize: screenWidth * 0.04)),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.02),

                          Row(
                            children: [
                              Icon(Icons.local_gas_station, color: Colors.white,
                                  size: screenWidth * 0.05),
                              SizedBox(width: screenWidth * 0.01),
                              Text(vehicleData!["engineType"] ?? "N/A",
                                  style: TextStyle(color: Colors.white,
                                      fontSize: screenWidth * 0.04)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Image.network(
                        imageUrl,
                        height: constraints.maxWidth * 0.3,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(
                              Icons.calendar_month,
                              size: constraints.maxWidth * 0.3,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Center(
              child: Text(
                "No Vehicle Assigned",
                style: TextStyle(color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(height: screenWidth * 0.05),
          Center(
            child: ElevatedButton(
              onPressed: vehicleData != null
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VehicleDetailsScreen(vehicleData: vehicleData!),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: vehicleData != null
                    ? AppColors.primaryColor2
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05)),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1,
                    vertical: screenWidth * 0.02),
              ),
              child: Text("Details →", style: TextStyle(
                  color: Colors.white, fontSize: screenWidth * 0.04)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRecentTripSection(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Trip",
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to all trips screen
                },
                child: Text(
                  "See all",
                  style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.035),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : recentTrips.isEmpty
              ? Center(child: Text("No recent trips available"))
              : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 1,
            itemBuilder: (context, index) {
              var trip = recentTrips[index];


              //logic in case of pick town ,pick city ,pick district gives the unknown
              String getLocationPriority(Map<String, dynamic> trip, String townKey, String cityKey, String districtKey) {
                String town = trip[townKey]?.toString() ?? "";
                String city = trip[cityKey]?.toString() ?? "";
                String district = trip[districtKey]?.toString() ?? "";

                if (town.isNotEmpty && !town.toLowerCase().contains("unknown")) {
                  return town;
                } else if (city.isNotEmpty && !city.toLowerCase().contains("unknown")) {
                  return city;
                } else if (district.isNotEmpty && !district.toLowerCase().contains("unknown")) {
                  return district;
                } else {
                  return "Unknown";
                }
              }

              String pickLocation = getLocationPriority(trip, "pickTown", "pickCity", "pickDistrict");
              String dropLocation = getLocationPriority(trip, "dropTown", "dropCity", "dropDistrict");

              // // Logic for if the town is null then display the city if city is null then display district
              // String pickLocation = trip["pickTown"] ?? trip["pickCity"] ?? trip["pickDistrict"] ?? "Unknown";
              // String dropLocation = trip["dropTown"] ?? trip["dropCity"] ?? trip["dropDistrict"] ?? "Unknown";


              // Extract date and time
              DateTime startTime = DateTime.parse(trip["startTime"]);
              String formattedDate = "${startTime.day}-${startTime.month}-${startTime.year}";
              String formattedTime = "${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour >= 12 ? "PM" : "AM"}";

              return Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: screenWidth * 0.02,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Trip Icon
                        // Trip Image (Replace Icon with Image)
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade800,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            "assets/Group.png", // Replace with your image path
                            width: screenWidth * 0.04,
                            height: screenWidth * 0.04,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(width: screenWidth * 0.04),

                        // Locations with line in between
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.black54, size: screenWidth * 0.045),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(pickLocation, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                      height: 2,
                                      color: AppColors.primaryColor2, // Solid red color
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Text(dropLocation, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500)),
                                      SizedBox(width: screenWidth * 0.02),
                                      Icon(Icons.location_on, color: Colors.black54, size: screenWidth * 0.045),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.04),

                    // Date and Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: screenWidth * 0.040, color: Colors.teal),
                              SizedBox(width: screenWidth * 0.02),
                              Text(formattedDate, style: TextStyle(color: Colors.teal, fontSize: screenWidth * 0.035)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.red.shade200,
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: screenWidth * 0.045, color: Colors.white),
                              SizedBox(width: screenWidth * 0.02),
                              Text(formattedTime, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildFuelLogSection(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fuel Log Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fuel Log",
                style: TextStyle(fontSize: screenWidth * 0.04,),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FuelLogScreen(fuelLogs: fuelLogs),
                    ),
                  );
                },
                child: Text(
                  "See all",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.red,

                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 10),

          // Show loading indicator while fetching data
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            if (fuelLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("No fuel logs available"),
                ),
              )
            else
            // Horizontal Scrollable Fuel Log Cards
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fuelLogs.length,
                  itemBuilder: (context, index) {
                    var log = fuelLogs[index];

                    return Container(
                      width: 150,
                      margin: EdgeInsets.only(right: 10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(log["createdOn"]),
                                    style: TextStyle(fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "${log["fuelQuantity"]}Ltr",
                                      style: TextStyle(color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: Text(
                                log["engineType"],
                                style: TextStyle(color: AppColors.secondaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    log["numberPlate"],
                                    style: TextStyle(fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.teal.shade800,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "₹${log["fuelPrice"]}",
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // ✅ Prevent FAB shift
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.teal.shade400,
        elevation: 0,
        leading: Builder(
          builder: (context) => InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child:CircleAvatar(
                radius: 40,
                backgroundImage: vehicleData != null && vehicleData!['driverImage'] != null
                    ? NetworkImage("http://192.168.1.110:8081${vehicleData!['driverImage']}")
                    : AssetImage('assets/user.jpeg') as ImageProvider,
              ),

            ),
          ),
        ),
        actions: [
          SizedBox(width: 15),
        ],
      ),
      body: _screens()[_selectedIndex],
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          onPressed: () => _showBottomSheet(context),
          backgroundColor: AppColors.secondaryColor,
          shape: CircleBorder(),
          child: Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.white,
          shape: CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem("assets/Light.png", "Home", 0, isCustom: true),
              _buildNavItem("assets/tripsicon.png", "Approvals", 1, isCustom: true),
              _buildNavItem("assets/Vector.png", "Records", 2, isCustom: true),
              _buildNavItem("assets/me.png", "Me", 3, isCustom: true),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHomeView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderSection(context),
          _buildRecentTripSection(context),
          _buildFuelLogSection(context),
          _buildRecentMaintenanceHistorySection(context),
        ],
      ),
    );
  }

  Widget _buildRecordsView() {
    return Center(
      child: Text("Records Screen", style: TextStyle(fontSize: 18)),
    );
  }


  Widget _buildNavItem(String iconPath, String label, int index, {bool isCustom = false}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor1.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,

            ),
            child: Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: isSelected ? AppColors.secondaryColor : Colors.grey,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? AppColors.secondaryColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }

Widget _buildDrawer(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 280, // Increased width for better spacing
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(4, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: vehicleData != null && vehicleData!['driverImage'] != null
                        ? NetworkImage("http://192.168.1.110:8081${vehicleData!['driverImage']}")
                        : AssetImage('assets/user.jpeg') as ImageProvider,
                  ),

                  SizedBox(width: 15), // Space between image and text
                  Expanded( // Ensures text doesn't overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicleData != null ? vehicleData!["fullName"] ?? "N/A" : "Loading...",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 4), // Small space between name and email
                        // Text(
                        //   vehicleData != null ? vehicleData!["email"] ?? "example@email.com" : "Loading...",
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.black54,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


            // Section Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "General",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.person, "My Account", () {
                    Navigator.pop(context); // Close drawer first
                    if (vehicleData != null && vehicleData!['driverId'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverProfileScreen(
                            driverId: vehicleData!['driverId'],
                          ),
                        ),
                      );
                    }
                  }),

                  // _buildDrawerItem(Icons.build, "Maintenance", () {}),
                  // _buildDrawerItem(Icons.approval, "Approvals", () {}),
                  // _buildDrawerItem(Icons.directions_bus, "Alloted Vehicle", () {}),
                ],
              ),
            ),


            // Logout Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton.icon(
                onPressed: () => logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor2,
                  // Ensure this color is defined
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                icon: Icon(Icons.power_settings_new, color: Colors.white),
                label: Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            spreadRadius: 1,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentMaintenanceHistorySection(BuildContext context) {
    if (maintenanceHistory.isEmpty) return SizedBox();

    // Group by maintenanceId and get latest
    final latestByMaintenanceId = <int, Map<String, dynamic>>{};
    for (var item in maintenanceHistory) {
      final maintenanceId = item['maintenancId'];
      final current = latestByMaintenanceId[maintenanceId];
      final itemDate = DateTime.parse(item['createdOn']);
      if (current == null || itemDate.isAfter(DateTime.parse(current['createdOn']))) {
        latestByMaintenanceId[maintenanceId] = item;
      }
    }

    // Sort latest records by date descending and pick the most recent
    final latestRecords = latestByMaintenanceId.values.toList()
      ..sort((a, b) => DateTime.parse(b['createdOn']).compareTo(DateTime.parse(a['createdOn'])));
    final latestItem = latestRecords.first;

    final date = DateTime.parse(latestItem['createdOn']);
    final formattedDate = "${date.day}/${date.month}/${date.year}";
    final numberPlate = latestItem['numberPlate'] ?? '';
    final serviceCost = latestItem['serviceCost'];
    final type = latestItem['maintenancType'] ?? '';
    final vehicleImage = latestItem['vehicleImage'] != null
        ? "http://192.168.1.110:8081${latestItem['vehicleImage']}"
        : "https://img.icons8.com/?size=100&id=7870&format=png";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Maintenance History", style: TextStyle(fontSize: 16)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllMaintenanceHistoryScreen(maintenanceHistory)),
                  );
                },
                child: Text(
                  "See all",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Single latest record
          Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDate, style: TextStyle(color: Colors.grey[700])),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF7F4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "₹$serviceCost",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade600,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(vehicleImage),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          numberPlate,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          type,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


}

