import 'package:flutter/material.dart';
import 'package:twende/l10n/l10n.dart'; // Add this import
import 'package:twende/screen/login.dart';
import 'package:twende/services/auth_service.dart';
import 'package:twende/services/storage_service.dart';
import 'package:twende/services/device_info_service.dart';
import '../../services/booking_service.dart';
import '../widgets/client_completed_ride_card.dart';
import '../widgets/empty_state.dart';

class CompletedRidesTab extends StatefulWidget {
  const CompletedRidesTab({Key? key}) : super(key: key);

  @override
  State<CompletedRidesTab> createState() => _CompletedRidesTabState();
}

class _CompletedRidesTabState extends State<CompletedRidesTab> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _completedTrips = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = false;
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
      _fetchCompletedTrips();
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

  Future<void> _fetchCompletedTrips({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      setState(() {
        _currentPage = 1;
        _errorMessage = '';
        _completedTrips = [];
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> response;

      if (_isGuestMode) {
        final phoneNumber = _phoneController.text.trim();
        if (phoneNumber.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Please enter your phone number to check completed trips';
          });
          return;
        }

        final deviceId = await DeviceInfoService.getDeviceId();

        response = await BookingService.getGuestCompletedBookings(
          deviceId: deviceId,
          phoneNumber: phoneNumber,
          page: _currentPage,
        );
      } else {
        response =
            await BookingService.getCompletedBookings(page: _currentPage);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response['success']) {
            final data = response['data'];
            final completedTrips = data['completed_trips'] ?? [];

            if (refresh) {
              _completedTrips = completedTrips;
            } else {
              _completedTrips.addAll(completedTrips);
            }

            // Update pagination info
            if (data['pagination'] != null) {
              _totalPages = data['pagination']['total_pages'] ?? 1;
              _hasMoreData = _currentPage < _totalPages;
            }
          } else {
            _errorMessage =
                response['message'] ?? 'Failed to load completed trips';
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

  void _loadMoreData() {
    if (!_isLoading && _hasMoreData) {
      _currentPage++;
      _fetchCompletedTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!; // Get localization

    if (_isGuestMode && _completedTrips.isEmpty) {
      return _buildGuestPhoneInput();
    }

    if (_isLoading && _completedTrips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _completedTrips.isEmpty) {
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
              onPressed: () => _fetchCompletedTrips(refresh: true),
              child: Text(s.retry),
            ),
          ],
        ),
      );
    }

    if (_completedTrips.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: s.noCompletedRides,
        subtitle: s.completedRidesWillAppearHere,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchCompletedTrips(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreData();
            return true;
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _completedTrips.length + (_hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _completedTrips.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return ClientCompletedRideCard(trip: _completedTrips[index]);
          },
        ),
      ),
    );
  }

  Widget _buildGuestPhoneInput() {
    final s = S.of(context)!; // Get localization

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 64, color: Color(0xFFF5141E)),
            const SizedBox(height: 24),
            Text(s.checkYourCompletedTrips,
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
                          _fetchCompletedTrips(refresh: true);
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
                        s.checkCompletedTrips,
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
