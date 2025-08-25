import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Twende Salama';

  @override
  String get fastReliable => 'Trajets rapides et fiables';

  @override
  String get getToDestination => 'Arrivez à destination à l\'heure, à chaque fois';

  @override
  String get safeSecure => 'Sûr et sécurisé';

  @override
  String get safetyPriority => 'Votre sécurité est notre priorité';

  @override
  String get affordablePrices => 'Prix abordables';

  @override
  String get premiumService => 'Profitez d\'un service premium à des tarifs compétitifs';

  @override
  String get bookingTypes => 'Types de réservation';

  @override
  String get failedToLoad => 'Échec du chargement des types de réservation';

  @override
  String get retry => 'Réessayer';

  @override
  String get loginRequired => 'Connexion requise';

  @override
  String get loginMessage => 'Vous devez créer un compte ou vous connecter pour réserver un trajet.';

  @override
  String get cancel => 'Annuler';

  @override
  String get login => 'Se connecter';

  @override
  String get guestMode => 'Mode invité';

  @override
  String get myLocation => 'Ma position';

  @override
  String get bookYourRide => 'Réserver votre course';

  @override
  String get whereTo => 'Où allez-vous?';

  @override
  String get letsGetYouToDestination => 'Allons à votre destination';

  @override
  String get selectCategory => 'Sélectionner une catégorie';

  @override
  String get pickupLocation => 'Lieu de prise en charge';

  @override
  String get gettingCurrentLocation => 'Obtention de la position actuelle...';

  @override
  String get errorGettingLocation => 'Erreur lors de l\'obtention de la position';

  @override
  String get destination => 'Destination';

  @override
  String get whereAreYouGoing => 'Où allez-vous?';

  @override
  String get calculatingDistanceAndFare => 'Calcul de la distance et du tarif...';

  @override
  String distance(Object distance) {
    return 'Distance: $distance';
  }

  @override
  String get duration => 'Durée';

  @override
  String get startDate => 'Début';

  @override
  String get endDate => 'Fin';

  @override
  String estimatedFare(Object fare) {
    return 'Tarif estimé: $fare USD';
  }

  @override
  String get confirmBooking => 'Confirmer la réservation';

  @override
  String confirmBookingWithFare(Object fare) {
    return 'Confirmer la réservation - $fare USD';
  }

  @override
  String get completeYourBooking => 'Compléter votre réservation';

  @override
  String get provideContactInfo => 'Veuillez fournir vos coordonnées pour finaliser la réservation:';

  @override
  String get yourName => 'Votre nom';

  @override
  String get enterYourFullName => 'Entrez votre nom complet';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneHint => '0788123456';

  @override
  String get privacyInfo => 'Vos informations seront utilisées uniquement pour cette réservation.';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String bookingConfirmed(Object category, Object fare) {
    return 'Réservation confirmée! $category - $fare USD';
  }

  @override
  String get bookingRequestSent => 'Demande de réservation envoyée! Vous serez contacté bientôt.';

  @override
  String bookingFailed(Object message) {
    return 'Échec de la réservation: $message';
  }

  @override
  String errorBooking(Object error) {
    return 'Erreur lors de la création de la réservation: $error';
  }

  @override
  String get searchCategories => 'Rechercher des catégories...';

  @override
  String get selectACategory => 'Sélectionner une catégorie';

  @override
  String get rentCar => 'Louer une voiture';

  @override
  String get rentCarWithDriver => 'Louer une voiture avec chauffeur';

  @override
  String get rentalOptions => 'Sélectionnez vos options de location préférées';

  @override
  String get vehicleCategories => 'Catégories de véhicules';

  @override
  String get rentalDurationType => 'Type de durée de location';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get numberOfUnits => 'Nombre de jours';

  @override
  String get pickupDate => 'Date de prise en charge';

  @override
  String get returnDate => 'Date de retour';

  @override
  String durationType(Object type) {
    return 'Type de durée: $type';
  }

  @override
  String totalDuration(Object duration, Object unit) {
    return 'Durée totale: $duration $unit';
  }

  @override
  String ratePerDuration(Object price, Object unit) {
    return 'Taux: $price USD par $unit';
  }

  @override
  String totalPrice(Object price) {
    return 'Total: $price USD';
  }

  @override
  String get priceIncludesDriver => 'Le prix comprend le chauffeur';

  @override
  String get confirmRental => 'Confirmer la location';

  @override
  String confirmRentalWithPrice(Object price) {
    return 'Confirmer la location - $price RWUSDF';
  }

  @override
  String get completeYourRental => 'Compléter votre location';

  @override
  String get provideRentalContactInfo => 'Veuillez fournir vos coordonnées pour finaliser la location:';

  @override
  String get selectVehicle => 'Sélectionner un véhicule';

  @override
  String get days => 'jours';

  @override
  String get weeks => 'semaines';

  @override
  String get months => 'mois';

  @override
  String get loadingRentalOptions => 'Chargement des options de location...';

  @override
  String get ride => 'Course';

  @override
  String get details => 'Détails';

  @override
  String get driver => 'Chauffeur';

  @override
  String get vehicle => 'Véhicule';

  @override
  String get from => 'De';

  @override
  String get to => 'À';

  @override
  String get date => 'Date';

  @override
  String get time => 'Heure';

  @override
  String get fare => 'Tarif';

  @override
  String get track => 'Suivre';

  @override
  String get cancelRide => 'Annuler la course';

  @override
  String get callDriver => 'Appeler le chauffeur';

  @override
  String get rideCancelled => 'Course annulée';

  @override
  String get phoneNumberNotAvailable => 'Numéro de téléphone non disponible';

  @override
  String get completed => 'Terminé';

  @override
  String get pending => 'En attente';

  @override
  String get cancelled => 'Annulé';

  @override
  String get unknown => 'inconnu';

  @override
  String get rideHistory => 'Historique des courses';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get onTrip => 'En course';

  @override
  String get startTrip => 'Démarrer le voyage';

  @override
  String get enterOtpMessage => 'Veuillez demander le code OTP au client pour démarrer le voyage.';

  @override
  String get enterOTP => 'Entrez OTP';

  @override
  String get sixDigitCode => 'Code à 6 chiffres';

  @override
  String get navigation => 'Navigation';

  @override
  String get locationCoordsNotAvailable => 'Les coordonnées de localisation ne sont pas disponibles pour la navigation';

  @override
  String get pause => 'Pause';

  @override
  String get startNavigation => 'Démarrer la navigation';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get unknownPickup => 'Lieu de prise en charge inconnu';

  @override
  String get unknownDestination => 'Destination inconnue';

  @override
  String get navigate => 'Naviguer';

  @override
  String get start => 'Démarrer';

  @override
  String get inProgress => 'En cours';

  @override
  String get complete => 'Terminer';

  @override
  String tripWithId(Object id) {
    return 'Voyage $id';
  }

  @override
  String get navigateToPickup => 'Naviguer vers le point de ramassage';

  @override
  String startedAt(Object time) {
    return 'Démarré: $time';
  }

  @override
  String completedAt(Object time) {
    return 'Terminé: $time';
  }

  @override
  String get bookingCode => 'Réservation';

  @override
  String get initialPayment => 'Paiement initial';

  @override
  String get totalEstimated => 'Total estimé';

  @override
  String get cancelBooking => 'Annuler la réservation';

  @override
  String get checkYourCarRentals => 'Vérifiez vos locations de voitures';

  @override
  String get enterPhoneForRentals => 'Entrez le numéro de téléphone que vous avez utilisé lors de la location';

  @override
  String get checkYourConfirmedRentals => 'Vérifiez vos locations confirmées';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get checkYourBookings => 'Vérifiez vos réservations';

  @override
  String get enterPhoneForBooking => 'Entrez le numéro de téléphone que vous avez utilisé lors de la réservation';

  @override
  String get checkBookings => 'Vérifier les réservations';

  @override
  String get noPendingRides => 'Aucun trajet en attente';

  @override
  String get pendingRidesWillAppearHere => 'Vos trajets en attente apparaîtront ici';

  @override
  String get checkYourActiveTrips => 'Vérifiez vos trajets actifs';

  @override
  String get checkActiveTrips => 'Vérifier les trajets actifs';

  @override
  String get noActiveTrips => 'Aucun trajet actif';

  @override
  String get activeTripsWillAppearHere => 'Vos trajets en cours apparaîtront ici';

  @override
  String get checkYourCompletedTrips => 'Vérifiez vos trajets terminés';

  @override
  String get checkCompletedTrips => 'Vérifier les trajets terminés';

  @override
  String get noCompletedRides => 'Aucun trajet terminé';

  @override
  String get completedRidesWillAppearHere => 'Vos trajets terminés apparaîtront ici';

  @override
  String get noCancelledRides => 'Aucun trajet annulé';

  @override
  String get cancelledRidesWillAppearHere => 'Vos trajets annulés apparaîtront ici';

  @override
  String get confirm => 'Confirmer';

  @override
  String statusWithValue(Object status) {
    return 'Statut: $status';
  }

  @override
  String totalWithValue(Object value) {
    return 'Total: $value';
  }

  @override
  String get provideCancellationReason => 'Veuillez indiquer un motif d\'annulation:';

  @override
  String get enterReason => 'Entrer la raison...';

  @override
  String get pleaseProvideReason => 'Veuillez fournir une raison';

  @override
  String get submit => 'Soumettre';

  @override
  String get noConfirmedRides => 'Aucun trajet confirmé';

  @override
  String get confirmedRidesWillAppearHere => 'Vos trajets confirmés apparaîtront ici';

  @override
  String get unknownClient => 'Client inconnu';

  @override
  String get calculatingRoute => 'Calcul du meilleur itinéraire...';

  @override
  String get arrivedAtDestination => 'Vous êtes arrivé à votre destination';

  @override
  String get signIn => 'Se connecter';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get enterEmail => 'Veuillez entrer votre email';

  @override
  String get enterValidEmail => 'Veuillez entrer un email valide';

  @override
  String get enterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get password => 'Mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get continueWithoutLogin => 'Continuer sans connexion';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte?';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get resetTokenSent => 'Jeton de réinitialisation envoyé à votre email';

  @override
  String get failedToSendToken => 'Échec de l\'envoi du jeton de réinitialisation';

  @override
  String get error => 'Erreur';

  @override
  String get tokenVerified => 'Jeton de réinitialisation vérifié avec succès';

  @override
  String get invalidToken => 'Jeton de réinitialisation invalide';

  @override
  String get passwordResetSuccess => 'Mot de passe réinitialisé avec succès';

  @override
  String get passwordResetFailed => 'Échec de la réinitialisation du mot de passe';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get verifyOTP => 'Vérifier OTP';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get enterEmailForReset => 'Entrez votre adresse e-mail pour recevoir un jeton de réinitialisation';

  @override
  String enterTokenSentTo(Object email) {
    return 'Entrez le jeton de réinitialisation envoyé à $email';
  }

  @override
  String get createNewPassword => 'Créez votre nouveau mot de passe';

  @override
  String get sendResetToken => 'Envoyer le jeton de réinitialisation';

  @override
  String get enterResetToken => 'Entrez le jeton de réinitialisation';

  @override
  String get tokenMinLength => 'Le jeton de réinitialisation doit comporter au moins 4 chiffres';

  @override
  String get resendResetToken => 'Renvoyer le jeton de réinitialisation';

  @override
  String get verifyResetToken => 'Vérifier le jeton de réinitialisation';

  @override
  String get enterNewPassword => 'Veuillez entrer un nouveau mot de passe';

  @override
  String get passwordMinLength => 'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get confirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get registrationSuccessful => 'Inscription réussie';

  @override
  String get createNewAccount => 'Créer un nouveau compte';

  @override
  String get completeYourProfile => 'Complétez votre profil';

  @override
  String get provideDetailsForAccount => 'Veuillez fournir vos données pour créer votre compte';

  @override
  String get firstName => 'Prénom';

  @override
  String get enterFirstName => 'Veuillez entrer votre prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get enterLastName => 'Veuillez entrer votre nom de famille';

  @override
  String get enterPhoneNumber => 'Veuillez entrer votre numéro de téléphone';

  @override
  String get enterValidPhoneNumber => 'Veuillez entrer un numéro de téléphone valide';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte?';

  @override
  String get home => 'Accueil';

  @override
  String get profile => 'Profil';

  @override
  String get carRentals => 'Location de voitures';

  @override
  String get rent => 'Location';

  @override
  String get driverProfile => 'Profil du chauffeur';

  @override
  String get yourProfile => 'Votre profil';

  @override
  String get totalRides => 'Total des trajets';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get rating => 'Évaluation';

  @override
  String get securityPrivacy => 'Sécurité et confidentialité';

  @override
  String get enableDriverCalls => 'Activer les appels du chauffeur';

  @override
  String get allowDriversToCall => 'Permettre aux chauffeurs de vous appeler pendant les trajets';

  @override
  String get shareLiveLocation => 'Partager la position en temps réel';

  @override
  String get shareLocationEmergency => 'Partager votre position avec les contacts d\'urgence';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get paymentMethods => 'Méthodes de paiement';

  @override
  String get favoriteDestinations => 'Destinations favorites';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Langue';

  @override
  String get helpSupport => 'Aide et support';

  @override
  String get logout => 'Déconnexion';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get areYouSureLogout => 'Êtes-vous sûr de vouloir vous déconnecter de votre compte?';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get wallet => 'Portefeuille';

  @override
  String get available => 'Disponible';

  @override
  String get offline => 'Hors ligne';

  @override
  String get driverAvailability => 'Disponibilité du chauffeur';

  @override
  String get toggleAvailabilityDescription => 'Basculer votre disponibilité pour accepter les trajets (Disponible/Hors ligne)';

  @override
  String get allowPassengersToCall => 'Permettre aux passagers de vous appeler pendant les trajets';

  @override
  String get shareLocationWithApp => 'Partager votre position avec l\'application';

  @override
  String get companyDetails => 'Détails de l\'entreprise';
}
