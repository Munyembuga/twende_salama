import 'package:flutter/material.dart';
import 'package:twende/l10n/l10n.dart'; // Add this import
import 'package:twende/screen/login.dart';
import 'package:twende/services/auth_service.dart';
import '../../services/booking_service.dart';
import 'ride_data.dart';
import '../widgets/ride_card.dart';
import '../widgets/empty_state.dart';
import '../../services/storage_service.dart';
import '../../services/device_info_service.dart';

class PendingRidesTab extends StatefulWidget {
  const PendingRidesTab({Key? key}) : super(key: key);

  @override
  State<PendingRidesTab> createState() => _PendingRidesTabState();
}

class _PendingRidesTabState extends State<PendingRidesTab> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _pendingBookings = [];
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
      _fetchPendingBookings();
    }
  }

  Future<void> _handleTokenExpiry() async {
    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> _fetchPendingBookings({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      setState(() {
        _currentPage = 1;
        _errorMessage = '';
        _pendingBookings = [];
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
            _errorMessage = 'Please enter your phone number to check bookings';
          });
          return;
        }

        final deviceId = await DeviceInfoService.getDeviceId();

        response = await BookingService.getGuestPendingBookings(
          deviceId: deviceId,
          phoneNumber: phoneNumber,
          page: _currentPage,
        );
      } else {
        response = await BookingService.getPendingBookings(page: _currentPage);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response['success']) {
            final data = response['data'];
            final bookings = data['bookings'] ?? [];

            if (refresh) {
              _pendingBookings = bookings;
            } else {
              _pendingBookings.addAll(bookings);
            }

            if (data['pagination'] != null) {
              _totalPages =
                  int.tryParse(data['pagination']['total_pages'].toString()) ??
                      1;
              _hasMoreData = _currentPage < _totalPages;
            }
          } else {
            _errorMessage = response['message'] ?? 'Failed to load bookings';
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
      _fetchPendingBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!; // Get localization

    if (_isGuestMode && _pendingBookings.isEmpty) {
      return _buildGuestPhoneInput();
    }

    if (_isLoading && _pendingBookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _pendingBookings.isEmpty) {
      if (_errorMessage.toLowerCase().contains('invalid or expired token')) {
        _handleTokenExpiry();
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchPendingBookings(refresh: true),
              child: Text(s.retry),
            ),
          ],
        ),
      );
    }

    if (_pendingBookings.isEmpty) {
      return EmptyState(
        icon: Icons.pending_outlined,
        title: s.noPendingRides,
        subtitle: s.pendingRidesWillAppearHere,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchPendingBookings(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreData();
            return true;
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pendingBookings.length + (_hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _pendingBookings.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final ride =
                RideData.transformBookingToRide(_pendingBookings[index]);
            return RideCard(ride: ride);
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
            const Icon(Icons.phone, size: 64, color: Color(0xFFF5141E)),
            const SizedBox(height: 24),
            Text(s.checkYourBookings,
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
                          _fetchPendingBookings(refresh: true);
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
                        s.checkBookings,
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
}
