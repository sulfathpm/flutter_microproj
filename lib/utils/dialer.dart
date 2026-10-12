import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone dialer. Wrapped in try/catch (exception handling).
Future<void> callNumber(BuildContext context, String number) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final ok = await launchUrl(Uri(scheme: 'tel', path: number));
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open dialer for $number')));
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Calling is not supported on this device ($number)')));
  }
}
