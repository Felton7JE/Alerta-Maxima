import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/alert_model.dart';
import 'theme.dart';
import 'widgets/map_widget.dart';
import 'widgets/alert_list_widget.dart';
import 'widgets/alert_detail_widget.dart';
import 'widgets/navigation_sidebar.dart';
import 'widgets/management_widgets.dart';

class EsquadraView extends StatefulWidget {
  final AppController controller;

  const EsquadraView({super.key, required this.controller});

  @override
  State<EsquadraView> createState() => _EsquadraViewState();
}

class _EsquadraViewState extends State<EsquadraView> {
  MainMenuTab _currentTab = MainMenuTab.operacional;
  int _selectedMobileIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final user = controller.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      appBar: _buildTopBar(context, user, controller),
      body: Column(
        children: [
          // Banner Esquadra
          Container(
            width: double.infinity,
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_police_outlined, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'ESQUADRA POLICIAL | DESPACHO DE PATRULHAS NO TERRENO — ${user?.name ?? ""}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),

          Expanded(
            child: isDesktop ? _buildDesktopLayout(controller) : _buildMobileLayout(controller),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileNavBar(),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context, User? user, AppController controller) {
    final stationAlerts = controller.alerts.where((a) => a.routing.responsible?.id == user?.organizationId).length;

    return AppBar(
      elevation: 1,
      titleSpacing: 12,
      title: Row(
        children: [
          const Text('ESQUADRA | DESPACHO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: Colors.white)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade800,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '$stationAlerts NA ESQUADRA',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
      actions: [
        // Seletor de Perfil Rápido (DEMO)
        PopupMenuButton<UserRole>(
          tooltip: 'Trocar Perfil (DEMO)',
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white38),
            ),
            child: Row(
              children: const [
                Icon(Icons.swap_horiz, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text('PERFIL DEMO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          onSelected: (role) {
            controller.switchUserRole(role);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: UserRole.operador, child: Text('🎧 Central (Operador)', style: TextStyle(fontSize: 12))),
            const PopupMenuItem(value: UserRole.despachante, child: Text('🚓 Esquadra (Despachante)', style: TextStyle(fontSize: 12))),
            const PopupMenuItem(value: UserRole.comando, child: Text('🛡️ Comando Superior', style: TextStyle(fontSize: 12))),
            const PopupMenuItem(value: UserRole.cidadao, child: Text('📱 Cidadão SOS', style: TextStyle(fontSize: 12))),
            const PopupMenuItem(value: UserRole.donoEstabelecimento, child: Text('🏢 Dono Estabelecimento', style: TextStyle(fontSize: 12))),
          ],
        ),

        if (user != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                '${user.name} [DESPACHANTE]',
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 16, color: Colors.white),
            tooltip: 'Sair',
            onPressed: () => controller.logout(),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(AppController controller) {
    return Row(
      children: [
        // Sidebar da Esquadra com Abas Específicas (Fundo Padrão)
        NavigationSidebar(
          title: 'ESQUADRA LOCAL',
          titleIcon: Icons.local_police,
          allowedTabs: const [
            MainMenuTab.operacional,
            MainMenuTab.rastreioImei,
            MainMenuTab.alertas,
            MainMenuTab.ocorrencias,
            MainMenuTab.relatorios,
          ],
          currentTab: _currentTab,
          onTabSelected: (tab) {
            setState(() {
              _currentTab = tab;
            });
          },
        ),

        // Conteúdo da Secção Selecionada
        Expanded(
          child: _buildSectionContent(_currentTab, controller),
        ),
      ],
    );
  }

  Widget _buildSectionContent(MainMenuTab tab, AppController controller) {
    switch (tab) {
      case MainMenuTab.operacional:
      case MainMenuTab.alertas:
      case MainMenuTab.ocorrencias:
        return Row(
          children: [
            // Painel Esquerda (Abas Alertas e Patrulhas da Esquadra)
            SizedBox(
              width: 350,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppTheme.border)),
                ),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'ALERTAS DA ESQUADRA'),
                          Tab(text: 'PATRULHAS / VIATURAS'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            AlertListWidget(controller: controller),
                            _buildPatrolsList(controller),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Centro (Mapa)
            Expanded(
              child: MapWidget(controller: controller),
            ),

            // Direita (Detalhes)
            if (controller.selectedAlert != null)
              SizedBox(
                width: 360,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: AppTheme.border)),
                  ),
                  child: AlertDetailWidget(controller: controller),
                ),
              ),
          ],
        );
      case MainMenuTab.dashboard:
        return StrategicDashboardView(controller: controller);
      case MainMenuTab.rastreioImei:
        return ImeiTrackingView(controller: controller);
      case MainMenuTab.estabelecimentos:
        return EstablishmentsManagementView(controller: controller);
      case MainMenuTab.utilizadores:
        return UsersManagementView(controller: controller);
      case MainMenuTab.relatorios:
        return ReportsView(controller: controller);
    }
  }

  Widget _buildPatrolsList(AppController controller) {
    final stationPatrols = controller.patrols.where((p) => p.organizationId == controller.currentUser?.organizationId).toList();

    return Column(
      children: [
        // Botão Nova Patrulha
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.appBarBg,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('NOVA PATRULHA / VIATURA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () => _showAddPatrolDialog(context, controller),
            ),
          ),
        ),

        Expanded(
          child: stationPatrols.isEmpty
              ? const Center(child: Text('Nenhuma patrulha cadastrada para esta esquadra.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: stationPatrols.length,
                  separatorBuilder: (_, __) => const Divider(color: AppTheme.border, height: 1),
                  itemBuilder: (context, index) {
                    final patrol = stationPatrols[index];
                    final isAvail = patrol.status == PatrolStatus.disponivel;
                    final isBusy = patrol.status == PatrolStatus.despachada || patrol.status == PatrolStatus.aCaminho || patrol.status == PatrolStatus.noLocal;

                    Color statusColor = isAvail
                        ? Colors.green.shade700
                        : (isBusy ? Colors.orange.shade800 : Colors.red.shade700);

                    return ExpansionTile(
                      dense: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      leading: Icon(
                        Icons.directions_car,
                        color: statusColor,
                        size: 20,
                      ),
                      title: Text(
                        patrol.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      subtitle: Text(
                        '${patrol.vehicle ?? "Sem viatura"} • ${patrol.status.label}',
                        style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                      ),
                      trailing: PopupMenuButton<PatrolStatus>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (newStatus) {
                          controller.setPatrolStatus(patrol, newStatus);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: PatrolStatus.disponivel,
                            child: Text('🟢 Disponível', style: TextStyle(fontSize: 12)),
                          ),
                          const PopupMenuItem(
                            value: PatrolStatus.despachada,
                            child: Text('🟠 Despachada', style: TextStyle(fontSize: 12)),
                          ),
                          const PopupMenuItem(
                            value: PatrolStatus.aCaminho,
                            child: Text('🔵 A caminho', style: TextStyle(fontSize: 12)),
                          ),
                          const PopupMenuItem(
                            value: PatrolStatus.noLocal,
                            child: Text('🟡 No local', style: TextStyle(fontSize: 12)),
                          ),
                          const PopupMenuItem(
                            value: PatrolStatus.indisponivel,
                            child: Text('🔴 Indisponível', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (patrol.teamMembers != null) ...[
                                Text('Agentes: ${patrol.teamMembers}', style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary)),
                                const SizedBox(height: 4),
                              ],
                              if (patrol.lat != null && patrol.lon != null) ...[
                                Text('Coordenadas: ${patrol.lat!.toStringAsFixed(4)}, ${patrol.lon!.toStringAsFixed(4)}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                const SizedBox(height: 6),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                                    icon: const Icon(Icons.delete_outline, size: 14),
                                    label: const Text('Remover', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      controller.removePatrol(patrol.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddPatrolDialog(BuildContext context, AppController controller) {
    final nameCtrl = TextEditingController();
    final vehicleCtrl = TextEditingController();
    final teamCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cadastrar Nova Patrulha', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome da Patrulha (ex: Patrulha Alfa 3)', isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: vehicleCtrl,
                  decoration: const InputDecoration(labelText: 'Identificação da Viatura (ex: PR-102)', isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: teamCtrl,
                  decoration: const InputDecoration(labelText: 'Membros / Agentes (ex: Sgt. João, Ag. Maria)', isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.appBarBg, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final orgId = controller.currentUser?.organizationId ?? 'esq_a';
                  final org = controller.organizations.firstWhere((o) => o.id == orgId, orElse: () => controller.organizations[1]);

                  final newP = Patrol(
                    id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    vehicle: vehicleCtrl.text.trim().isEmpty ? 'Viatura' : vehicleCtrl.text.trim(),
                    teamMembers: teamCtrl.text.trim().isEmpty ? 'Agentes escalados' : teamCtrl.text.trim(),
                    status: PatrolStatus.disponivel,
                    organizationId: orgId,
                    lat: org.lat + 0.002,
                    lon: org.lon + 0.002,
                  );
                  controller.addPatrol(newP);
                  Navigator.pop(context);
                }
              },
              child: const Text('Cadastrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(AppController controller) {
    switch (_selectedMobileIndex) {
      case 0:
        return AlertListWidget(controller: controller);
      case 1:
        return _buildPatrolsList(controller);
      case 2:
        return MapWidget(controller: controller);
      case 3:
        return AlertDetailWidget(controller: controller);
      default:
        return AlertListWidget(controller: controller);
    }
  }

  Widget _buildMobileNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedMobileIndex,
      onTap: (index) {
        setState(() {
          _selectedMobileIndex = index;
        });
      },
      selectedItemColor: AppTheme.appBarBg,
      unselectedItemColor: AppTheme.textMuted,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Alertas'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Patrulhas'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Detalhes'),
      ],
    );
  }
}
