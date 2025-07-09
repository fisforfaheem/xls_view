import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'core/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize permission service (but don't request permissions yet)
  // Permissions will be requested when needed
  final permissionService = PermissionService();

  runApp(const XlsViewApp());
}
