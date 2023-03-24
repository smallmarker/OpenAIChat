
import 'package:get/get.dart';

class ApiProvider extends GetConnect {

  final String apiKey = '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';
  final String baseUrl = 'https://api.openai.com';
  final Duration timeout = Duration(seconds: 30);

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
  }

  ApiProvider() {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = timeout;
    httpClient.addAuthenticator((request)  {
      request.headers.addAll(_headers());
      return request;
    });
  }

  Future<Response> completions(String body) {
    return post('/v1/chat/completions', body);
  }
}