import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adminlogin.dart';
import 'colors.dart';
import 'trip_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trip_list_screen.dart';
import 'vehicles_on_road_screen.dart';
import 'fuel_entry.dart';
import 'fuel_list_screen.dart';
import 'adminmaintenancelist.dart';
import 'package:ramadrive/MaintenanceEntry.dart';
import 'drivertrip.dart';
import 'assigned_trip.dart';
import 'package:intl/intl.dart';
import 'adminprofile.dart';
import 'fuel_maintenance_screen.dart';
import 'admingetalldriver.dart';
import 'admingetalldriver.dart';
import 'pending_drivers_screen.dart';
import 'adminprofilemodel.dart';
import 'vehicle_screen.dart';
import 'AssignVehicle.dart';
class HomePageAdmin extends StatefulWidget {

  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _selectedIndex = 0;
  int tripCount = 0;
  int onRoadVehicle = 0;
  List<dynamic> onRoadVehicleList = [];
  int fuelCount = 0;
  List<FuelEntry> fuelList = [];
  List<MaintenanceEntry> maintenanceList = [];
  int maintenanceCount = 0;
  List<DriverTrip> driverTrips = [];
  List<AssignedTrip> assignedTrips = [];

  String? adminName;
  String? adminImage;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  final List<Widget> _pages = [
    Container(), // Home
    FuelMaintenanceScreen(), // Approvals
    Drivervehiclescreen(), // Records
    PendingDriversScreen(),
  ];




  @override
  void initState() {
    super.initState();
    _loadUserId();
    fetchCompletedTrips().then((trips) {
      setState(() {
        tripCount = trips.length;
      });
    });
    fetchonroadvehicle().then((vehicles) {
      setState(() {
        onRoadVehicleList = vehicles;
        onRoadVehicle = vehicles.length;
      });
    });
    fetchFuelDetails();
    fetchTodayMaintenances();
    fetchDriverTripsToday().then((trips) {
      setState(() => driverTrips = trips);
    });
    fetchAssignedTrips();
    _fetchAnalyticsCounts();
    fetchAdminProfile();
  }

  void _fetchAnalyticsCounts() async {
    try {
      final tripResponse = await http.get(Uri.parse('http://192.168.1.110:8081/api/Admin/GetTodayCompletedTripCount'));
      final fuelResponse = await http.get(Uri.parse('http://192.168.1.110:8081/api/Admin/GetTodayRefuelCount'));
      final maintenanceResponse = await http.get(Uri.parse('http://192.168.1.110:8081/api/Admin/GetTodayActiveMaintenanceCount'));
      final vehicleResponse = await http.get(Uri.parse('http://192.168.1.110:8081/api/Admin/GetTodayOnRoadVehicleCount'));

      if (tripResponse.statusCode == 200 &&
          fuelResponse.statusCode == 200 &&
          maintenanceResponse.statusCode == 200 &&
          vehicleResponse.statusCode == 200) {

        final tripData = json.decode(tripResponse.body);
        final fuelData = json.decode(fuelResponse.body);
        final maintenanceData = json.decode(maintenanceResponse.body);
        final vehicleData = json.decode(vehicleResponse.body);

        setState(() {
          tripCount = tripData['todayCompleteTrip'] ?? 0;
          fuelCount = fuelData['todayRefuel'] ?? 0;
          maintenanceCount = maintenanceData['todayMaintenance'] ?? 0;
          onRoadVehicle = vehicleData['todayOnRoadVehicle'] ?? 0;
        });
      } else {
        print("Failed to load analytics data.");
      }
    } catch (e) {
      print("Error fetching analytics data: $e");
    }
  }
  Future<void> fetchAdminProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('admin_userId');

    if (storedUserId != null) {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.110:8081/api/Admin/GetActiveAdmins?UserId=$storedUserId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'] as List;
        if (jsonData.isNotEmpty) {
          final admin = AdminProfileModel.fromJson(jsonData[0]);
          setState(() {
            adminName = admin.name;
            adminImage = admin.adminImage;
          });
        }
      } else {
        print("❌ Failed to fetch admin data. Status Code: ${response.statusCode}");
      }
    }
  }


  String _calculateTotalFuelPrice() {
    double total = fuelList.fold(0, (sum, item) => sum + item.fuelPrice);
    return total.toStringAsFixed(2);
  }

  void _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('admin_userId');

    if (storedUserId != null) {
      print('✅ Retrieved Admin User ID: $storedUserId');
      // You can use this ID if needed:
      // setState(() => userId = storedUserId);
    } else {
      print('❌ Admin User ID not found in SharedPreferences.');
    }
  }

  Future<void> fetchAssignedTrips() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.110:8081/api/Admin/GetTodayAssignTrips'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      setState(() {
        assignedTrips = list.map((e) => AssignedTrip.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load assigned trips');
    }
  }

  Future<List<DriverTrip>> fetchDriverTripsToday() async {
    final response = await http.get(
        Uri.parse("http://192.168.1.110:8081/api/Admin/GetDriverAllTripToday"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List trips = jsonData['data'];

      return trips.map((trip) => DriverTrip.fromJson(trip)).toList();
    } else {
      throw Exception("Failed to load driver trips");
    }
  }

  Future<void> fetchFuelDetails() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.110:8081/api/Admin/GetTodayFuelDetails'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List jsonList = data['data'];
      setState(() {
        fuelList = jsonList.map((e) => FuelEntry.fromJson(e)).toList();
        fuelCount = fuelList.length;
      });
    } else {
      throw Exception("Failed to load fuel details");
    }
  }

  Future<List<Trip>> fetchCompletedTrips() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.110:8081/api/Admin/GetTripsComplete'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List tripsJson = data['data'];
      return tripsJson.map((json) => Trip.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trips');
    }
  }

  Future<List<dynamic>> fetchonroadvehicle() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.110:8081/api/Admin/GetVehiclesOnRoad'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // full list
    } else {
      throw Exception('Failed to load onroad vehicles');
    }
  }

  Future<void> fetchTodayMaintenances() async {
    final response = await http.get(
      Uri.parse(
          "http://192.168.1.110:8081/api/Admin/GetTodayActiveMaintenances"),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List data = jsonData['data'];
      setState(() {
        maintenanceList =
            data.map((e) => MaintenanceEntry.fromJson(e)).toList();
        maintenanceCount = jsonData['count'];
      });
    } else {
      throw Exception("Failed to load maintenance data");
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AdminLoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: _selectedIndex == 0
            ? ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            _buildSearchBar(),
            SizedBox(height: 20),
            _buildSectionTitle("Today's Analytics"),
            _buildAnalyticsCards(context),
            SizedBox(height: 24),
            _buildSectionTitle("Live Assigned Vehicles"),
            _buildAssignedVehicleCard(),
            SizedBox(height: 24),
            _buildSectionTitle("Driver Activity"),
            _buildDriverActivity(),
            SizedBox(height: 80), // avoid nav bar overlap
          ],
        )
            : _pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child:  CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryColor,
            backgroundImage: adminImage != null ? NetworkImage(adminImage!) : null,
            child: adminImage == null && adminName != null
                ? Text(
              adminName![0],
              style: TextStyle(fontSize: 20, color: Colors.white),
            )
                : null,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello,",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text(
              adminName ?? "Loading...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        Spacer(),
        Icon(Icons.notifications_none, color: Colors.black),
      ],
    );
  }


  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search Drivers, Vehicles etc...",
        prefixIcon: Icon(Icons.search),
        suffixIcon: Icon(Icons.filter_list),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black12, width: 2),
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16));
  }

  Widget _buildAnalyticsCards(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAnalyticsItem(
            Icons.directions_bus,
            "$tripCount",
            "Trips Completed",
            "Across 7 drivers",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TripListScreen()),
              );
            },
          ),
          _buildAnalyticsItem(
            Icons.directions_car,
            "$onRoadVehicle",
            "Vehicles On Road",
            "Live tracking enabled",
            onTap: () {
              final today = DateTime.now();

              final filteredVehicles = onRoadVehicleList.where((vehicle) {
                final startTimeString = vehicle['startTime']?.toString();
                final startDate = DateTime.tryParse(startTimeString ?? '');
                return startDate != null &&
                    startDate.year == today.year &&
                    startDate.month == today.month &&
                    startDate.day == today.day;
              }).toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VehiclesOnRoadScreen(vehicleData: filteredVehicles),
                ),
              );
            },


          ),
          _buildAnalyticsItem(
            Icons.local_gas_station,
            "$fuelCount",
            "Refueling Entries",
            "₹${_calculateTotalFuelPrice()} total spent",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FuelListScreen(),
                ),
              );
            },
          ),


          _buildAnalyticsItem(
            Icons.settings,
            "$maintenanceCount", // 👈 display the count
            "Maintenance Logs",
            "Reported today",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MaintenanceListScreen(maintenanceList: maintenanceList),
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(IconData iconData,
      String count,
      String title,
      String subtitle, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 24,
                color: Colors.teal,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAssignedVehicleCard() {
    if (assignedTrips.isEmpty) return SizedBox(); // or placeholder

    final trip = assignedTrips.first;

    // Parse assignDate
    DateTime assignDateTime = DateTime.parse(trip.assignDate);
    String formattedTime = DateFormat.jm().format(
        assignDateTime); // e.g., 12:51 PM

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vehicle", style: TextStyle(color: Colors.grey)),
          Text(trip.vehicleNumber,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text("Driver", style: TextStyle(color: Colors.grey)),
          Text(trip.driverName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Assigned at $formattedTime",
                  style: TextStyle(color: Colors.black54)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // implement track action here
                },
                child: Text(
                    "Track Here", style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDriverActivity() {
    return Container(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: driverTrips.length,
        itemBuilder: (context, index) {
          final driver = driverTrips[index];
          final status = driver.tripStatus == "P" ? "On Trip" : "Completed";

          return Container(
            width: 180,
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.driverName, style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(driver.vehicleNumber,
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                  decoration: BoxDecoration(
                    color: status == "On Trip" ? Colors.green[100] : Colors
                        .blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == "On Trip" ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4)],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem("assets/Light.png", "Home", 0, isCustom: true),
          _buildNavItem("assets/admin2.png", "Approvals", 1, isCustom: true),
          _buildNavItem("assets/admi3.png", "Track", 2, isCustom: true),
          _buildNavItem("assets/driver.png", "New Drivers", 3, isCustom: true),
        ],
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index,
      {bool isCustom = false}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal.withOpacity(0.1) : Colors
                  .transparent,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: isSelected ? Colors.teal : Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.teal : Colors.grey,
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
              color: Colors.black,
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
                    backgroundColor:AppColors.primaryColor,
                    backgroundImage: adminImage != null ? NetworkImage(adminImage!) : null,
                    child: adminImage == null && adminName != null
                        ? Text(
                      adminName![0],
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    )
                        : null,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminName ?? "Loading...",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                        ),
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

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.person, "My Account", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProfile()));
                  }),
                  _buildDrawerItem(Icons.build, "Maintenance", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Drivervehiclescreen()));
                  }),
                  _buildDrawerItem(Icons.approval, "Approvals", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FuelMaintenanceScreen()));

                  }),
                  _buildDrawerItem(Icons.directions_car, "Add Vehicle", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddVehicleScreen()));

                  }),
                  _buildDrawerItem(Icons.directions_car, "Assign Vehicle", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AssignVehicleScreen()));

                  }),
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
        trailing: Icon(
            Icons.arrow_forward_ios, size: 16, color: Colors.black45),
        onTap: onTap,
      ),
    );
  }
}