import 'package:dio/dio.dart';
import '../bloc/auth_event.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl =
      "https://striking-officially-imp.ngrok-free.app/api/auth";
  Future<void> registerUser1(RegisterUser event) async {
    FormData formData = FormData.fromMap({
      'name': event.name,
      'email': event.email,
      'password': event.password,
      'phone': event.phone,
      'address': event.address,
      'latlong': event.latlong,
      'confirm_password': event.confirmPassword,
      if (event.image != null)
        'image': await MultipartFile.fromFile(event.image!),
    });
    print(
        "RGDATA ${event.name} ${event.email} ${event.password} ${event.phone} ${event.address} ${event.latlong} ${event.confirmPassword}  ${event.image}");
    await _dio.post("$baseUrl/register", data: formData);
  }

  Future<void> registerUser(RegisterUser event) async {
    try {
      FormData formData = FormData.fromMap({
        'name': event.name,
        'email': event.email,
        'password': event.password,
        'phone': event.phone,
        'address': event.address,
        'latlong': event.latlong,
        'confirm_password': event.confirmPassword,
        if (event.image != null)
          'image': await MultipartFile.fromFile(event.image!),
      });
      print(
          "RGDATA ${event.name} ${event.email} ${event.password} ${event.phone} ${event.address} ${event.latlong} ${event.confirmPassword}  ${event.image}");
      Response response = await _dio.post("$baseUrl/register", data: formData);

      print("Registration Response: ${response.data}");
    } on DioException catch (e) {
      print("Dio Error: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception("Failed to register: ${e.response?.data}");
    }
  }

  Future<String> loginUser(String email, String password) async {
    Response response = await _dio.post("$baseUrl/login", data: {
      'email': email,
      'password': password,
    });

    return response.data['token'];
  }

  Future<void> logoutUser() async {
    await _dio.post("$baseUrl/logout");
  }
}
