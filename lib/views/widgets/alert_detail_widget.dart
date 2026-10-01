import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../models/alert_model.dart';
import '../../models/management_dtos.dart';
import '../theme.dart';

class AlertDetailWidget extends StatelessWidget {
  final AppController controller;

  const AlertDetailWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final alert = controller.selectedAlert;
    final currentUser = controller.currentUser;

    if (alert == null) {
      return const Center(
        child: Text('Selecione um alerta para ver o detalhe', style: TextStyle(color: AppTheme.textMuted)),
      );
    }

    final isOwner = currentUser?.role == UserRole.donoEstabelecimento;

    if (isOwner) {
      return _buildOwnerView(alert);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ALERTA #${alert.alertUid}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                onPressed: () => controller.selectAlert(null),
              ),
            ],
          ),
          const Divider(color: AppTheme.border),

          // Informação Básica
          _buildSectionTitle('IDENTIFICAÇÃO'),
          if (alert.source == 'denuncia') ...[
            Text('DENÚNCIA: ${alert.category ?? "Geral"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple)),
            const SizedBox(height: 2),
            Text('Denunciante: ${alert.userName}', style: const TextStyle(fontSize: 12)),
            if (alert.details != null && alert.details!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Text('Detalhes: "${alert.details}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
              ),
            ],
          ] else
            Text(
              alert.source == 'botao'
                  ? '${alert.establishmentName}\n${alert.buttonLabel}'
                  : '${alert.userName}\n${alert.userPhone}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          const SizedBox(height: 8),

          // Telefone Clicável ou Ação
          if (alert.userPhone != null)
            SelectableText(
              'Tel: ${alert.userPhone}',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
            ),

          const SizedBox(height: 12),
          _buildSectionTitle('LOCALIZAÇÃO E SINAL'),
          if (alert.locationName != null || alert.lastPosition.address != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Colors.blue, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      alert.locationName ?? alert.lastPosition.address ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Text('Lat: ${alert.lastPosition.lat.toStringAsFixed(5)}, Lon: ${alert.lastPosition.lon.toStringAsFixed(5)}'),
          Text('Precisão: ±${alert.lastPosition.accuracyM.toInt()}m | Bateria: ${alert.lastPosition.battery}%'),

          const SizedBox(height: 12),
          _buildSectionTitle('ENCAMINHAMENTO'),
          Text('Esquadra Resp.: ${alert.routing.responsible?.name ?? "N/A"} (${alert.routing.responsibleDistanceKm ?? 0} km)'),
          Text('Supervisão: ${alert.routing.supervision?.name ?? "Comando"}'),
          Text('Reserva: ${alert.routing.reserve?.name ?? "N/A"}'),

          const SizedBox(height: 12),
          // Ações do Operador / Despachante / Comando
          _buildSectionTitle('AÇÕES DE EMERGÊNCIA'),
          _buildActionButtons(context, alert, currentUser),

          const SizedBox(height: 8),
          // Botões de Contacto de Emergência Externa (Hospital & Bombeiros)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alert.ambulanceRequested ? Colors.green.shade800 : Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.medical_services, size: 14),
                  label: Text(
                    alert.ambulanceRequested ? 'HOSPITAL CONTACTADO' : 'CONTACTAR HOSPITAL',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showContactHospitalDialog(context, alert),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alert.firefightersRequested ? Colors.green.shade800 : Colors.deepOrange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.local_fire_department, size: 14),
                  label: Text(
                    alert.firefightersRequested ? 'BOMBEIROS CONTACTADOS' : 'CONTACTAR BOMBEIROS',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showContactFirefightersDialog(context, alert),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _buildSectionTitle('PATRULHAS DESPACHADAS'),
          if (alert.assignedPatrols.isEmpty)
            const Text('Nenhuma patrulha associada', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))
          else
            ...alert.assignedPatrols.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${p.name}: ${p.status.label}', style: const TextStyle(fontSize: 12)),
                      if (currentUser?.role == UserRole.despachante) _buildPatrolAction(p, alert),
                    ],
                  ),
                )),

          const SizedBox(height: 12),
          _buildSectionTitle('LINHA DO TEMPO'),
          ...alert.timeline.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${item.action} (${item.at.hour.toString().padLeft(2, '0')}:${item.at.minute.toString().padLeft(2, '0')})',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
      ),
    );
  }

  Widget _buildOwnerView(AlertItem alert) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.red.shade900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALERTA NO ${alert.buttonLabel?.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'A POLÍCIA FOI NOTIFICADA. NÃO SE DIRIJA AO LOCAL.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('ESTADO ATUAL'),
          Text(
            alert.status.labelDono,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AlertItem alert, User? user) {
    if (user == null) return const SizedBox.shrink();

    final isAssignedToMe = alert.assignedTo?.id == user.id;

    if (alert.status == AlertStatus.novo) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusNovo),
              onPressed: () => controller.assumeAlert(alert),
              child: const Text('ASSUMIR ALERTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }

    if (user.role == UserRole.despachante && isAssignedToMe) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () => _showDispatchDialog(context, alert),
            child: const Text('DESPACHAR PATRULHA'),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showResolutionReportDialog(context, alert),
                  child: const Text('RESOLVER'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.updateAlertStatus(alert, AlertStatus.falsoAlarme),
                  child: const Text('FALSO ALARME'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (user.role == UserRole.comando) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () => _showReassignDialog(context, alert),
            child: const Text('REATRIBUIR ESQUADRA'),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.updateAlertStatus(alert, AlertStatus.resolvido),
                child: const Text('RESOLVER'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.updateAlertStatus(alert, AlertStatus.falsoAlarme),
                child: const Text('FALSO ALARME'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatrolAction(Patrol patrol, AlertItem alert) {
    if (patrol.status == PatrolStatus.despachada) {
      return TextButton(
        onPressed: () => controller.updatePatrolStatus(patrol, PatrolStatus.aCaminho, alert),
        child: const Text('A Caminho', style: TextStyle(fontSize: 10)),
      );
    } else if (patrol.status == PatrolStatus.aCaminho) {
      return TextButton(
        onPressed: () => controller.updatePatrolStatus(patrol, PatrolStatus.noLocal, alert),
        child: const Text('No Local', style: TextStyle(fontSize: 10)),
      );
    } else if (patrol.status == PatrolStatus.noLocal) {
      return TextButton(
        onPressed: () => controller.updatePatrolStatus(patrol, PatrolStatus.disponivel, alert),
        child: const Text('Libertar', style: TextStyle(fontSize: 10, color: Colors.red)),
      );
    }
    return const SizedBox.shrink();
  }

  void _showDispatchDialog(BuildContext context, AlertItem alert) {
    final availablePatrols = controller.patrols.where((p) => p.status == PatrolStatus.disponivel).toList();
    final List<Patrol> selected = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.panelBg,
            title: const Text('Despachar Patrulhas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 300,
              child: availablePatrols.isEmpty
                  ? const Text('Sem patrulhas disponíveis na esquadra', style: TextStyle(color: AppTheme.textMuted))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: availablePatrols
                          .map((p) => CheckboxListTile(
                                title: Text(p.name, style: const TextStyle(fontSize: 12)),
                                value: selected.contains(p),
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == true) {
                                      selected.add(p);
                                    } else {
                                      selected.remove(p);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
              ElevatedButton(
                onPressed: selected.isEmpty
                    ? null
                    : () {
                        controller.dispatchPatrols(alert, selected);
                        Navigator.pop(ctx);
                      },
                child: const Text('CONFIRMAR DESPACHO'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReassignDialog(BuildContext context, AlertItem alert) {
    final esquadras = controller.organizations.where((o) => o.type == 'esquadra').toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: const Text('Reatribuir Esquadra', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: esquadras
                .map((e) => ListTile(
                      title: Text(e.name, style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        controller.reassignAlert(alert, e);
                        Navigator.pop(ctx);
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showResolutionReportDialog(BuildContext context, AlertItem alert) {
    final reportCtrl = TextEditingController(text: 'Ocorrência atendida pela patrulha. Situação controlada e normalizada.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Relatório de Encerramento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Encerramento da Ocorrência #${alert.alertUid}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 10),
            TextField(
              controller: reportCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Resumo / Observações da Operação',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            onPressed: () {
              final note = reportCtrl.text.trim();
              if (note.isNotEmpty) {
                alert.timeline.add(TimelineItem(
                  action: 'RESOLVIDO: $note',
                  actorName: controller.currentUser?.name,
                  at: DateTime.now(),
                ));
              }
              controller.updateAlertStatus(alert, AlertStatus.resolvido);
              Navigator.pop(ctx);
            },
            child: const Text('ENCERRAR OCORRÊNCIA'),
          ),
        ],
      ),
    );
  }

  void _showContactHospitalDialog(BuildContext context, AlertItem alert) {
    final nearest = controller.getNearestHospital(alert.lastPosition.lat, alert.lastPosition.lon);
    HospitalDTO selectedHospital = nearest;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.local_hospital, color: Colors.red),
                SizedBox(width: 8),
                Text('Hospitais & Centros de Saúde (Beira)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecione uma unidade de saúde para ver o contacto:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(height: 8),

                  // Lista de Hospitais
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.hospitals.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
                      itemBuilder: (context, index) {
                        final h = controller.hospitals[index];
                        final isNearest = h.id == nearest.id;
                        final isSelected = h.id == selectedHospital.id;

                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          selectedTileColor: Colors.red.shade50,
                          onTap: () {
                            setDialogState(() {
                              selectedHospital = h;
                            });
                          },
                          leading: Icon(
                            Icons.local_hospital,
                            color: isNearest ? Colors.red.shade700 : Colors.grey,
                            size: 18,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  h.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (isNearest) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('MAIS PRÓXIMO', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(h.address, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Detalhes da Unidade Selecionada
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selectedHospital.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                        const SizedBox(height: 4),
                        Text('Endereço: ${selectedHospital.address}', style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 6),
                        SelectableText('📞 Telefone Geral: ${selectedHospital.phone}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        SelectableText('🚨 Emergência / Resgate: ${selectedHospital.emergencyPhone}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('FECHAR'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                icon: const Icon(Icons.phone_in_talk, size: 16),
                label: Text('REGISTAR CHAMADA (${selectedHospital.name.split(' ').first})'),
                onPressed: () {
                  controller.contactHospital(alert, selectedHospital);
                  Navigator.pop(ctx);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showContactFirefightersDialog(BuildContext context, AlertItem alert) {
    final fireStation = controller.getNearestFireStation(alert.lastPosition.lat, alert.lastPosition.lon);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.local_fire_department, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Contactar Corpo de Bombeiros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.deepOrange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fireStation.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange)),
                  const SizedBox(height: 4),
                  Text('Endereço: ${fireStation.address}', style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 6),
                  SelectableText('📞 Telefone Directo: ${fireStation.phone}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SelectableText('🚨 Linha Nacional de Emergência: ${fireStation.emergencyPhone}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ao efetuar a chamada, confirme abaixo para registar na linha do tempo do incidente.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('FECHAR'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.phone_in_talk, size: 16),
            label: const Text('REGISTAR CHAMADA'),
            onPressed: () {
              controller.contactFirefighters(alert, fireStation);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
