import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermissions() async {
  // Request notification permissions
  final status = await Permission.notification.request();

  if (status.isGranted) {
    log('Notification permissions granted');
  } else {
    log('Notification permissions denied');
  }
}