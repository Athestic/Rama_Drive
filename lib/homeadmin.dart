import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'vehicle_screen.dart';
import 'user.dart';
import 'adminlogin.dart';
import 'colors.dart';

class HomePageAdmin extends StatefulWidget {
  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/user.jpeg'),
                ),
                SizedBox(height: 10),
                Text(
                  "Rohit Gupta",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "rtg00112@gmail.com",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.teal),
            title: Text("Add Driver"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddDriverScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_car, color: Colors.teal),
            title: Text("Add Vehicle"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddVehicleScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout"),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/user.jpeg'),
          ),
          SizedBox(width: 15),
        ],
      ),
      drawer: _buildDrawer(context),
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
            _buildNavItem(Icons.home_sharp, "Home", 0),
            _buildNavItem("assets/approval.png", "Approvals", 1, isCustom: true),
            SizedBox(width: screenWidth * 0.1),
            _buildNavItem(Icons.directions_car, "Vehicles", 2),
            _buildNavItem(Icons.person, "Me", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(dynamic icon, String label, int index, {bool isCustom = false}) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isCustom
              ? Image.asset(
            icon,
            width: 24,
            height: 24,
            color: _selectedIndex == index ? AppColors.primaryColor1 : Colors.grey,
          )
              : Icon(
            icon,
            color: _selectedIndex == index ? AppColors.primaryColor1 : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? AppColors.primaryColor1 : Colors.grey,
              fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
