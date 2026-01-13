import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'user_session.dart';

/// Central API service for all backend communication
/// Handles base URL configuration, headers, and request/response management
class ApiService {
  // Production backend URL
  static const String _productionBaseUrl = 'https://newset.onrender.com';

  // Development URLs
  static const String _webLocalUrl = 'http://localhost:3000';
  static const String _androidLocalUrl = 'http://10.0.2.2:3000';
  static const String _iosLocalUrl = 'http://localhost:3000';

  static bool _useProduction = true;
  static String? _overrideBaseUrl;

  static String get baseUrl {
    // Use override if set
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }

    // Use production URL by default
    if (_useProduction) {
      return _productionBaseUrl;
    }

    // Development URLs based on platform
    if (kIsWeb) {
      return _webLocalUrl;
    }

    try {
      if (Platform.isAndroid) return _androidLocalUrl;
      if (Platform.isIOS) return _iosLocalUrl;
    } catch (_) {
      // Fallback when Platform isn't available
    }

    return _productionBaseUrl; // Default fallback
  }

  /// Toggle between production and development modes
  static void setProductionMode(bool useProduction) {
    _useProduction = useProduction;
  }

  /// Set custom base URL
  static void setBaseUrl(String newBaseUrl) {
    _overrideBaseUrl = newBaseUrl;
  }

  /// Get headers with authorization token
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
    String? customToken,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth || customToken != null) {
      final token = customToken ?? await UserSession.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Generic GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requireAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);

      // Build URL with query parameters
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 120),
            onTimeout: () => throw TimeoutException(
              'Request timeout - Server took too long to respond',
            ),
          );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('GET request failed: $e');
    }
  }

  /// Generic POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = true,
    String? customToken,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth, customToken: customToken);
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 120),
            onTimeout: () => throw TimeoutException(
              'Request timeout - Server took too long to respond',
            ),
          );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('POST request failed: $e');
    }
  }

  /// Generic PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 120),
            onTimeout: () => throw TimeoutException(
              'Request timeout - Server took too long to respond',
            ),
          );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('PUT request failed: $e');
    }
  }

  /// Generic DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(
            const Duration(seconds: 120),
            onTimeout: () => throw TimeoutException(
              'Request timeout - Server took too long to respond',
            ),
          );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('DELETE request failed: $e');
    }
  }

  /// Upload file with multipart request
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      // Remove Content-Type for multipart request
      headers.remove('Content-Type');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(headers);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Add additional fields
      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          request.fields[key] = value;
        });
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      return _handleResponse(http.Response(responseBody, response.statusCode));
    } catch (e) {
      throw ApiException('File upload failed: $e');
    }
  }

  /// Handle API response and standardize error handling
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body) as Map<String, dynamic>;

      switch (response.statusCode) {
        case 200:
        case 201:
        case 202:
          return decodedBody;

        case 400:
          throw BadRequestException(decodedBody['error'] ?? 'Bad request');

        case 401:
          // Token expired or invalid - clear session
          UserSession.reset();
          throw UnauthorizedException(decodedBody['error'] ?? 'Unauthorized');

        case 403:
          throw ForbiddenException(decodedBody['error'] ?? 'Forbidden');

        case 404:
          throw NotFoundException(decodedBody['error'] ?? 'Not found');

        case 409:
          throw ConflictException(decodedBody['error'] ?? 'Conflict');

        case 422:
          throw ValidationException(
            decodedBody['error'] ?? 'Validation failed',
          );

        case 429:
          throw RateLimitException(decodedBody['error'] ?? 'Too many requests');

        case 500:
        case 502:
        case 503:
          throw ServerException(decodedBody['error'] ?? 'Server error');

        default:
          throw ApiException('Unexpected status code: ${response.statusCode}');
      }
    } on FormatException {
      // Handle non-JSON responses
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Request successful'};
      } else {
        throw ApiException('Server returned non-JSON response');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to parse response: $e');
    }
  }

  /// Health check endpoint
  static Future<bool> healthCheck() async {
    try {
      final response = await get('/health', requireAuth: false);
      return response['status'] == 'ok' || response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Test backend connectivity
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🌐 Testing connection to: $baseUrl');
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 10));

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'url': baseUrl,
        'message': response.statusCode == 200
            ? '✅ Connected successfully!'
            : '⚠️ Connection failed with status ${response.statusCode}',
      };
    } on TimeoutException {
      return {
        'success': false,
        'statusCode': 0,
        'url': baseUrl,
        'message': '❌ Connection timeout. Server might be sleeping.',
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'url': baseUrl,
        'message': '❌ Connection error: $e',
      };
    }
  }
}

// Custom exception classes
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super('Bad Request: $message');
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super('Unauthorized: $message');
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super('Forbidden: $message');
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super('Not Found: $message');
}

class ConflictException extends ApiException {
  ConflictException(String message) : super('Conflict: $message');
}

class ValidationException extends ApiException {
  ValidationException(String message) : super('Validation Error: $message');
}

class RateLimitException extends ApiException {
  RateLimitException(String message) : super('Rate Limit: $message');
}

class ServerException extends ApiException {
  ServerException(String message) : super('Server Error: $message');
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super('Timeout: $message');
}
