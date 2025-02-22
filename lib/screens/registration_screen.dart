import 'dart:async';
import 'dart:io';
import 'package:assignmentsubhasish/model/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latlongController = TextEditingController();

  File? _image; // Image File
  final ImagePicker _picker = ImagePicker(); // Image Picker
  late Position _currentPosition;
  double _distanceInMeters = 0.0;
  String latitude = 'Unknown';
  String longitude = 'Unknown';
  String? _latlong;
  PlaceLocation? _pickedLocation;
  late Timer _timer;
  // Function to Pick Image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Validate Email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
        .hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Validate Password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Validate Confirm Password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm password is required';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  // Validate Required Fields
  String? _validateRequired(String? value) {
    return (value == null || value.isEmpty) ? 'This field is required' : null;
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _getLocation();
    });
  }

  void _cancelTimer() {
    _timer.cancel();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever');
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = _currentPosition.latitude.toString();
      longitude = _currentPosition.longitude.toString();
      _latlong = 'Lat: $latitude, Long: $longitude';

      // Convert LatLong to Address
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

        setState(() {
          _pickedLocation = PlaceLocation(
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude,
          );
          latlongController.text = _latlong!;
          addressController.text = address; // ✅ Auto-fill address
        });

        print("Location: $_latlong, Address: $address");
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    latlongController.text = _latlong!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image Picker
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
                SizedBox(height: 12),

                // Name Field
                TextFormField(
                  controller: nameController,
                  validator: _validateRequired,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12),

                // Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12),

                // Confirm Password Field
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  validator: _validateConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12),

                // Phone Field
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validateRequired,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12),

                // Address Field
                TextFormField(
                  controller: addressController,
                  validator: _validateRequired,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12),

                // Lat/Long Field
                TextFormField(
                  controller: latlongController,
                  validator: _validateRequired,
                  decoration: InputDecoration(
                    labelText: 'Lat/Long',
                    prefixIcon: Icon(Icons.map),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 20),

                // Register Button
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFailure) {
                      String errorMessage =
                          state.error.contains("Server is offline")
                              ? "Registration failed. Please try again later."
                              : state.error;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(errorMessage)));
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error)),
                      );
                      print("RgError ${state.error}");
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<AuthBloc>(context)
                                      .add(RegisterUser(
                                    name: nameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                    confirmPassword:
                                        confirmPasswordController.text,
                                    phone: phoneController.text,
                                    address: addressController.text,
                                    latlong: latlongController.text,
                                    image: _image
                                        ?.path, // ✅ Convert File to String (file path)
                                  ));
                                }
                              },
                        child: state is AuthLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Register",
                                style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
