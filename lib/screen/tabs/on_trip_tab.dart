import 'package:flutter/material.dart';
import 'package:twende/l10n/l10n.dart';
import 'package:twende/screen/login.dart';
import 'package:twende/services/auth_service.dart';
import 'package:twende/services/storage_service.dart';
import 'package:twende/services/device_info_service.dart';
import '../../services/booking_service.dart';
import 'ride_data.dart';
import '../widgets/ride_card.dart';
import '../widgets/empty_state.dart';

class OnTripTab extends StatefulWidget {
  const OnTripTab({Key? key}) : super(key: key);

  @override
  State<OnTripTab> createState() => _OnTripTabState();
}

class _OnTripTabState extends State<OnTripTab> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _onTripBookings = [];
  bool _clientOnTrip = false;
  bool _isGuestMode = false;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
    _phoneController.addListener(() {
      // Clear error message when typing
      if (_errorMessage.isNotEmpty) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }

  Future<void> _checkGuestMode() async {
    final isGuest = await StorageService.isGuestMode();
    setState(() {
      _isGuestMode = isGuest;
    });

    if (!isGuest) {
      _fetchOnTripBookings();
    }
  }

  Future<void> _handleTokenExpiry() async {
    try {
      await AuthService.logout();

      // Navigate to login screen and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Handle logout error if needed
      print('Error during logout: $e');
    }
  }

  Future<void> _fetchOnTripBookings({bool refresh = false}) async {
    // Remove the early return that was preventing execution when loading
    // if (_isLoading) return;

    if (refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _onTripBookings = [];
      });
    } else if (!_isLoading) {
      // Only set loading to true if not already loading
      setState(() {
        _isLoading = true;
      });
    }

    try {
      Map<String, dynamic> response;

      if (_isGuestMode) {
        final phoneNumber = _phoneController.text.trim();
        if (phoneNumber.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Please enter your phone number to check active trips';
          });
          return;
        }

        final deviceId = await DeviceInfoService.getDeviceId();

        response = await BookingService.getGuestOnTripBookings(
          deviceId: deviceId,
          phoneNumber: phoneNumber,
        );
      } else {
        response = await BookingService.getOnTripBookings();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response['success']) {
            final data = response['data'];
            _onTripBookings = data['bookings'] ?? [];
            _clientOnTrip = data['client_on_trip'] ?? false;
          } else {
            _errorMessage =
                response['message'] ?? 'Failed to load on trip bookings';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred while fetching data';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    if (_isGuestMode && _onTripBookings.isEmpty) {
      return _buildGuestPhoneInput();
    }

    if (_isLoading && _onTripBookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _onTripBookings.isEmpty) {
      if (_errorMessage.toLowerCase().contains('invalid or expired token')) {
        // Automatically logout and redirect to login
        _handleTokenExpiry();
        return const Center(
          child: CircularProgressIndicator(), // Show loading while redirecting
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchOnTripBookings(refresh: true),
              child: Text(s.retry),
            ),
          ],
        ),
      );
    }

    if (_onTripBookings.isEmpty) {
      return EmptyState(
        icon: Icons.directions_car_outlined,
        title: s.noActiveTrips,
        subtitle: s.activeTripsWillAppearHere,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchOnTripBookings(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _onTripBookings.length,
        itemBuilder: (context, index) {
          final ride = RideData.transformBookingToRide(_onTripBookings[index]);
          return RideCard(ride: ride);
        },
      ),
    );
  }

  Widget _buildGuestPhoneInput() {
    final s = S.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 64, color: Color(0xFFF5141E)),
            const SizedBox(height: 24),
            Text(s.checkYourActiveTrips,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              s.enterPhoneForBooking,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: s.phoneNumber,
                hintText: s.phoneHint,
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFF5141E), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        final phone = _phoneController.text.trim();
                        if (phone.isNotEmpty) {
                          FocusScope.of(context).unfocus();
                          _fetchOnTripBookings(refresh: true);
                        } else {
                          setState(() {
                            _errorMessage = s.pleaseProvideReason;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5141E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        s.checkActiveTrips,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
