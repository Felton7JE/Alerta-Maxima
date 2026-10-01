import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../models/alert_model.dart';
import '../theme.dart';

class AlertListWidget extends StatelessWidget {
  final AppController controller;

  const AlertListWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final alerts = controller.alerts;
    final selectedAlert = controller.selectedAlert;

    // Ordenar: Alertas NOVO no topo
    final sortedAlerts = List<AlertItem>.from(alerts)
      ..sort((a, b) {
        if (a.status == AlertStatus.novo && b.status != AlertStatus.novo) return -1;
        if (a.status != AlertStatus.novo && b.status == AlertStatus.novo) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    return Column(
      children: [
        // Topo da Lista
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ALERTAS ATIVOS (${sortedAlerts.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      onPressed: () {
                        controller.triggerDemoButtonAlert();
                      },
                      child: const Text('+ BOTÃO LOJA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      onPressed: () {
                        controller.triggerDemoCitizenAlert();
                      },
                      child: const Text('+ SOS CIDADÃO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de Cartões
        Expanded(
          child: sortedAlerts.isEmpty
              ? const Center(child: Text('Sem alertas ativos', style: TextStyle(color: AppTheme.textMuted)))
              : ListView.separated(
                  itemCount: sortedAlerts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
                  itemBuilder: (context, index) {
                    final alert = sortedAlerts[index];
                    final isSelected = alert.alertUid == selectedAlert?.alertUid;

                    Color statusColor;
                    switch (alert.status) {
                      case AlertStatus.novo:
                        statusColor = AppTheme.statusNovo;
                        break;
                      case AlertStatus.assumido:
                        statusColor = AppTheme.statusAssumido;
                        break;
                      case AlertStatus.equipaACaminho:
                        statusColor = AppTheme.statusEquipaACaminho;
                        break;
                      case AlertStatus.equipaNoLocal:
                        statusColor = AppTheme.statusEquipaNoLocal;
                        break;
                      default:
                        statusColor = AppTheme.statusResolvido;
                    }

                    final timeDiff = DateTime.now().difference(alert.createdAt);
                    final minutesAgo = timeDiff.inMinutes.toString().padLeft(2, '0');
                    final secondsAgo = (timeDiff.inSeconds % 60).toString().padLeft(2, '0');

                    String titleText;
                    if (alert.source == 'botao') {
                      titleText = '${alert.establishmentName} (${alert.buttonLabel})';
                    } else if (alert.source == 'denuncia') {
                      titleText = 'DENÚNCIA: ${alert.category ?? "Ocorrência"}';
                    } else {
                      titleText = '${alert.userName} (${alert.userPhone})';
                    }

                    return Container(
                      color: isSelected
                          ? Colors.blue.withValues(alpha: 0.15)
                          : (alert.escalated ? Colors.red.withValues(alpha: 0.1) : Colors.transparent),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        onTap: () => controller.selectAlert(alert),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                alert.status.label,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (alert.source == 'denuncia') ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                color: Colors.purple,
                                child: const Text('DENÚNCIA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            if (alert.escalated) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                color: Colors.red,
                                child: const Text('SEM RESPOSTA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            const Spacer(),
                            Text('há $minutesAgo:$secondsAgo', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titleText,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert.routing.responsible?.name ?? 'Sem Esquadra',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text('Bat: ${alert.lastPosition.battery}%', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                ],
                              ),
                              if (alert.locationName != null || alert.lastPosition.address != null) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 12, color: Colors.redAccent),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        alert.locationName ?? alert.lastPosition.address ?? '',
                                        style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (alert.assignedTo != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text('Assumido por: ${alert.assignedTo!.name}', style: const TextStyle(fontSize: 10, color: Colors.orangeAccent)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
