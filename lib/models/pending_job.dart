import 'job_status.dart';

class PendingJob {
  final String id, endpoint, method;
  final Map<String, String> headers;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int retries;
  JobStatus status;
  String? lastError;

  PendingJob({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.headers,
    required this.payload,
    required this.createdAt,
    this.retries = 0,
    this.status = JobStatus.queued,
    this.lastError,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'endpoint': endpoint,
    'method': method,
    'headers': headers,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'retries': retries,
    'status': status.name,
    'lastError': lastError,
  };

  factory PendingJob.fromMap(Map<String, dynamic> m) => PendingJob(
    id: m['id'],
    endpoint: m['endpoint'],
    method: m['method'],
    headers: Map<String, String>.from(m['headers'] ?? {}),
    payload: Map<String, dynamic>.from(m['payload'] ?? {}),
    createdAt: DateTime.parse(m['createdAt']),
    retries: m['retries'] ?? 0,
    status: JobStatus.values.firstWhere(
      (e) => e.name == (m['status'] ?? 'queued'),
      orElse: () => JobStatus.queued,
    ),
    lastError: m['lastError'],
  );

  factory PendingJob.create({
    required String method,
    required String endpoint,
    required Map<String, dynamic> payload,
    Map<String, String>? headers,
    String? id,
    DateTime? createdAt,
  }) {
    return PendingJob(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      endpoint: endpoint,
      method: method.toUpperCase(),
      headers: headers ?? <String, String>{},
      payload: payload,
      createdAt: createdAt ?? DateTime.now(),
      retries: 0,
      status: JobStatus.queued,
      lastError: null,
    );
  }
}
