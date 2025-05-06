class ApiConfig {
  static const String baseUrl = 'http://10.16.112.109:5000';
  static const String processEndpoint = '/api/process';
  static const String statusEndpoint = '/api/status';

  static String getProcessUrl() => '$baseUrl$processEndpoint';
  static String getStatusUrl(String jobId) => '$baseUrl$statusEndpoint/$jobId';
}
