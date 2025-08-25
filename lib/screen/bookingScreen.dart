import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:twende/screen/bottomTab.dart';
import 'package:twende/screen/login.dart';
import 'package:twende/services/device_info_service.dart';
import 'package:twende/services/storage_service.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:twende/services/booking_service.dart';
import 'package:twende/models/booking_type_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:twende/l10n/l10n.dart';

class BookingScreen extends StatefulWidget {
  final loc.LocationData? initialPickupLocation;
  final String initialVehicleType;
  final String? categoryId;
  final String? bookingTypeId; // Add booking type ID

  const BookingScreen({
    Key? key,
    this.initialPickupLocation,
    this.initialVehicleType = 'Standard',
    this.categoryId,
    this.bookingTypeId,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String _selectedVehicleType = 'Standard';
  loc.Location location = loc.Location();
  bool _isLoadingPickupLocation = false;
  // Distance and fare calculation variables
  String _distance = '';
  String _duration = '';
  double _estimatedFare = 0.0;
  bool _isCalculatingDistance = false;
  bool _isGuestMode = false;
  String _totalDistance = '';

  // Location coordinates
  double? _pickupLat;
  double? _pickupLng;
  double? _destinationLat;
  double? _destinationLng;

  static const String _apiKey = 'AIzaSyBXaMspN9XlQhkUHiyLCXkQoEurPKrMeog';

  // Add a property to store duration in minutes
  int _estimatedDurationMinutes = 0;

  // Add a property to track booking processing state
  bool _isProcessingBooking = false;

  // Use only CategoryWithBookingType for the new dropdown system
  List<CategoryWithBookingType> _categories = [];
  CategoryWithBookingType? _selectedCategory;
  bool _isLoadingCategories = false;
  String _categoryError = '';

  // Add controllers for guest information
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _guestNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
    _setCurrentLocationAsPickup();
    // Initialize Google Directions API
    DirectionsService.init(_apiKey);

    // Fetch categories based on booking type ID
    if (widget.bookingTypeId != null) {
      _fetchCategoriesByBookingType(widget.bookingTypeId!);
    } else {
      // Default to booking type 1 (Ride with Driver)
      _fetchCategoriesByBookingType('1');
    }

    if (widget.initialPickupLocation != null) {
      _pickupLat = widget.initialPickupLocation!.latitude;
      _pickupLng = widget.initialPickupLocation!.longitude;
    } else {
      _setCurrentLocationAsPickup();
    }
  }

  Future<void> _checkGuestMode() async {
    final isGuest = await StorageService.isGuestMode();
    if (isGuest) {
      setState(() {
        _isGuestMode = true;
      });
    }
  }

  Future<void> _fetchCategoriesByBookingType(String bookingTypeId) async {
    setState(() {
      _isLoadingCategories = true;
      _categoryError = '';
    });

    try {
      final result =
          await BookingService.getCategoriesByBookingType(bookingTypeId);

      if (result['success']) {
        // The API now consistently returns arrays for all booking types
        final dynamic categoryData = result['data']['data'] ?? result['data'];
        List<dynamic> categoryList = [];

        if (categoryData is List) {
          // If it's already a list, use it directly
          categoryList = categoryData;
        } else if (categoryData is Map<String, dynamic>) {
          // If it's a single object, wrap it in a list (fallback)
          categoryList = [categoryData];
        } else {
          // If data structure is unexpected, log it and show error
          print('Unexpected data structure: $categoryData');
          setState(() {
            _categoryError = 'Unexpected data format received';
            _isLoadingCategories = false;
          });
          return;
        }

        setState(() {
          _categories = categoryList
              .map((json) => CategoryWithBookingType.fromJson(json))
              .where((category) => category.isActive)
              .toList();

          // Auto-select first category if available
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
          }

          _isLoadingCategories = false;
        });
        await _setCurrentLocationAsPickup();

        print(
            'Loaded ${_categories.length} categories for booking type $bookingTypeId');
        if (_categories.isNotEmpty) {
          print('Selected category: ${_selectedCategory?.availableVehicles}');
          print('Selected category: ${_selectedCategory?.catgName}');
          print('Category pricing type: ${_selectedCategory?.pricing['type']}');
          print('Category display price: ${_selectedCategory?.displayPrice}');
        }

        // Recalculate fare if destination is already set
        if (_distance.isNotEmpty && _selectedCategory != null) {
          _calculateDistanceAndFare();
        }
      } else {
        setState(() {
          _categoryError = result['message'];
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        _categoryError = 'Failed to fetch categories: $e';
        _isLoadingCategories = false;
      });
      print('Error fetching categories: $e');
    }
  }

// Calculate distance and fare using Google Directions API
  Future<void> _calculateDistanceAndFare() async {
    if (_pickupLat == null ||
        _pickupLng == null ||
        _destinationLat == null ||
        _destinationLng == null ||
        _selectedCategory == null) {
      return;
    }

    setState(() {
      _isCalculatingDistance = true;
    });

    try {
      final directionsService = DirectionsService();

      final request = DirectionsRequest(
        origin: '${_pickupLat},${_pickupLng}',
        destination: '${_destinationLat},${_destinationLng}',
        travelMode: TravelMode.driving,
      );

      directionsService.route(request,
          (DirectionsResult response, DirectionsStatus? status) {
        if (status == DirectionsStatus.ok &&
            response.routes?.isNotEmpty == true) {
          final route = response.routes!.first;
          final leg = route.legs?.first;

          if (leg != null) {
            setState(() {
              _distance = leg.distance?.text ?? '';
              _duration = leg.duration?.text ?? '';

              // Calculate fare based on category pricing type
              // double distanceInKm = (leg.distance?.value ?? 0) / 1000.0;
              double distanceInKm = (leg.distance?.value ?? 0) / 1000.0;
              int durationInMinutes = (leg.duration?.value ?? 0) ~/ 60;
              _totalDistance = distanceInKm.toStringAsFixed(2);
              if (_selectedCategory!.pricing != null) {
                final pricingType = _selectedCategory!.pricing['type'];

                if (pricingType == 'ride') {
                  // Booking type 1: Pay per km and per minute
                  double baseFare = double.tryParse(
                          _selectedCategory!.pricing['base_fee'] ?? '0') ??
                      0;
                  double baseKm = double.tryParse(
                          _selectedCategory!.pricing['base_km'] ?? '0') ??
                      0;
                  double perKmRate = double.tryParse(
                          _selectedCategory!.pricing['per_km_rate'] ?? '0') ??
                      0;

                  print('=== RIDE FARE CALCULATION ===');
                  print('Distance: $distanceInKm km');
                  print('Base KM: $baseKm km');
                  print('Base fare: $baseFare USD');
                  print('Per KM rate: $perKmRate USD');

                  if (distanceInKm <= baseKm) {
                    // Distance is within base km limit, charge only base fare
                    _estimatedFare = baseFare;
                    print('Distance <= Base KM: Using base fare only');
                    print('Final fare: $baseFare USD');
                  } else {
                    // Distance exceeds base km, calculate additional km charges

                    _estimatedFare = distanceInKm * perKmRate;
                    print("estimate Price: $_estimatedFare");
                    print('Distance > Base KM: Using base fare + per km rate');
                    print(
                        'Final fare: ${_estimatedFare.toStringAsFixed(0)} USD');
                  }
                  print('=============================');
                }
              } else {
                _estimatedFare = 1000.0; // Default fare
              }

              _isCalculatingDistance = false;
              _estimatedDurationMinutes = durationInMinutes;
            });

            print('=== FARE CALCULATION SUMMARY ===');
            print('Distance: $_distance ( km)');
            print('Pricing Type: ${_selectedCategory!.pricing['type']}');
            print('Category: ${_selectedCategory!.catgName}');
            print('Estimated Fare: ${_estimatedFare.toStringAsFixed(0)} USD');
            print('================================');
          } else {
            setState(() {
              _isCalculatingDistance = false;
            });
          }
        } else {
          setState(() {
            _isCalculatingDistance = false;
          });
          print('Error calculating route: $status');
        }
      });
    } catch (e) {
      setState(() {
        _isCalculatingDistance = false;
      });
      print('Error calculating distance: $e');
    }
  }

  // Google Places API integration for TypeAhead
  Future<List<PlaceSuggestion>> _getPlaceSuggestions(String query) async {
    if (query.isEmpty) return [];

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey&components=country:rw|country:ug|country:cf|country:cm|country:cd';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;

        return predictions
            .map((prediction) => PlaceSuggestion(
                  placeId: prediction['place_id'],
                  description: prediction['description'],
                  mainText: prediction['structured_formatting']['main_text'],
                  secondaryText: prediction['structured_formatting']
                          ['secondary_text'] ??
                      '',
                ))
            .toList();
      }
    } catch (e) {
      print('Error fetching place suggestions: $e');
    }
    return [];
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey&fields=geometry';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];

        setState(() {
          _destinationLat = location['lat'].toDouble();
          _destinationLng = location['lng'].toDouble();
        });

        print(
            "Selected place coordinates: ${_destinationLat}, ${_destinationLng}");

        // Calculate distance and fare when destination is selected
        _calculateDistanceAndFare();
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
  }

  void _confirmBooking() async {
    // Prevent booking if no vehicles available
    if (_selectedCategory != null &&
        (_selectedCategory!.availableVehicles == null ||
            (int.tryParse(_selectedCategory!.availableVehicles.toString()) ==
                0))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No vehicles available for this category.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isGuestMode) {
      _showGuestBookingDialog();
      return;
    }

    // Regular booking flow for authenticated users
    _processBooking();
  }

  void _showGuestBookingDialog() {
    final l10n = S.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.completeYourBooking),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.provideContactInfo,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _guestNameController,
                  decoration: InputDecoration(
                    labelText: l10n.yourName,
                    hintText: l10n.enterYourFullName,
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    hintText: l10n.phoneHint,
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.privacyInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (_guestNameController.text.trim().isEmpty ||
                    _phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.fillAllFields),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _processBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07723D),
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.confirmBooking),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processBooking() async {
    final l10n = S.of(context)!;

    // Show loading indicator
    setState(() {
      _isProcessingBooking = true;
    });

    try {
      if (_pickupLat == null ||
          _pickupLng == null ||
          _destinationLat == null ||
          _destinationLng == null ||
          _selectedCategory == null) {
        throw Exception('Missing required booking information');
      }

      // Get category ID
      int categoryId = int.tryParse(_selectedCategory!.catgId) ?? 1;
      print("_totalDistance&&&&&&&&&&&&&&&&: $_totalDistance");
      // Create booking with guest information if in guest mode
      final result = await BookingService.createBooking(
        pickupLocation: _pickupController.text,
        pickupLat: _pickupLat!,
        pickupLong: _pickupLng!,
        dropoffLocation: _destinationController.text,
        dropoffLat: _destinationLat!,
        dropoffLong: _destinationLng!,
        estimatedDuration: _estimatedDurationMinutes.toString(),
        estimated_km: _totalDistance,
        estimatedPrice: _estimatedFare.toStringAsFixed(0),
        categoryId: categoryId,
        phoneNumber: _isGuestMode ? _phoneController.text.trim() : null,
        guestName: _isGuestMode ? _guestNameController.text.trim() : null,
      );

      setState(() {
        _isProcessingBooking = false;
      });
      print("response: $result");
      if (result['success']) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BottomNavigation(
              initialIndex: 1, // Navigate to second tab (TrackingScreen)
              isGuestMode: _isGuestMode,
            ),
          ),
          (route) => false, // Remove all previous routes
        );
        // Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isGuestMode
                ? l10n.bookingRequestSent
                : l10n.bookingConfirmed(_selectedCategory!.catgName,
                    _estimatedFare.toStringAsFixed(0))),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingFailed(result['message'])),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingBooking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorBooking(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCategoryDropdown() {
    final l10n = S.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectCategory,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<CategoryWithBookingType>(
          items: (filter, infiniteScrollProps) => _categories,
          selectedItem: _selectedCategory,
          itemAsString: (CategoryWithBookingType category) => category.catgName,
          compareFn:
              (CategoryWithBookingType item1, CategoryWithBookingType item2) {
            return item1.catgId == item2.catgId;
          },
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: 'Select a category',
              prefixIcon: const Icon(Icons.category, color: Color(0xFF07723D)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF07723D), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: l10n.searchCategories,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            menuProps: const MenuProps(
              backgroundColor: Colors.white,
              elevation: 8,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            itemBuilder: (context, item, isSelected, isFocused) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF07723D).withOpacity(0.1)
                      : isFocused
                          ? Colors.grey.withOpacity(0.1)
                          : null,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07723D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Color(0xFF07723D),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.catgName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF07723D)
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.displayPrice,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF07723D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item.availableVehicles != null)
                            Text(
                              'Available vehicles: ${item.availableVehicles}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF07723D),
                        size: 20,
                      ),
                  ],
                ),
              );
            },
            fit: FlexFit.loose,
            constraints: const BoxConstraints(maxHeight: 300),
          ),
          onChanged: (CategoryWithBookingType? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });

            // Recalculate fare if destination is set
            if (_distance.isNotEmpty) {
              _calculateDistanceAndFare();
            }
          },
          validator: (CategoryWithBookingType? item) {
            if (item == null) {
              return "Please select a category";
            }
            return null;
          },
          dropdownBuilder: (context, selectedItem) {
            if (selectedItem == null) {
              return Text(
                l10n.selectACategory,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07723D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Color(0xFF07723D),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedItem.catgName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          selectedItem.displayPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF07723D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (selectedItem.availableVehicles != null)
                          Text(
                            'Available vehicles: ${selectedItem.availableVehicles}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _setCurrentLocationAsPickup() async {
    final l10n = S.of(context)!;

    try {
      // Show loading state
      setState(() {
        _isLoadingPickupLocation = true;
        _pickupController.text = l10n.gettingCurrentLocation;
      });

      loc.LocationData locationData = await location.getLocation();

      // Get the real address name using reverse geocoding
      String addressName = await _getReverseGeocodedAddress(
        locationData.latitude!,
        locationData.longitude!,
      );

      setState(() {
        _pickupLat = locationData.latitude;
        _pickupLng = locationData.longitude;
        _pickupController.text = addressName;
        _isLoadingPickupLocation = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _pickupController.text = l10n.errorGettingLocation;
        // _isLoadingPickupLocation = false;
      });
    }
  }

  // Add this new method to get the address from coordinates
  Future<String> _getReverseGeocodedAddress(double lat, double lng) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          String formattedAddress = result['formatted_address'];

          // Optional: Get a shorter, more readable address
          String shortAddress =
              _extractShortAddress(result['address_components']);

          // Return the short address if available, otherwise the full formatted address
          return shortAddress.isNotEmpty ? shortAddress : formattedAddress;
        }
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
    }

    // Fallback to coordinates if reverse geocoding fails
    return 'Current Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
  }

  // Helper method to extract a shorter, more readable address
  String _extractShortAddress(List<dynamic> addressComponents) {
    String streetNumber = '';
    String route = '';
    String locality = '';
    String sublocality = '';

    for (var component in addressComponents) {
      List<String> types = List<String>.from(component['types']);

      if (types.contains('street_number')) {
        streetNumber = component['long_name'];
      } else if (types.contains('route')) {
        route = component['long_name'];
      } else if (types.contains('locality')) {
        locality = component['long_name'];
      } else if (types.contains('sublocality') ||
          types.contains('sublocality_level_1')) {
        sublocality = component['long_name'];
      }
    }

    // Build a concise address
    List<String> addressParts = [];

    if (streetNumber.isNotEmpty && route.isNotEmpty) {
      addressParts.add('$streetNumber $route');
    } else if (route.isNotEmpty) {
      addressParts.add(route);
    }

    if (sublocality.isNotEmpty) {
      addressParts.add(sublocality);
    } else if (locality.isNotEmpty) {
      addressParts.add(locality);
    }

    return addressParts.join(', ');
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _phoneController.dispose();
    _guestNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookYourRide),
        backgroundColor: const Color(0xFF07723D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingCategories
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.selectCategory)
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  // Text(
                  //   l10n.whereTo,
                  //   style: const TextStyle(
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  // Text(
                  //   l10n.letsGetYouToDestination,
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     color: Colors.grey.shade600,
                  //   ),
                  // ),
                  // const SizedBox(height: 30),

                  // Category Selection Dropdown
                  if (_categories.isNotEmpty) _buildCategoryDropdown(),
                  const SizedBox(height: 24),

                  // Pickup Location Field
                  Text(
                    l10n.pickupLocation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pickupController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: l10n.pickupLocation,
                      prefixIcon: _isLoadingPickupLocation
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF07723D),
                                ),
                              ),
                            )
                          : const Icon(Icons.location_on,
                              color: Color(0xFF07723D)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.my_location,
                            color: Color(0xFF07723D)),
                        onPressed: _isLoadingPickupLocation
                            ? null
                            : _setCurrentLocationAsPickup,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF07723D), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Destination Field with TypeAhead
                  Text(
                    l10n.destination,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TypeAheadField<PlaceSuggestion>(
                    controller: _destinationController,
                    suggestionsCallback: (pattern) async {
                      return await _getPlaceSuggestions(pattern);
                    },
                    itemBuilder: (context, PlaceSuggestion suggestion) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF07723D),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    suggestion.mainText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (suggestion.secondaryText.isNotEmpty)
                                    Text(
                                      suggestion.secondaryText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                    onSelected: (PlaceSuggestion suggestion) {
                      _destinationController.text = suggestion.description;
                      _getPlaceDetails(suggestion.placeId);
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: l10n.whereAreYouGoing,
                          prefixIcon:
                              const Icon(Icons.flag, color: Color(0xFF07723D)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF07723D), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      );
                    },
                    decorationBuilder: (context, child) {
                      return Material(
                        type: MaterialType.card,
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: child,
                      );
                    },
                    offset: const Offset(0, 4),
                    constraints: const BoxConstraints(maxHeight: 300),
                    hideOnEmpty: true,
                    hideOnError: true,
                    hideOnLoading: false,
                    animationDuration: const Duration(milliseconds: 300),
                    direction: VerticalDirection.down,
                  ),
                  const SizedBox(height: 20),

                  // Distance and Fare Information
                  if (_distance.isNotEmpty || _isCalculatingDistance)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07723D).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF07723D).withOpacity(0.2)),
                      ),
                      child: _isCalculatingDistance
                          ? Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF07723D),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.calculatingDistanceAndFare,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.straighten,
                                            color: Color(0xFF07723D), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.distance(_totalDistance),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            color: Color(0xFF07723D), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${l10n.duration}: $_duration',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.attach_money,
                                        color: Color(0xFF07723D), size: 20),
                                    Text(
                                      l10n.estimatedFare(
                                          _estimatedFare.toStringAsFixed(0)),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF07723D),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),

                  const SizedBox(height: 40),

                  // Confirm Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: (_destinationController.text.isNotEmpty &&
                              _selectedCategory?.availableVehicles != null &&
                              int.tryParse(_selectedCategory!.availableVehicles
                                      .toString()) !=
                                  null &&
                              int.tryParse(_selectedCategory!.availableVehicles
                                      .toString())! >
                                  0)
                          ? const LinearGradient(
                              colors: [Color(0xFF07723D), Color(0xFF07723D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: (_destinationController.text.isEmpty ||
                              _selectedCategory?.availableVehicles == null ||
                              int.tryParse(_selectedCategory!.availableVehicles
                                      .toString()) ==
                                  0)
                          ? Colors.grey.shade300
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: (_destinationController.text.isNotEmpty &&
                              !_isProcessingBooking &&
                              _selectedCategory?.availableVehicles != null &&
                              int.tryParse(_selectedCategory!.availableVehicles
                                      .toString()) !=
                                  null &&
                              int.tryParse(_selectedCategory!.availableVehicles
                                      .toString())! >
                                  0)
                          ? _confirmBooking
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isProcessingBooking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color:
                                      (_destinationController.text.isNotEmpty &&
                                              _selectedCategory
                                                      ?.availableVehicles !=
                                                  null &&
                                              int.tryParse(_selectedCategory!
                                                      .availableVehicles
                                                      .toString()) !=
                                                  null &&
                                              int.tryParse(_selectedCategory!
                                                      .availableVehicles
                                                      .toString())! >
                                                  0)
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _estimatedFare > 0
                                      ? l10n.confirmBookingWithFare(
                                          _estimatedFare.toStringAsFixed(0))
                                      : l10n.confirmBooking,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: (_destinationController
                                                .text.isNotEmpty &&
                                            _selectedCategory
                                                    ?.availableVehicles !=
                                                null &&
                                            int.tryParse(_selectedCategory!
                                                    .availableVehicles
                                                    .toString()) !=
                                                null &&
                                            int.tryParse(_selectedCategory!
                                                    .availableVehicles
                                                    .toString())! >
                                                0)
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  // Show warning if no vehicles available
                  if (_selectedCategory != null &&
                      (_selectedCategory!.availableVehicles == null ||
                          int.tryParse(_selectedCategory!.availableVehicles
                                  .toString()) ==
                              0))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'No vehicles available for this category.',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

// Place suggestion model class
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}
