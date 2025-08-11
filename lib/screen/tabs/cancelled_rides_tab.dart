import 'package:flutter/material.dart';
import 'package:twende/l10n/l10n.dart';
import 'ride_data.dart';
import '../widgets/ride_card.dart';
import '../widgets/empty_state.dart';

class CancelledRidesTab extends StatelessWidget {
  const CancelledRidesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!; // Get localization
    final cancelledRides = RideData.getRidesByStatus('cancelled');

    if (cancelledRides.isEmpty) {
      return EmptyState(
        icon: Icons.cancel_outlined,
        title: s.noCancelledRides,
        subtitle: s.cancelledRidesWillAppearHere,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cancelledRides.length,
      itemBuilder: (context, index) {
        final ride = cancelledRides[index];
        return RideCard(ride: ride);
      },
    );
  }
}
