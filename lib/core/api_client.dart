import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'constants.dart';
import 'storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final StorageService _storage;

  // A global callback to handle forced logout from interceptor
  static void Function()? onForceLogout;

  ApiClient(this._storage) {
    debugPrint('Initializing ApiClient with baseUrl: ${AppConstants.baseUrl}');
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 7),
        receiveTimeout: const Duration(seconds: 7),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    debugPrint('--> ${options.method} ${options.path}');
    if (options.data != null) debugPrint('Body: ${options.data}');
    handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    debugPrint('<-- ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final message = _extractMessage(err.response);
      if (message != 'Please verify your email first') {
        await _storage.clearAll();
        onForceLogout?.call();
      }
    }
    debugPrint('<-- ERROR ${err.type} ${err.message}');
    if (err.response != null) {
      debugPrint('Status: ${err.response?.statusCode}');
      debugPrint('Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }

  String _extractMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map) {
        if (data.containsKey('message')) return data['message'].toString();
        if (data['error'] is Map && data['error'].containsKey('message')) {
          return data['error']['message'].toString();
        }
      }
    } catch (_) {}
    return '';
  }

  String extractError(dynamic err) {
    if (err is DioException) {
      try {
        if (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.sendTimeout) {
          return 'Connection timed out. Please check your internet or if the server is running.';
        }
        final data = err.response?.data;
        if (data is Map) {
          if (data.containsKey('message')) return data['message'].toString();
          if (data['error'] is Map && data['error'].containsKey('message')) {
            return data['error']['message'].toString();
          }
          return 'An error occurred';
        }
      } catch (_) {}
      return err.message ?? 'An error occurred';
    }
    return err.toString();
  }

  // ── HTTP Methods ─────────────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.post(path, data: data, options: options);

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.patch(path, data: data, options: options);

  Future<Response> delete(String path) => _dio.delete(path);

  Future<Response> postForm(String path, FormData formData) => _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

  // ── Response Helpers ─────────────────────────────────────────────────

  /// Unwraps response.data['data']
  static dynamic unwrap(Response response) {
    final body = response.data;
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  /// Extracts pagination meta
  static Map<String, dynamic>? meta(Response response) {
    final body = response.data;
    if (body is Map && body.containsKey('meta')) {
      return body['meta'] as Map<String, dynamic>?;
    }
    return null;
  }
}
