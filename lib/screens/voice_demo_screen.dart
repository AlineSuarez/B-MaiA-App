import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';
import '../config/api_config.dart';
import '../services/api_client.dart';

class VoiceDemoScreen extends StatefulWidget {
  final String baseUrl;
  final Future<String?> Function() getToken;

  const VoiceDemoScreen({
    super.key,
    required this.baseUrl,
    required this.getToken,
  });

  @override
  State<VoiceDemoScreen> createState() => _VoiceDemoScreenState();
}

class _VoiceDemoScreenState extends State<VoiceDemoScreen> {
  final TextEditingController _debugController = TextEditingController();

  @override
  void dispose() {
    _debugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VoiceProvider>(
      create: (_) => VoiceProvider(apiClient: ApiClient()),
      child: Consumer<VoiceProvider>(
        builder: (context, vp, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Demo Voz · Apiarios'),
              actions: [
                IconButton(
                  tooltip: 'Iniciar asistente',
                  icon: const Icon(Icons.mic_none_rounded),
                  onPressed: () async {
                    await vp.startAssistant();
                  },
                ),
                IconButton(
                  tooltip: 'Detener asistente',
                  icon: const Icon(Icons.stop_circle_outlined),
                  onPressed: () async {
                    await vp.stopAssistant();
                  },
                ),
                FutureBuilder<int>(
                  future: vp.pendingCount(),
                  builder: (context, snap) {
                    final count = snap.data ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            'Pend.: $count',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _StatusTile(vp: vp),
                  const SizedBox(height: 12),
                  _ListeningTile(vp: vp),
                  const SizedBox(height: 12),
                  _HeardTile(vp: vp),
                  const SizedBox(height: 12),
                  _FinalTile(vp: vp),
                  const SizedBox(height: 24),

                  const Text(
                    'Prueba rápida (texto → como si fuera voz):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _debugController,
                          decoration: const InputDecoration(
                            hintText:
                                'Ej: crear apiario llamado Las Palmas en región Maule, comuna Talca',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final txt = _debugController.text;
                          if (txt.trim().isEmpty) return;
                          await vp.debugCreateFromText(txt);
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Base URL:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    ApiConfig.baseUrl,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async => vp.startAssistant(),
              icon: const Icon(Icons.mic),
              label: const Text('Crear apiario por voz'),
            ),
          );
        },
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final VoiceProvider vp;
  const _StatusTile({required this.vp});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.info_outline),
      title: const Text('Estado'),
      subtitle: Text(vp.uiStatus.isEmpty ? '—' : vp.uiStatus),
    );
  }
}

class _ListeningTile extends StatelessWidget {
  final VoiceProvider vp;
  const _ListeningTile({required this.vp});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(
        vp.isListening ? Icons.hearing_rounded : Icons.hearing_disabled_rounded,
      ),
      title: const Text('Micrófono'),
      subtitle: Text(vp.isListening ? 'Escuchando…' : 'Inactivo'),
    );
  }
}

class _HeardTile extends StatelessWidget {
  final VoiceProvider vp;
  const _HeardTile({required this.vp});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.subtitles_outlined),
      title: const Text('Parcial'),
      subtitle: Text(vp.lastHeard.isEmpty ? '—' : vp.lastHeard),
    );
  }
}

class _FinalTile extends StatelessWidget {
  final VoiceProvider vp;
  const _FinalTile({required this.vp});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.closed_caption_off_outlined),
      title: const Text('Final'),
      subtitle: Text(
        vp.lastFinalUtterance.isEmpty ? '—' : vp.lastFinalUtterance,
      ),
    );
  }
}
