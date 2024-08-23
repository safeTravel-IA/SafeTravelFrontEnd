import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Response> getRequest(String url) async {
    Response response;
    try {
      response = await _dio.get(url);
    } catch (e) {
      print(e);
      throw Exception('Failed to load data');
    }
    return response;
  }
}