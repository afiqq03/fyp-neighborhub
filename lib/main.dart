import 'package:flutter/material.dart';
import 'package:rukuntetangga/pages/user/home.dart';
import 'package:rukuntetangga/pages/user/information.dart';
import 'package:rukuntetangga/pages/user/settings.dart';
import 'package:rukuntetangga/pages/user/maps.dart';
import 'package:rukuntetangga/pages/user/timetable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rukuntetangga/widgets/constants.dart';
import 'package:rukuntetangga/services/location_service.dart';
import 'package:rukuntetangga/services/user_service.dart';
import 'package:rukuntetangga/pages/login.dart';

// Create a global service locator
final serviceLocator = _ServiceLocator();

// Main app entry point with optimized initialization
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Core only (not all Firebase services)
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeighborHub',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

// This wrapper checks authentication status and renders the appropriate screen
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Check if user is logged in
      final user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        setState(() {
          _isAuthenticated = user != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
      debugPrint('Error checking auth status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate to the appropriate screen based on authentication status
    if (_isAuthenticated) {
      return const MainNavigation();
    } else {
      return const LoginScreen();
    }
  }
}

// Service locator for lazy initialization
class _ServiceLocator {
  // Lazy initialized services
  UserService? _userService;
  LocationService? _locationService;

  // Getters that initialize services only when first accessed
  UserService get userService => _userService ??= UserService();

  LocationService get locationService => _locationService ??= LocationService();
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Only fetch notifications, without UI details
  }

  // Fetch notification count using the service
  void _onNavigate(int index) {
    // Don't rebuild if selecting the same index
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Handle notifications without UI implementatio

@override
Widget build(BuildContext context) {
  // Create screens dynamically to ensure onNavigate callback works properly
  final List<Widget> screens = [
    HomeScreen(
      onNavigate: _onNavigate, 
    ),
    InformationScreen(

    ),
    const MapScreen(),
    TimetablePage(
      username: '', // Add your username property here
    ),
    SettingsScreen(
    ),
  ];

    // Simplified scaffold with just navigation functionality
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: _onNavigate,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline),label: 'Information',),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings),label: 'Settings',
          ),
        ],
      ),
    );
  }
}