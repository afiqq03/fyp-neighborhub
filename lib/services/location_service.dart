import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  bool _initialized = false;
  
  LocationService() {
    // Don't initialize anything on construction
  }
  
  // Only initialize location when actually needed
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Check current permission status
      final permission = await Geolocator.checkPermission();
      
      // Request permissions if not granted
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing location: $e');
      // Don't set _initialized to true if there was an error
    }
  }
  
  // Get current position only when needed
  Future<Position?> getCurrentPosition() async {
    try {
      // Ensure initialized
      await initialize();
      
      // Get position
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting position: $e');
      return null;
    }
  }
  
  // Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission != LocationPermission.denied && 
           permission != LocationPermission.deniedForever;
  }
}