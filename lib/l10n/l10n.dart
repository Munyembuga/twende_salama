import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Twende Salama'**
  String get appName;

  /// No description provided for @fastReliable.
  ///
  /// In en, this message translates to:
  /// **'Fast & Reliable Rides'**
  String get fastReliable;

  /// No description provided for @getToDestination.
  ///
  /// In en, this message translates to:
  /// **'Get to your destination on time, every time'**
  String get getToDestination;

  /// No description provided for @safeSecure.
  ///
  /// In en, this message translates to:
  /// **'Safe & Secure'**
  String get safeSecure;

  /// No description provided for @safetyPriority.
  ///
  /// In en, this message translates to:
  /// **'Your safety is our top priority'**
  String get safetyPriority;

  /// No description provided for @affordablePrices.
  ///
  /// In en, this message translates to:
  /// **'Affordable Prices'**
  String get affordablePrices;

  /// No description provided for @premiumService.
  ///
  /// In en, this message translates to:
  /// **'Enjoy premium service at competitive rates'**
  String get premiumService;

  /// No description provided for @bookingTypes.
  ///
  /// In en, this message translates to:
  /// **'Booking Types'**
  String get bookingTypes;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load booking types'**
  String get failedToLoad;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @loginMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to create an account or log in to book a ride.'**
  String get loginMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @bookYourRide.
  ///
  /// In en, this message translates to:
  /// **'Book Your Ride'**
  String get bookYourRide;

  /// No description provided for @whereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// No description provided for @letsGetYouToDestination.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you to your destination'**
  String get letsGetYouToDestination;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @gettingCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting current location...'**
  String get gettingCurrentLocation;

  /// No description provided for @errorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting location'**
  String get errorGettingLocation;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @whereAreYouGoing.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get whereAreYouGoing;

  /// No description provided for @calculatingDistanceAndFare.
  ///
  /// In en, this message translates to:
  /// **'Calculating distance and fare...'**
  String get calculatingDistanceAndFare;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance}'**
  String distance(Object distance);

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endDate;

  /// No description provided for @estimatedFare.
  ///
  /// In en, this message translates to:
  /// **'Estimated Fare: {fare} RWF'**
  String estimatedFare(Object fare);

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @confirmBookingWithFare.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking - {fare} RWF'**
  String confirmBookingWithFare(Object fare);

  /// No description provided for @completeYourBooking.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Booking'**
  String get completeYourBooking;

  /// No description provided for @provideContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Please provide your contact information to complete the booking:'**
  String get provideContactInfo;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'0788123456'**
  String get phoneHint;

  /// No description provided for @privacyInfo.
  ///
  /// In en, this message translates to:
  /// **'Your information will only be used for this booking.'**
  String get privacyInfo;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed! {category} - {fare} RWF'**
  String bookingConfirmed(Object category, Object fare);

  /// No description provided for @bookingRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Booking request sent! You will be contacted shortly.'**
  String get bookingRequestSent;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed: {message}'**
  String bookingFailed(Object message);

  /// No description provided for @errorBooking.
  ///
  /// In en, this message translates to:
  /// **'Error creating booking: {error}'**
  String errorBooking(Object error);

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategories;

  /// No description provided for @selectACategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectACategory;

  /// No description provided for @rentCar.
  ///
  /// In en, this message translates to:
  /// **'Rent a Car'**
  String get rentCar;

  /// No description provided for @rentCarWithDriver.
  ///
  /// In en, this message translates to:
  /// **'Rent a Car with Driver'**
  String get rentCarWithDriver;

  /// No description provided for @rentalOptions.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred rental options'**
  String get rentalOptions;

  /// No description provided for @vehicleCategories.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Categories'**
  String get vehicleCategories;

  /// No description provided for @rentalDurationType.
  ///
  /// In en, this message translates to:
  /// **'Rental Duration Type'**
  String get rentalDurationType;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @numberOfUnits.
  ///
  /// In en, this message translates to:
  /// **'Number of Day(s)'**
  String get numberOfUnits;

  /// No description provided for @pickupDate.
  ///
  /// In en, this message translates to:
  /// **'Pickup Date'**
  String get pickupDate;

  /// No description provided for @returnDate.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// No description provided for @durationType.
  ///
  /// In en, this message translates to:
  /// **'Duration Type: {type}'**
  String durationType(Object type);

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration: {duration} {unit}'**
  String totalDuration(Object duration, Object unit);

  /// No description provided for @ratePerDuration.
  ///
  /// In en, this message translates to:
  /// **'Rate: {price} RWF per {unit}'**
  String ratePerDuration(Object price, Object unit);

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total: {price} RWF'**
  String totalPrice(Object price);

  /// No description provided for @priceIncludesDriver.
  ///
  /// In en, this message translates to:
  /// **'Price includes driver'**
  String get priceIncludesDriver;

  /// No description provided for @confirmRental.
  ///
  /// In en, this message translates to:
  /// **'Confirm Rental'**
  String get confirmRental;

  /// No description provided for @confirmRentalWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Confirm Rental - {price} RWF'**
  String confirmRentalWithPrice(Object price);

  /// No description provided for @completeYourRental.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Rental'**
  String get completeYourRental;

  /// No description provided for @provideRentalContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Please provide your contact information to complete the rental:'**
  String get provideRentalContactInfo;

  /// No description provided for @selectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @loadingRentalOptions.
  ///
  /// In en, this message translates to:
  /// **'Loading rental options...'**
  String get loadingRentalOptions;

  /// No description provided for @ride.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get ride;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @cancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRide;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get callDriver;

  /// No description provided for @rideCancelled.
  ///
  /// In en, this message translates to:
  /// **'Ride cancelled'**
  String get rideCancelled;

  /// No description provided for @phoneNumberNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNumberNotAvailable;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknown;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @onTrip.
  ///
  /// In en, this message translates to:
  /// **'On Trip'**
  String get onTrip;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get startTrip;

  /// No description provided for @enterOtpMessage.
  ///
  /// In en, this message translates to:
  /// **'Please ask the client for the OTP code to start the trip.'**
  String get enterOtpMessage;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOTP;

  /// No description provided for @sixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get sixDigitCode;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @locationCoordsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location coordinates not available for navigation'**
  String get locationCoordsNotAvailable;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @startNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get startNavigation;

  /// No description provided for @googleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMaps;

  /// No description provided for @unknownPickup.
  ///
  /// In en, this message translates to:
  /// **'Unknown pickup'**
  String get unknownPickup;

  /// No description provided for @unknownDestination.
  ///
  /// In en, this message translates to:
  /// **'Unknown destination'**
  String get unknownDestination;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @tripWithId.
  ///
  /// In en, this message translates to:
  /// **'Trip {id}'**
  String tripWithId(Object id);

  /// No description provided for @navigateToPickup.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Pickup'**
  String get navigateToPickup;

  /// No description provided for @startedAt.
  ///
  /// In en, this message translates to:
  /// **'Started: {time}'**
  String startedAt(Object time);

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed: {time}'**
  String completedAt(Object time);

  /// No description provided for @bookingCode.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookingCode;

  /// No description provided for @initialPayment.
  ///
  /// In en, this message translates to:
  /// **'Initial Payment'**
  String get initialPayment;

  /// No description provided for @totalEstimated.
  ///
  /// In en, this message translates to:
  /// **'Total Estimated'**
  String get totalEstimated;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @checkYourCarRentals.
  ///
  /// In en, this message translates to:
  /// **'Check Your Car Rentals'**
  String get checkYourCarRentals;

  /// No description provided for @enterPhoneForRentals.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number you used when making the rental booking'**
  String get enterPhoneForRentals;

  /// No description provided for @checkYourConfirmedRentals.
  ///
  /// In en, this message translates to:
  /// **'Check Your Confirmed Rentals'**
  String get checkYourConfirmedRentals;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @checkYourBookings.
  ///
  /// In en, this message translates to:
  /// **'Check Your Bookings'**
  String get checkYourBookings;

  /// No description provided for @enterPhoneForBooking.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number you used when making the booking'**
  String get enterPhoneForBooking;

  /// No description provided for @checkBookings.
  ///
  /// In en, this message translates to:
  /// **'Check Bookings'**
  String get checkBookings;

  /// No description provided for @noPendingRides.
  ///
  /// In en, this message translates to:
  /// **'No Pending Rides'**
  String get noPendingRides;

  /// No description provided for @pendingRidesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your pending rides will appear here'**
  String get pendingRidesWillAppearHere;

  /// No description provided for @checkYourActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'Check Your Active Trips'**
  String get checkYourActiveTrips;

  /// No description provided for @checkActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'Check Active Trips'**
  String get checkActiveTrips;

  /// No description provided for @noActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'No Active Trips'**
  String get noActiveTrips;

  /// No description provided for @activeTripsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your ongoing trips will appear here'**
  String get activeTripsWillAppearHere;

  /// No description provided for @checkYourCompletedTrips.
  ///
  /// In en, this message translates to:
  /// **'Check Your Completed Trips'**
  String get checkYourCompletedTrips;

  /// No description provided for @checkCompletedTrips.
  ///
  /// In en, this message translates to:
  /// **'Check Completed Trips'**
  String get checkCompletedTrips;

  /// No description provided for @noCompletedRides.
  ///
  /// In en, this message translates to:
  /// **'No Completed Rides'**
  String get noCompletedRides;

  /// No description provided for @completedRidesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your completed rides will appear here'**
  String get completedRidesWillAppearHere;

  /// No description provided for @noCancelledRides.
  ///
  /// In en, this message translates to:
  /// **'No Cancelled Rides'**
  String get noCancelledRides;

  /// No description provided for @cancelledRidesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your cancelled rides will appear here'**
  String get cancelledRidesWillAppearHere;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @statusWithValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusWithValue(Object status);

  /// No description provided for @totalWithValue.
  ///
  /// In en, this message translates to:
  /// **'Total: {value}'**
  String totalWithValue(Object value);

  /// No description provided for @provideCancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for cancellation:'**
  String get provideCancellationReason;

  /// No description provided for @enterReason.
  ///
  /// In en, this message translates to:
  /// **'Enter reason...'**
  String get enterReason;

  /// No description provided for @pleaseProvideReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason'**
  String get pleaseProvideReason;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @noConfirmedRides.
  ///
  /// In en, this message translates to:
  /// **'No Confirmed Rides'**
  String get noConfirmedRides;

  /// No description provided for @confirmedRidesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your confirmed rides will appear here'**
  String get confirmedRidesWillAppearHere;

  /// No description provided for @unknownClient.
  ///
  /// In en, this message translates to:
  /// **'Unknown Client'**
  String get unknownClient;

  /// No description provided for @calculatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Calculating best route...'**
  String get calculatingRoute;

  /// No description provided for @arrivedAtDestination.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination'**
  String get arrivedAtDestination;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @continueWithoutLogin.
  ///
  /// In en, this message translates to:
  /// **'Continue without login'**
  String get continueWithoutLogin;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @resetTokenSent.
  ///
  /// In en, this message translates to:
  /// **'Reset token sent to your email'**
  String get resetTokenSent;

  /// No description provided for @failedToSendToken.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset token'**
  String get failedToSendToken;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tokenVerified.
  ///
  /// In en, this message translates to:
  /// **'Reset token verified successfully'**
  String get tokenVerified;

  /// No description provided for @invalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid reset token'**
  String get invalidToken;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get passwordResetFailed;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOTP;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a reset token'**
  String get enterEmailForReset;

  /// No description provided for @enterTokenSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the reset token sent to {email}'**
  String enterTokenSentTo(Object email);

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create your new password'**
  String get createNewPassword;

  /// No description provided for @sendResetToken.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Token'**
  String get sendResetToken;

  /// No description provided for @enterResetToken.
  ///
  /// In en, this message translates to:
  /// **'Enter Reset Token'**
  String get enterResetToken;

  /// No description provided for @tokenMinLength.
  ///
  /// In en, this message translates to:
  /// **'Reset token must be at least 4 digits'**
  String get tokenMinLength;

  /// No description provided for @resendResetToken.
  ///
  /// In en, this message translates to:
  /// **'Resend Reset Token'**
  String get resendResetToken;

  /// No description provided for @verifyResetToken.
  ///
  /// In en, this message translates to:
  /// **'Verify Reset Token'**
  String get verifyResetToken;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get enterNewPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccessful;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createNewAccount;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @provideDetailsForAccount.
  ///
  /// In en, this message translates to:
  /// **'Please provide your details to create your account'**
  String get provideDetailsForAccount;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get enterFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get enterLastName;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhoneNumber;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @carRentals.
  ///
  /// In en, this message translates to:
  /// **'Car Rentals'**
  String get carRentals;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @driverProfile.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile'**
  String get driverProfile;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @totalRides.
  ///
  /// In en, this message translates to:
  /// **'Total Rides'**
  String get totalRides;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @securityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityPrivacy;

  /// No description provided for @enableDriverCalls.
  ///
  /// In en, this message translates to:
  /// **'Enable Driver Calls'**
  String get enableDriverCalls;

  /// No description provided for @allowDriversToCall.
  ///
  /// In en, this message translates to:
  /// **'Allow drivers to call you during rides'**
  String get allowDriversToCall;

  /// No description provided for @shareLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Live Location'**
  String get shareLiveLocation;

  /// No description provided for @shareLocationEmergency.
  ///
  /// In en, this message translates to:
  /// **'Share your location with emergency contacts'**
  String get shareLocationEmergency;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @favoriteDestinations.
  ///
  /// In en, this message translates to:
  /// **'Favorite Destinations'**
  String get favoriteDestinations;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get areYouSureLogout;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @driverAvailability.
  ///
  /// In en, this message translates to:
  /// **'Driver Availability'**
  String get driverAvailability;

  /// No description provided for @toggleAvailabilityDescription.
  ///
  /// In en, this message translates to:
  /// **'Toggle your availability for accepting rides (Available/Offline)'**
  String get toggleAvailabilityDescription;

  /// No description provided for @allowPassengersToCall.
  ///
  /// In en, this message translates to:
  /// **'Allow passengers to call you during rides'**
  String get allowPassengersToCall;

  /// No description provided for @shareLocationWithApp.
  ///
  /// In en, this message translates to:
  /// **'Share your location with the app'**
  String get shareLocationWithApp;

  /// No description provided for @companyDetails.
  ///
  /// In en, this message translates to:
  /// **'Company Details'**
  String get companyDetails;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'fr': return SFr();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
