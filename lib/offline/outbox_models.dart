enum OutboxStatus { pending, syncing, done, failed }

class OutboxOperation {
  final int? id;
  final String idemKey;
  final String intent;
  final String method;
  final String path;
  final String payloadJson;
  final String? headersJson;
  final String createdAt;
  final String status;
  final int attempts;
  final String? lastError;

  OutboxOperation({
    this.id,
    required this.idemKey,
    required this.intent,
    required this.method,
    required this.path,
    required this.payloadJson,
    this.headersJson,
    required this.createdAt,
    required this.status,
    this.attempts = 0,
    this.lastError,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'idem_key': idemKey,
    'intent': intent,
    'method': method,
    'path': path,
    'payload_json': payloadJson,
    'headers_json': headersJson,
    'created_at': createdAt,
    'status': status,
    'attempts': attempts,
    'last_error': lastError,
  };

  static OutboxOperation fromMap(Map<String, Object?> m) => OutboxOperation(
    id: m['id'] as int?,
    idemKey: m['idem_key'] as String,
    intent: m['intent'] as String,
    method: m['method'] as String,
    path: m['path'] as String,
    payloadJson: m['payload_json'] as String,
    headersJson: m['headers_json'] as String?,
    createdAt: m['created_at'] as String,
    status: m['status'] as String,
    attempts: m['attempts'] as int,
    lastError: m['last_error'] as String?,
  );
}
