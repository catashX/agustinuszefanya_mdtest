class ServerException implements Exception {
  final String message;
  ServerException([this.message = '']);

  @override
  String toString() => message.isEmpty ? 'ServerException' : message;
}

class CacheException implements Exception {}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = '']);

  @override
  String toString() => message.isEmpty ? 'AuthException' : message;
}
