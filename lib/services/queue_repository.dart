import '../models/pending_job.dart';
import 'json_store.dart';

class QueueRepository {
  final _queue = JsonStore('pending_jobs.json');

  Future<List<PendingJob>> load() async {
    final m = await _queue.read();
    return List<Map<String, dynamic>>.from(
      m['items'] ?? [],
    ).map(PendingJob.fromMap).toList();
  }

  Future<void> save(List<PendingJob> jobs) async =>
      _queue.write({'items': jobs.map((e) => e.toMap()).toList()});
  Future<void> add(PendingJob job) async {
    final list = await load();
    list.add(job);
    await save(list);
  }

  Future<void> update(PendingJob job) async {
    final list = await load();
    final i = list.indexWhere((e) => e.id == job.id);
    if (i >= 0) {
      list[i] = job;
      await save(list);
    }
  }
}
