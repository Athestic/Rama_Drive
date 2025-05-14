import 'package:flutter/material.dart';
import 'colors.dart';
import 'homeadmin.dart';
import 'getadminfuellogmodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'getadminfuellogalldata.dart';
import 'getmaintenancealldata.dart';
import 'getadmaintenancemodel.dart';


class FuelMaintenanceScreen extends StatefulWidget {
  @override
  _FuelMaintenanceScreenState createState() => _FuelMaintenanceScreenState();
}

class _FuelMaintenanceScreenState extends State<FuelMaintenanceScreen> {
  bool isFuelSelected = true;
  List<Maintenance> maintenanceList = [];
  bool isLoading = true;
  List<FuelLog> fuelLogs = [];

  @override
  void initState() {
    super.initState();
    fetchFuelLogs();
    fetchMaintenanceData();
  }

  Future<void> fetchFuelLogs() async {
    final url = Uri.parse(
        "http://192.168.1.110:8081/api/Admin/GetTodayFuelDetails");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        setState(() {
          fuelLogs = data.map((e) => FuelLog.fromJson(e)).toList();
        });
      } else {
        print("Failed to fetch fuel data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching fuel data: $e");
    }
  }

  Future<void> fetchMaintenanceData() async {
    final url = Uri.parse(
        "http://192.168.1.110:8081/api/Admin/GetTodayActiveMaintenances");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'];

        setState(() {
          maintenanceList =
              data.map((item) => Maintenance.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to load maintenance data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Logs",
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
              child: isFuelSelected
                  ? _buildFuelList()
                  : _buildMaintenanceList(),
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
          _buildTabButton("Fuel", Icons.local_gas_station, isFuelSelected),
          const SizedBox(width: 10),
          _buildTabButton("Maintenance", Icons.build, !isFuelSelected),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isFuelSelected = (title == "Fuel");
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
          const SizedBox(width: 10),
          Chip(
            label: Text("Approved",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFuelList() {
    if (fuelLogs.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: fuelLogs.length,
      itemBuilder: (context, index) {
        return _buildFuelCard(fuelLogs[index]);
      },
    );
  }


  Widget _buildMaintenanceList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: maintenanceList.length,
      itemBuilder: (context, index) {
        return _buildMaintenanceCard(maintenanceList[index]);
      },
    );
  }


  Widget _buildFuelCard(FuelLog log) {
    String baseUrl = "http://192.168.1.110:8081"; // for vehicleImage and receiptImage
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.createdOn.split("T")[0],
                style: TextStyle(color: Colors.teal)),
            const SizedBox(height: 5),
            Row(
              children: [
                log.vehicleImage != null
                    ? Image.network(
                  baseUrl + log.vehicleImage!,
                  width: 100,
                  errorBuilder: (_, __, ___) => Icon(Icons.car_repair),
                )
                    : Image.asset("assets/ScorpioClassic.png", width: 100),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.numberPlate,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(log.fullName),
                      const SizedBox(height: 5),
                      Text("Fuel Quantity   ${log.fuelQuantity} Ltr"),
                      Text("Fuel Cost   ₹${log.fuelPrice.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
                Icon(Icons.local_gas_station_outlined, color: Colors.teal),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FuelLogAllDataScreen(fuelLog: log),
                      ),
                    );
                  },
                  icon: Icon(Icons.visibility_outlined),
                  label: const Text("View Details"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard(Maintenance maintenance) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(maintenance.createdOn.split("T")[0],
                style: TextStyle(color: AppColors.primaryColor)),
            const SizedBox(height: 5),
            Row(
              children: [
                maintenance.vehicleImage.isNotEmpty
                    ? Image.network(
                    "http://192.168.1.110:8081${maintenance.vehicleImage}",
                    width: 100)
                    : Image.asset("assets/ScorpioClassic.png", width: 100),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(maintenance.numberPlate,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(maintenance.fullName),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Issue: ${maintenance.maintenancType}"),
                          Text("Status: Completed"),
                          Text("Cost: ₹${maintenance.serviceCost}"),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.build_outlined, color: AppColors.secondaryColor),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GetMaintenanceAllDataScreen(maintenance: maintenance),
                      ),
                    );
                  },
                  icon: Icon(Icons.visibility_outlined),
                  label: const Text("View Details",
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}