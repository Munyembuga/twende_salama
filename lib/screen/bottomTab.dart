import 'package:flutter/material.dart';
import 'package:twende/screen/profileScreen.dart';
import 'package:twende/screen/trackingScreen.dart';
import 'package:twende/screen/homeScreen.dart';
import 'package:twende/screen/login.dart';
import 'package:twende/services/storage_service.dart';
import 'package:twende/screen/mainRentScreen.dart';
import 'package:twende/l10n/l10n.dart';

class BottomNavigation extends StatefulWidget {
  final int initialIndex;
  final bool isGuestMode;

  const BottomNavigation({
    Key? key,
    this.initialIndex = 0,
    this.isGuestMode = false,
  }) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigation> {
  late int _selectedIndex;
  late bool _isGuestMode;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _isGuestMode = widget.isGuestMode;
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    if (!widget.isGuestMode) {
      final isGuest = await StorageService.isGuestMode();
      if (isGuest) {
        setState(() {
          _isGuestMode = true;
        });
      }
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const TrackingScreen();
      case 2:
        return const MainRentScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  void _onItemTapped(int index) {
    if (_isGuestMode && index == 3) {
      _showLoginPrompt();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginPrompt() {
    final s = S.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(s.loginRequired),
          content: Text(s.loginMessage),
          actions: <Widget>[
            TextButton(
              child: Text(s.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                s.login,
                style: const TextStyle(color: Color(0xFFF5141E)),
              ),
              onPressed: () {
                StorageService.clearGuestSession().then((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color(0xFFF5141E),
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: s.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_car),
            label: s.ride,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.car_rental),
            label: 'Rent',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_2_outlined),
            label: s.profile,
          ),
        ],
      ),
    );
  }
}
