import 'dart:async';

import '../models/job_status.dart';
import 'queue_repository.dart';
import 'voice_api_gateway.dart';

/// Drena la cola de PendingJob usando el gateway HTTP
class SyncWorker {
  final QueueRepository queueRepo;
  final VoiceApiGateway api;

  SyncWorker({required this.queueRepo, required this.api});

  /// Intenta enviar todo una vez (sin loop ni timers)
  Future<void> drainOnce() async {
    final list = await queueRepo.load();

    for (final job in list) {
      // Si ya está hecho, salta
      if (job.status == JobStatus.done) {
        continue;
      }

      try {
        // Enviar
        await api.enviarJob(job);

        // Mutar y persistir como DONE
        job.status = JobStatus.done;
        job.lastError = null;
        await queueRepo.update(job);
      } catch (e) {
        // Mutar y persistir como ERROR
        job.status = JobStatus.error;
        job.lastError = e.toString();
        await queueRepo.update(job);
        // Continúa para no bloquear el resto
      }
    }
  }
}
