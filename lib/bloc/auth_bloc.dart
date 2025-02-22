import 'package:assignmentsubhasish/db/database_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc({required this.apiService}) : super(AuthInitial()) {
    on<RegisterUser>(_onRegister);
    on<LoginUser>(_onLogin);
    on<LogoutUser>(_onLogout);
  }

  Future<void> _onRegister1(RegisterUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await apiService.registerUser(event);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegister(RegisterUser event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    if (await _hasInternet()) {
      await apiService.registerUser(event);
    } else {
      await DatabaseHelper.instance.insertUser({
        'name': event.name,
        'email': event.email,
        'password': event.password,
        'phone': event.phone,
        'address': event.address,
        'latlong': event.latlong,
        'confirm_password': event.confirmPassword,
        'image': event.image,
        'synced': 0
      });
      emit(AuthSuccess()); // Show success even if offline
    }
  } catch (e) {
    emit(AuthFailure(e.toString()));
  }
}


Future<void> _onRegister2(RegisterUser event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    if (await _hasInternet()) {
      await apiService.registerUser(event);
      emit(AuthSuccess());
    } else {
      await _storeOfflineUser(event); // Store locally if offline
      emit(AuthFailure("No internet. User data saved locally and will sync later."));
    }
  } catch (e) {
    if (e is DioException && e.type == DioExceptionType.badResponse) {
      emit(AuthFailure("Failed to register: Server is offline."));
    } else {
      await _storeOfflineUser(event);
      emit(AuthFailure("No internet. User data saved locally and will sync later."));
    }
  }
}

Future<void> _storeOfflineUser(RegisterUser event) async {
  await DatabaseHelper.instance.insertUser({
    'name': event.name,
    'email': event.email,
    'password': event.password,
    'phone': event.phone,
    'address': event.address,
    'latlong': event.latlong,
    'confirm_password': event.confirmPassword,
    'image': event.image,
    'synced': 0
  });
}

Future<bool> _hasInternet() async {
  try {
    final result = await Dio().get('https://google.com');
    return result.statusCode == 200;
  } catch (_) {
    return false;
  }
}


  Future<void> _onLogin(LoginUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      String token = await apiService.loginUser(event.email, event.password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await apiService.logoutUser();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
