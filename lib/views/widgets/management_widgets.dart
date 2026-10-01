import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../models/alert_model.dart';
import '../../models/management_dtos.dart';
import '../theme.dart';
import 'map_widget.dart';

// --- VIEW DA DASHBOARD ESTRATÉGICA ---
class StrategicDashboardView extends StatelessWidget {
  final AppController controller;

  const StrategicDashboardView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final metrics = controller.getDashboardMetrics();

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Estratégico & Indicadores de Operação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Visão geral do volume de ocorrências, tempos de resposta e disponibilidade operacional.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            // CARDS DE KPI / MÉTRICAS CHAVE
            Row(
              children: [
                Expanded(child: _buildMetricCard('Total Ocorrências Hoje', '${metrics.totalAlertsToday}', Icons.notification_important, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Alertas Ativos', '${metrics.activeAlertsCount}', Icons.warning_amber_rounded, Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Resolvidos Hoje', '${metrics.resolvedTodayCount}', Icons.check_circle_outline, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Tempo Médio Resposta', '${metrics.avgResponseTimeMinutes} min', Icons.timer_outlined, Colors.amber)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard('Patrulhas Ativas', '${metrics.activePatrolsCount}', Icons.local_police_outlined, Colors.indigo)),
              ],
            ),
            const SizedBox(height: 24),

            // TABELAS E DISTRIBUIÇÃO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distribuição por Categoria
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ocorrências por Categoria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                        const Divider(height: 20),
                        ...metrics.alertsByCategory.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Distribuição por Esquadra Responsável
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Volume por Esquadra / Unidade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                        const Divider(height: 20),
                        ...metrics.alertsByEsquadra.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

// --- VIEW DE GESTÃO DE UTILIZADORES ---
class UsersManagementView extends StatelessWidget {
  final AppController controller;

  const UsersManagementView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final users = controller.systemUsers;

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Gestão de Utilizadores e Acessos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Administração de contas, perfis de despachante, operadores e donos de estabelecimentos.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Ação simulada de adicionar utilizador
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Formulário de novo utilizador aberto.')),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Novo Utilizador'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabela de Utilizadores
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isActive ? Colors.blue.shade100 : Colors.grey.shade200,
                      child: Icon(
                        user.role == UserRole.comando ? Icons.shield : (user.role == UserRole.despachante ? Icons.local_police : Icons.person),
                        color: user.isActive ? Colors.blue.shade900 : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${user.phone} • ${user.role.name.toUpperCase()} ${user.organizationName != null ? "(${user.organizationName})" : ""}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.isActive ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.isActive ? 'ATIVO' : 'INATIVO',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: user.isActive ? Colors.green.shade700 : Colors.red.shade700),
                          ),
                        ),
                        IconButton(
                          icon: Icon(user.isActive ? Icons.block : Icons.check_circle, size: 18, color: user.isActive ? Colors.red : Colors.green),
                          onPressed: () => controller.toggleUserStatus(user.id),
                          tooltip: user.isActive ? 'Desativar' : 'Ativar',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- VIEW DE RELATÓRIOS E AUDITORIA ---
class ReportsView extends StatefulWidget {
  final AppController controller;

  const ReportsView({super.key, required this.controller});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  int _selectedTab = 0; // 0: Métricas, 1: Diário de Contactos e Ocorrências

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final reports = controller.getReportSummary();
    final alerts = controller.alerts;

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho dos Relatórios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Relatórios, Contactos & Auditoria', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Registo detalhado de ocorrências, patrulhas despachadas e contactos efetuados (Hospitais / Bombeiros).', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Relatório Oficial de Ocorrências exportado em PDF com sucesso!')),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.redAccent),
                label: const Text('EXPORTAR RELATÓRIO PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tabs de Seleção
          Row(
            children: [
              ChoiceChip(
                label: const Text('Resumo de Métricas'),
                selected: _selectedTab == 0,
                onSelected: (val) => setState(() => _selectedTab = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Diário de Ocorrências & Contactos Externa'),
                selected: _selectedTab == 1,
                onSelected: (val) => setState(() => _selectedTab = 1),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Conteúdo Conforme Tab
          Expanded(
            child: _selectedTab == 0
                ? _buildSummaryTab(reports)
                : _buildDetailedIncidentsTab(alerts),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(List<ReportSummaryItem> reports) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListView.separated(
        itemCount: reports.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final r = reports[index];
          return ListTile(
            leading: const Icon(Icons.bar_chart, color: Color(0xFF2563EB)),
            title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Total acumulado: ${r.count} registo(s)'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${r.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                Text(r.statusLabel, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailedIncidentsTab(List<AlertItem> alerts) {
    if (alerts.isEmpty) {
      return const Center(child: Text('Nenhuma ocorrência registada no sistema.'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const Divider(height: 16, color: AppTheme.border),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final hasHospitalContact = alert.ambulanceRequested;
          final hasFirefightersContact = alert.firefightersRequested;

          return ExpansionTile(
            dense: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: alert.status == AlertStatus.resolvido
                  ? Colors.green.shade100
                  : (alert.status == AlertStatus.falsoAlarme ? Colors.grey.shade200 : Colors.red.shade100),
              child: Icon(
                alert.status == AlertStatus.resolvido
                    ? Icons.check_circle_outline
                    : (alert.status == AlertStatus.falsoAlarme ? Icons.cancel_outlined : Icons.warning_amber_rounded),
                color: alert.status == AlertStatus.resolvido
                    ? Colors.green.shade800
                    : (alert.status == AlertStatus.falsoAlarme ? Colors.grey.shade700 : Colors.red.shade800),
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Text(
                  'OCORRÊNCIA #${alert.alertUid}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    alert.source.toUpperCase(),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                  ),
                ),
                if (hasHospitalContact) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_hospital, size: 10, color: Colors.red),
                        SizedBox(width: 2),
                        Text('HOSPITAL CONTACTADO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                if (hasFirefightersContact) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_fire_department, size: 10, color: Colors.deepOrange),
                        SizedBox(width: 2),
                        Text('BOMBEIROS CONTACTADOS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Local: ${alert.locationName ?? "Endereço não disponível"} • Esquadra: ${alert.routing.responsible?.name ?? "N/A"}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dados do Alerta
                    if (alert.userName != null) ...[
                      Text('Solicitante: ${alert.userName} (${alert.userPhone ?? "N/A"})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                    ],
                    if (alert.establishmentName != null) ...[
                      Text('Estabelecimento: ${alert.establishmentName} (${alert.buttonLabel ?? "Botão SOS"})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                    ],

                    const SizedBox(height: 8),
                    const Text('AUDITORIA DE CRONOLOGIA & TELEFONES ESTRUTURADOS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),

                    // Histórico Completo de Ações e Contactos
                    ...alert.timeline.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.action.contains('CONTACTO')
                                ? Colors.amber.shade50
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: item.action.contains('CONTACTO') ? Colors.amber.shade300 : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.action.contains('CONTACTO') ? Icons.phone_in_talk : Icons.access_time,
                                size: 14,
                                color: item.action.contains('CONTACTO') ? Colors.amber.shade900 : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.action,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: item.action.contains('CONTACTO') ? FontWeight.bold : FontWeight.normal,
                                    color: item.action.contains('CONTACTO') ? Colors.amber.shade900 : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Text(
                                '${item.at.hour.toString().padLeft(2, '0')}:${item.at.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- VIEW DE GESTÃO DE ESTABELECIMENTOS ---
class EstablishmentsManagementView extends StatelessWidget {
  final AppController controller;

  const EstablishmentsManagementView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ests = controller.establishments;

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Gestão de Estabelecimentos Comerciais', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Estabelecimentos registados, botões de pânico instalados e esquadras de cobertura.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Formulário de novo estabelecimento aberto.')),
                  );
                },
                icon: const Icon(Icons.add_business, size: 16),
                label: const Text('Novo Estabelecimento'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabela de Estabelecimentos
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: ListView.separated(
                itemCount: ests.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final est = ests[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.shade100,
                      child: Icon(
                        est.category.contains('Bomba')
                            ? Icons.local_gas_station
                            : (est.category.contains('Banco') ? Icons.account_balance : Icons.store),
                        color: Colors.amber.shade900,
                        size: 20,
                      ),
                    ),
                    title: Text(est.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${est.category} • ${est.address}\nProprietário: ${est.ownerName} (${est.ownerPhone}) • Coberta por: ${est.responsibleEsquadraName}'),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            '${est.activePanicButtons} Botões SOS',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- VISÃO DE RASTREIO E LOCALIZAÇÃO DE DISPOSITIVOS / CELULARES ROUBADOS (IMEI & GPS) ---
class ImeiTrackingView extends StatefulWidget {
  final AppController controller;

  const ImeiTrackingView({super.key, required this.controller});

  @override
  State<ImeiTrackingView> createState() => _ImeiTrackingViewState();
}

class _ImeiTrackingViewState extends State<ImeiTrackingView> {
  final TextEditingController _searchController = TextEditingController(text: '869401928374651');
  bool _isSearching = false;
  bool _deviceFound = true;
  bool _imeiBlocked = false;

  // Mock tracked device data
  String _deviceName = 'Samsung Galaxy A54 5G (Preto)';
  String _victimName = 'Amélia Sitoe';
  String _victimPhone = '+258 84 912 3456';
  String _carrier = 'Vodacom Moçambique (SIM Slot 1)';
  String _batteryLevel = '74%';
  String _lastSignalTime = 'Há 3 minutos (Em tempo real)';
  String _estimatedLocation = 'Bairro Munhava, próximo ao Mercado Estrela, Beira';
  double _lat = -19.8250;
  double _lng = 34.8600;

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _isSearching = false;
      _deviceFound = true;
      if (query.contains('84') || query.contains('86') || query.startsWith('35')) {
        _deviceName = 'iPhone 13 Pro (Azul Sierra)';
        _victimName = 'Carlos Nhantumbo';
        _victimPhone = '+258 86 543 2109';
        _carrier = 'Movitel Moçambique (eSIM)';
        _batteryLevel = '52%';
        _lastSignalTime = 'Em tempo real';
        _estimatedLocation = 'Bairro Manga, Av. das F.P.L.M., Beira';
        _lat = -19.8020;
        _lng = 34.8750;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📡 Triangulação de sinal de celular concluída com sucesso!'),
          backgroundColor: Colors.blueAccent,
        ),
      );
    }
  }

  void _dispatchPatrolToDevice() {
    // Create alert for nearby patrol dispatch
    widget.controller.triggerDemoButtonAlert();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.directions_car, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text('🚓 Ordem de Interceptação emitida! Patrulha mais próxima acionada para as coordenadas do celular.'),
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade900,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _toggleImeiBlock() {
    setState(() {
      _imeiBlocked = !_imeiBlocked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_imeiBlocked
            ? '🚫 IMEI bloqueado na Base de Dados Nacional (INCM / Vodacom / Movitel / TMcel).'
            : '✅ Desbloqueio do IMEI processado.'),
        backgroundColor: _imeiBlocked ? Colors.red.shade900 : Colors.green.shade800,
      ),
    );
  }

  void _emitRemoteSound() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔊 Sinal sonoro remoto de alta frequência emitido no dispositivo para auxílio nas buscas locais!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Sistema de Rastreio de Celulares & Dispositivos Roubados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Triangulação por antenas GSM (Vodacom / Movitel / TMcel) e GPS em tempo real na Cidade da Beira',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.cell_tower, size: 16, color: Colors.blue),
                    SizedBox(width: 6),
                    Text('REDE GSM NACIONAL: ATIVA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppTheme.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppTheme.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Insira o número de IMEI (15 dígitos), MSISDN (+258...) ou Código da Ocorrência...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _isSearching ? null : _performSearch,
                    icon: _isSearching
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.radar, size: 16),
                    label: Text(_isSearching ? 'Rastreando...' : 'RASTREAR SINAL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Content
          Expanded(
            child: _deviceFound
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Device Specifications and Interception Panel
                      SizedBox(
                        width: 380,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: AppTheme.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.smartphone, color: Colors.blue, size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_deviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text('IMEI: ${_searchController.text}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),

                                _buildDetailItem('Proprietário / Vítima', '$_victimName ($_victimPhone)'),
                                _buildDetailItem('Operadora / Chip', _carrier),
                                _buildDetailItem('Bateria Restante', _batteryLevel),
                                _buildDetailItem('Última Atividade GSM', _lastSignalTime),
                                _buildDetailItem('Localização Estimada', _estimatedLocation),
                                _buildDetailItem('Coordenadas GPS', '$_lat, $_lng'),

                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _imeiBlocked ? Colors.red.shade50 : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: _imeiBlocked ? Colors.red.shade200 : Colors.amber.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(_imeiBlocked ? Icons.block : Icons.warning_amber, size: 18, color: _imeiBlocked ? Colors.red : Colors.amber.shade900),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _imeiBlocked
                                              ? 'ESTADO: IMEI BLOQUEADO NA REDE NACIONAL'
                                              : 'ESTADO: DISPOSITIVO EM DESLOCAMENTO ATIVO',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _imeiBlocked ? Colors.red.shade900 : Colors.amber.shade900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),
                                const Divider(),

                                // Action Buttons for Command
                                Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo.shade900,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: _dispatchPatrolToDevice,
                                        icon: const Icon(Icons.local_police, size: 18),
                                        label: const Text('ENVIAR PATRULHA DE INTERCEPTAÇÃO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: _imeiBlocked ? Colors.green.shade800 : Colors.red.shade800,
                                              side: BorderSide(color: _imeiBlocked ? Colors.green : Colors.red),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                            ),
                                            onPressed: _toggleImeiBlock,
                                            icon: Icon(_imeiBlocked ? Icons.lock_open : Icons.block, size: 16),
                                            label: Text(_imeiBlocked ? 'DESBLOQUEAR' : 'BLOQUEAR IMEI', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.orange.shade900,
                                              side: BorderSide(color: Colors.orange.shade700),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                            ),
                                            onPressed: _emitRemoteSound,
                                            icon: const Icon(Icons.volume_up, size: 16),
                                            label: const Text('BIPE REMOTO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Map View Component showing device signal
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Stack(
                            children: [
                              MapWidget(controller: widget.controller),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.gps_fixed, size: 14, color: Colors.red),
                                      const SizedBox(width: 6),
                                      Text(
                                        'RASTREIO DE SINAL | MARCADOR: CELULAR DE $_victimName',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cell_tower, size: 64, color: AppTheme.textMuted),
                        SizedBox(height: 12),
                        Text('Insira o número de IMEI ou telefone acima para localizar o aparelho.', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}


