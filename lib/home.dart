import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  int _selectedIndex = 1; // Default to Home tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context), // Pass context here
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
      backgroundColor: Colors.teal.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildRecentTripSection(),
            _buildVehicleHealthSection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/Group.png',
              width: 24, // Adjust width as needed
              height: 24, // Adjust height as needed
            ),
            label: 'Trip',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        backgroundColor: Colors.white,
      ),

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
                  "Rohit Gupta", // Replace with actual user name
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "rtg00112@gmail.com", // Replace with actual email
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.teal),
            title: Text("Home"),
            onTap: () {
              Navigator.pop(context); // Now `context` is available
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.teal),
            title: Text("Settings"),
            onTap: () {},
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


  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade800],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today Assigned Vehicle", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("UP 78 AB 2345", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Scorpio Classic (2022)", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor2,// Background color
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.speed, color: Colors.white, size: 20),
                              SizedBox(width: 5),
                              Text("20,000 km", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor2,// Background color
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_gas_station, color: Colors.white, size: 20), // Fuel icon
                              SizedBox(width: 5),
                              Text("Petrol", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              Image.asset('assets/ScorpioClassic.png', height: 100),
            ],
          ),
          SizedBox(height: 15),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:AppColors.primaryColor2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: Text("Details →", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomNavigation() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.home, color: Colors.teal), onPressed: () {}),
          SizedBox(width: 40),
          IconButton(icon: Icon(Icons.person, color: Colors.teal), onPressed: () {}),
        ],
      ),
    );
  }
}


  Widget _buildRecentTripSection() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.teal.shade700,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Trip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hapur", style: TextStyle(color: Colors.white)),
                Icon(Icons.arrow_forward, color: Colors.white),
                Text("Lakhanpur", style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleHealthSection() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Assigned Vehicle Health", style: TextStyle(fontWeight: FontWeight.bold)),
            Divider(),
            ListTile(
              leading: Icon(Icons.directions_car, color: Colors.teal),
              title: Text("UP78-AB-2345"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tire Pressure: OK"),
                  Text("Reported Issue: No"),
                  Text("Next Service Due: 12-03-2024"),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:AppColors.primaryColor2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Report Issue", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.home, color: Colors.teal), onPressed: () {}),
          SizedBox(width: 40), // Space for FAB
          IconButton(icon: Icon(Icons.person, color: Colors.teal), onPressed: () {}),
        ],
      ),
    );
  }
