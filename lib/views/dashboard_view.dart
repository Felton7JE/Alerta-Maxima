import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/alert_model.dart';
import 'theme.dart';
import 'widgets/map_widget.dart';
import 'widgets/alert_list_widget.dart';
import 'widgets/alert_detail_widget.dart';

class DashboardView extends StatefulWidget {
  final AppController controller;

  const DashboardView({super.key, required this.controller});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedTabIndex = 0; // Para visualização Mobile (0: Lista, 1: Mapa, 2: Detalhes, 3: Patrulhas/Stats)

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
          // Banner de Alertas Sem Resposta / Escalada
          if (controller.alerts.any((a) => a.escalated))
            Container(
              width: double.infinity,
              color: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: const Text(
                'ATENÇÃO: EXISTEM ALERTAS ESCALADOS SEM RESPOSTA DA ESQUADRA RESPONSÁVEL',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),

          // Conteúdo Principal
          Expanded(
            child: isDesktop ? _buildDesktopLayout(controller) : _buildMobileLayout(controller),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileNavBar(),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context, User? user, AppController controller) {
    final activeCount = controller.alerts.where((a) => a.status != AlertStatus.resolvido && a.status != AlertStatus.falsoAlarme).length;

    return AppBar(
      elevation: 1,
      titleSpacing: 12,
      title: Row(
        children: [
          const Text('ALERTA SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: Colors.white)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: activeCount > 0 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '$activeCount ACTIVOS',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              children: const [
                Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                SizedBox(width: 4),
                Text('EM TEMPO REAL (MOCK)', style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (user != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                '${user.name} [${user.role.name.toUpperCase()}]',
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
    final user = controller.currentUser;

    return Row(
      children: [
        // Painel da Esquerda (Lista de Alertas / Patrulhas)
        SizedBox(
          width: 340,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppTheme.border)),
            ),
            child: user?.role == UserRole.despachante
                ? _buildEsquadraLeftPanel(controller)
                : AlertListWidget(controller: controller),
          ),
        ),

        // Centro (Mapa)
        Expanded(
          child: MapWidget(controller: controller),
        ),

        // Painel da Direita (Detalhes do Alerta Selecionado)
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
  }

  Widget _buildEsquadraLeftPanel(AppController controller) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'ALERTAS'),
              Tab(text: 'PATRULHAS'),
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
    );
  }

  Widget _buildPatrolsList(AppController controller) {
    final stationPatrols = controller.patrols.where((p) => p.organizationId == controller.currentUser?.organizationId).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: stationPatrols.length,
      separatorBuilder: (_, __) => const Divider(color: AppTheme.border),
      itemBuilder: (context, index) {
        final patrol = stationPatrols[index];
        return ListTile(
          dense: true,
          title: Text(patrol.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          subtitle: Text('Estado: ${patrol.status.label}', style: const TextStyle(fontSize: 11)),
          trailing: Switch(
            value: patrol.status == PatrolStatus.disponivel,
            onChanged: (val) {
              controller.togglePatrolAvailability(patrol);
            },
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(AppController controller) {
    switch (_selectedTabIndex) {
      case 0:
        return AlertListWidget(controller: controller);
      case 1:
        return MapWidget(controller: controller);
      case 2:
        return AlertDetailWidget(controller: controller);
      default:
        return AlertListWidget(controller: controller);
    }
  }

  Widget _buildMobileNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedTabIndex,
      onTap: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      selectedItemColor: AppTheme.appBarBg,
      unselectedItemColor: AppTheme.textMuted,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Alertas'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Detalhes'),
      ],
    );
  }
}
