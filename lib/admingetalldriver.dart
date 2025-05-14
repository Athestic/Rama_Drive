import 'package:flutter/material.dart';
import 'colors.dart';
import 'homeadmin.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'getadmindriverdetails.dart';
import 'getalldrivermodel.dart';
import 'getadminvehiclemodel.dart';
import 'getadmindriverdetails.dart';
import 'getadminvehicledetails.dart';

class Drivervehiclescreen extends StatefulWidget {
  @override
  _DrivervehiclescreenState createState() => _DrivervehiclescreenState();
}

class _DrivervehiclescreenState extends State<Drivervehiclescreen> {
  bool isDriverSelected = true;
  List<Driver> _drivers = [];
  bool _isLoading = true;
  List<Vehicle> vehicles = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    fetchDrivers();
    fetchVehicles();
  }

  Future<void> fetchDrivers() async {
    final url = Uri.parse(
        'http://192.168.1.110:8081/api/Driver/GetActiveDrivers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _drivers = data.map((json) => Driver.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchVehicles() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.110:8081/api/Driver/VehicleAll'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        vehicles = data.map((json) => Vehicle.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Track",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePageAdmin()),
            );
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            _buildSearchAndFilter(),
            Expanded(
              child: isDriverSelected
                  ? _buildDriverList()
                  : _buildVehicleList(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          _buildTabButton("Driver", Icons.person, isDriverSelected),
          const SizedBox(width: 10),
          _buildTabButton("Vehicle", Icons.directions_car, !isDriverSelected),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isDriverSelected = (title == "Driver");
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF2E7D6F) : Colors.grey[300],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "search...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _drivers.length,
      itemBuilder: (context, index) {
        return _buildDriverCard(_drivers[index], context);
      },
    );
  }

  Widget _buildVehicleList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        return _buildVehicleCard(vehicles[index], context);
      },
    );
  }

  Widget _buildDriverCard(Driver driver, BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: driver.driverImage != null
                      ? Image.network(
                    'http://192.168.1.110:8081${driver.driverImage}',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    "assets/Group.png",
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16,
                              color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            driver.address ?? "Unknown",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverDetailsScreen(driver: driver),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text("View Details"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme
                      .of(context)
                      .primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, BuildContext context) {
    return Card(
      elevation: 4, // Add a subtle shadow for depth
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Vehicle Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: vehicle.vehicleImage != null
                      ? Image.network(
                    'http://192.168.1.110:8081${vehicle.vehicleImage}',
                    width: 100,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    "assets/ScorpioClassic.png",
                    width: 100,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Vehicle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.numberPlate,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Model Year: ${vehicle.modelYear}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.build_outlined,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          // Text(
                          //   "Maintenance Pending",
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     color: Colors.orange,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text("View Details"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme
                      .of(context)
                      .primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}