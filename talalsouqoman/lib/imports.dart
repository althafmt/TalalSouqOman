// lib/core/app_exports.dart
library dart_exports;

// Dart core libraries
export 'dart:async' hide AsyncError, StreamView;
export 'dart:convert';
export 'dart:developer' show log;
export 'dart:io' if (dart.library.html) 'dart:html';

// Project imports
export './imports.dart';

// Flutter core
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter/foundation.dart';


// Third-party packages
export 'package:provider/provider.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:supabase_flutter/supabase_flutter.dart';
export 'package:http/http.dart';
export 'package:http/io_client.dart';
export 'package:fluttertoast/fluttertoast.dart';
export 'package:geolocator/geolocator.dart';
export 'package:image_picker/image_picker.dart';
export 'package:camera/camera.dart';
export 'package:path_provider/path_provider.dart';

// Authentication
export 'package:talalsouqoman/Authentication/auth_service.dart';
export 'package:talalsouqoman/Authentication/login_screen.dart';
export 'package:talalsouqoman/Authentication/signup_screen.dart';

// Screens
export 'package:talalsouqoman/home_screen.dart';
export 'package:talalsouqoman/main.dart';
export 'package:talalsouqoman/Assets/assets_screen.dart';
export 'package:talalsouqoman/Assets/halban_store_screen.dart';
export 'package:talalsouqoman/Assets/seeb_office_screen.dart';
export 'package:talalsouqoman/Assets/seeb_shop_screen.dart';
export 'package:talalsouqoman/Assets/seeb_store_screen.dart';

// Employee Details - Fixed conflict here
export 'package:talalsouqoman/EmployeeDetails/AllEmployeesScreen.dart' hide EmployeeCard;
export 'package:talalsouqoman/EmployeeDetails/TemporaryEmployeeScreen.dart';
export 'package:talalsouqoman/EmployeeDetails/VisaEmployeeScreen.dart';
export 'package:talalsouqoman/EmployeeDetails/EmployeeDetailsScreen.dart';

// Drawer Screens
export 'package:talalsouqoman/drawer/NotificationScreen.dart';
export 'package:talalsouqoman/drawer/SettingsScreen.dart';
export 'package:talalsouqoman/drawer/about_app.dart';
export 'package:talalsouqoman/drawer/profile_screen.dart';

// Widgets
export 'package:talalsouqoman/widgets/button.dart';
export 'package:talalsouqoman/widgets/button2.dart';
export 'package:talalsouqoman/widgets/textfield.dart';
export 'package:talalsouqoman/widgets/custom_app_bar.dart';
export 'package:talalsouqoman/widgets/custom_bottom_navigation_bar.dart';
export 'package:talalsouqoman/widgets/design2.dart';
export 'package:talalsouqoman/widgets/constants.dart';

//Driver

export 'package:talalsouqoman/driver/driver_screen.dart';
export 'package:talalsouqoman/driver/PaymentListPage.dart';
export 'package:talalsouqoman/driver/WageCalculatorPage.dart';

//Delivery
export 'package:talalsouqoman/DeliveryScreen/DeliveriesPage.dart';

//Vehicles
export 'package:talalsouqoman/Vehicles/VehiclesDetails.dart';



export 'package:camera/camera.dart';
export 'package:flutter/material.dart';
export 'package:image_picker/image_picker.dart';
export 'dart:typed_data'; // For ByteData
export 'package:fluttertoast/fluttertoast.dart';
export 'dart:convert'; // For base64 encoding
export 'dart:io'; // Add this import
export 'dart:typed_data'; // Ensure you have this import