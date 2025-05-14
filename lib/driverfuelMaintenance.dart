import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'driverfuelmodel.dart';
import 'drivermaintenancemodel.dart';

class DriverFuelMaintenance extends StatefulWidget {
  final int driverId;


  const DriverFuelMaintenance({Key? key, required this.driverId}) : super(key: key);

  @override
  _DriverFuelMaintenanceState createState() => _DriverFuelMaintenanceState();
}


class _DriverFuelMaintenanceState extends State<DriverFuelMaintenance> {

  List<FuelLog> fuelLogs = [];
  bool isFuelSelected = true;
  bool isLoading = true;
  List<Maintenance> maintenanceList = [];

  @override
  void initState() {
    super.initState();
    fetchFuelLogs();
    fetchMaintenanceData();
    print("Driver ID received: ${widget.driverId}");
  }

  Future<void> fetchFuelLogs() async {
    final response = await http.get(
      Uri.parse(
          "http://192.168.1.110:8081/api/Driver/GetFuelDetails?driverId=${widget
              .driverId}"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        fuelLogs = data.map((json) => FuelLog.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      print("Failed to load fuel logs");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMaintenanceData() async {
    final response = await http.get(Uri.parse(
      "http://192.168.1.110:8081/api/Driver/GetVehicleMaintenanceByDriver?driverId=${widget
          .driverId}",
    ));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        maintenanceList = data.map((e) => Maintenance.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      print("Failed to load maintenance data");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: Text(
      //     "Approvals",
      //     style: TextStyle(
      //       color: AppColors.primaryColor,
      //       fontSize: 18,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (_) => HomePage(driverId: widget.driverId)),
      //       );
      //     },
      //   ),
      // ),

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

        ],7
      ),
    );
  }

  Widget _buildFuelList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (fuelLogs.isEmpty) {
      return Center(child: Text("No fuel logs found."));
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
    String baseUrl = "http://192.168.1.110:8081";
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
                log.receiptImage != null
                    ? Image.network(
                    baseUrl + "/Images/" + log.receiptImage!, width: 100,
                    errorBuilder: (_, __, ___) => Icon(Icons.broken_image))
                    : Image.asset("assets/ScorpioClassic.png", width: 100),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.numberPlate,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Engine Type: ${log.engineType}"),
                      Text("Fuel Qty: ${log.fuelQuantity} L"),
                      Text("Fuel Cost: ₹${log.fuelPrice.toStringAsFixed(2)}"),
                      Text("Meter: ${log.meterReading} km"),
                    ],
                  ),
                ),
                Icon(Icons.local_gas_station_outlined, color: Colors.teal),
              ],
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
            Text(
              maintenance.createdOn.split("T")[0],
              style: TextStyle(color: AppColors.primaryColor),
            ),
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
                      // Text(maintenance.modelName,
                      //     style: TextStyle(
                      //         color: Colors.black,
                      //         fontStyle: FontStyle.italic)),
                      // Text(maintenance.fullName),
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
            // Center(
            //   child: OutlinedButton(
            //     onPressed: () {
            //       // Navigator.push(
            //       //   context,
            //       //   MaterialPageRoute(
            //       //     builder: (context) =>
            //       //         GetMaintenanceAllDataScreen(
            //       //             maintenance: maintenance),
            //       //   ),
            //       // );
            //     },
            //     child: Text("View Details"),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}