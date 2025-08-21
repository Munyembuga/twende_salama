import 'package:flutter/material.dart';
import 'package:twende/l10n/l10n.dart';
import 'package:twende/main.dart';
import 'package:twende/services/storage_service.dart';
import 'package:twende/services/auth_service.dart';
import 'package:twende/services/driver_service.dart';
import 'package:twende/screen/login.dart';
import 'package:provider/provider.dart';

class ProfileDriverScreen extends StatefulWidget {
  const ProfileDriverScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDriverScreen> createState() => _ProfileDriverScreenState();
}

class _ProfileDriverScreenState extends State<ProfileDriverScreen> {
  bool _isSecurityExpanded = false;
  bool _enableDriverCalls = false;
  bool _shareLiveLocation = false;
  bool _privateMode = false;

  // Driver status variables
  bool _isUpdatingStatus = false;
  String _statusUpdateMessage = '';
  int _driverId = 0;

  // User data variables
  String firstName = '';
  String lastName = '';
  String wallet = '';
  String email = '';
  String status = '';
  bool isLoading = true;

  // Monthly rides statistics variables
  Map<String, dynamic> monthlyStats = {};
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userType = await StorageService.getUserType();
      print("Current user type: $userType");

      final userData = await StorageService.getUserData();
      final clientData = await StorageService.getClientData();
      final driverData = await StorageService.getDriverData();

      print("User Data: $userData");
      print("Driver Data: $driverData");
      print("Client Data: $clientData");

      if (driverData != null) {
        setState(() {
          // Make sure we're accessing the right fields
          wallet = driverData['wallet_balance'] ?? '';
          _driverId =
              int.tryParse(driverData['driver_id']?.toString() ?? '0') ?? 0;
          firstName = driverData['fname'] ?? '';
          lastName = driverData['lname'] ?? '';
          email = driverData['email'] ?? '';

          print("Wallet balance: $wallet");
          print("Driver ID: $_driverId");
        });

        // Fetch current driver status from API
        if (_driverId > 0) {
          try {
            final statusResult =
                await DriverService.getDriverStatus(driverId: _driverId);
            if (statusResult['success']) {
              setState(() {
                final statusCode = statusResult['status'];
                _privateMode = statusCode == '3'; // 3 = Available
                print(
                    "Current driver status from API: $statusCode (${statusResult['status_label']})");
              });
            } else {
              print("Failed to get driver status: ${statusResult['message']}");
            }
          } catch (e) {
            print("Error fetching driver status: $e");
          }
        }
      }

      // If driver data didn't have name/email, fall back to user data
      if (firstName.isEmpty && userData != null) {
        setState(() {
          firstName = userData['fname'] ?? '';
          lastName = userData['lname'] ?? '';
          email = userData['email'] ?? '';
          status = userData['sts'] == '1' ? 'Active' : 'Inactive';
        });
      }

      // Load monthly rides statistics
      if (_driverId > 0) {
        await _loadMonthlyStats();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        isLoading = false;
        isLoadingStats = false;
      });
    }
  }

  Future<void> _loadMonthlyStats() async {
    try {
      setState(() {
        isLoadingStats = true;
      });

      final result = await DriverService.getDriverMonthlyRides(
        driverId: _driverId,
        context: context,
      );

      if (result['success']) {
        setState(() {
          monthlyStats = result;
          isLoadingStats = false;
        });
        print("Monthly stats loaded: ${result['data']}");
      } else {
        print("Failed to load monthly stats: ${result['message']}");
        setState(() {
          isLoadingStats = false;
        });
      }
    } catch (e) {
      print("Error loading monthly stats: $e");
      setState(() {
        isLoadingStats = false;
      });
    }
  }

  // Method to update driver status
  Future<void> _updateDriverStatus(bool isAvailable) async {
    setState(() {
      _isUpdatingStatus = true;
      _statusUpdateMessage = '';
    });

    try {
      // Convert boolean to int: available = 3, offline = 5
      final statusCode = isAvailable ? 3 : 5;

      final result = await AuthService.updateDriverStatus(
        driverId: _driverId,
        status: statusCode,
      );

      setState(() {
        _isUpdatingStatus = false;
        if (result['success']) {
          _privateMode = isAvailable; // Update the toggle state
          _statusUpdateMessage = 'Status updated to ${result['status']}';
          status = isAvailable ? 'Available' : 'Offline';

          // Show a success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Driver status updated to ${isAvailable ? 'Available' : 'Offline'}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _statusUpdateMessage = result['message'];
          print("Status update failed: ${result['message']}");
          // Show an error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Color(0xFF07723D),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isUpdatingStatus = false;
        _statusUpdateMessage = 'Failed to update status: $e';
        print("Error updating driver status: $e");
        // Show an error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Color(0xFF07723D),
          ),
        );
      });
    }
  }

  Future<void> _handleLogout() async {
    final s = S.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Logout icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF07723D).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  size: 40,
                  color: Color(0xFF07723D),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                s.logout,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                s.areYouSureLogout,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        s.cancel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Logout button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF07723D),
                            ),
                          ),
                        );

                        await AuthService.logout();

                        // Close loading indicator and navigate
                        Navigator.of(context).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF07723D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        s.logout,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    final s = S.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar (optional)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                s.selectLanguage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Language options
              ...S.supportedLocales.map((locale) {
                final flag = _getFlag(locale.languageCode);
                final languageName =
                    locale.languageCode == 'en' ? s.english : s.french;

                return ListTile(
                  leading: Text(flag, style: const TextStyle(fontSize: 24)),
                  title: Text(languageName),
                  trailing: Icon(
                    Localizations.localeOf(context).languageCode ==
                            locale.languageCode
                        ? Icons.check_circle
                        : null,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    localeProvider.setLocale(locale);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
              // Cancel button (optional, since users can swipe down or tap outside)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(s.cancel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'fr':
        return '🇫🇷';
      case 'en':
      default:
        return '🇺🇸';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Get real stats from API or use defaults
    final totalRides = monthlyStats['rides_count']?.toString() ?? '0';
    final thisMonth = monthlyStats['completed_rides']?.toString() ?? '0';
    final avgEarnings =
        monthlyStats['statistics']?['average_ride_amount']?.toString() ?? '0';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF07723D),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top row with title and edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.driverProfile,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            // Edit profile functionality
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Profile info row
                    Row(
                      children: [
                        // Profile avatar
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            firstName.isNotEmpty
                                ? '${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}'
                                    .toUpperCase()
                                : 'D',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Profile details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$firstName $lastName',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              wallet.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${s.wallet}: $wallet USD',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),

                        // Status indicator - Updated to show Available/Offline based on _privateMode
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _privateMode ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _privateMode ? s.available : s.offline,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Quick stats container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Display month name if available
                  if (monthlyStats['month_name'] != null && !isLoadingStats)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        monthlyStats['month_name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA77D55),
                        ),
                      ),
                    ),
                  // Quick stats or additional info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                          s.totalRides, totalRides, Icons.directions_car),
                      _buildQuickStat(
                          s.thisMonth, thisMonth, Icons.calendar_month),
                      _buildQuickStat(
                          'Avg USD', avgEarnings, Icons.monetization_on),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Security & Privacy Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSecurityExpanded = !_isSecurityExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.security,
                                color: Color(0xFFA77D55),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                s.securityPrivacy,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA77D55),
                                ),
                              ),
                            ],
                          ),
                          AnimatedRotation(
                            turns: _isSecurityExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFFA77D55),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isSecurityExpanded ? null : 0,
                    child: _isSecurityExpanded
                        ? Column(
                            children: [
                              Container(
                                height: 1,
                                color: Colors.grey.withOpacity(0.2),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                              ),

                              _buildToggleOption(
                                Icons.location_on,
                                s.shareLiveLocation,
                                s.shareLocationWithApp,
                                _shareLiveLocation,
                                (value) {
                                  setState(() {
                                    _shareLiveLocation = value;
                                  });
                                },
                              ),
                              // This is the toggle for driver status (available/offline)
                              _isUpdatingStatus
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : _buildToggleOption(
                                      Icons.radio_button_checked,
                                      s.driverAvailability,
                                      s.toggleAvailabilityDescription,
                                      _privateMode,
                                      (value) async {
                                        // Call API to update status
                                        await _updateDriverStatus(value);
                                      },
                                    ),
                              if (_statusUpdateMessage.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: Text(
                                    _statusUpdateMessage,
                                    style: TextStyle(
                                      color: _privateMode
                                          ? Colors.green
                                          : Color(0xFF07723D),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // _buildProfileOption(
                  //     Icons.person_outline, s.personalInformation, () {}),
                  // _buildProfileOption(Icons.business, s.companyDetails, () {}),
                  // _buildProfileOption(Icons.payment, s.paymentMethods, () {}),
                  // _buildProfileOption(
                  //     Icons.favorite, s.favoriteDestinations, () {}),
                  _buildProfileOption(
                      Icons.language, s.language, _showLanguageDialog),
                  // _buildProfileOption(Icons.help_outline, s.helpSupport, () {}),
                  _buildProfileOption(Icons.logout, s.logout, _handleLogout,
                      isLast: true, isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFA77D55),
          size: 24,
        ),
        const SizedBox(height: 4),
        isLoadingStats
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFA77D55),
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA77D55),
                ),
              ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap,
      {bool isLast = false, bool isLogout = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Color(0xFF07723D) : Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Color(0xFF07723D) : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isLogout ? Color(0xFF07723D) : Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(IconData icon, String title, String subtitle,
      bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFA77D55),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFA77D55),
          ),
        ],
      ),
    );
  }
}
