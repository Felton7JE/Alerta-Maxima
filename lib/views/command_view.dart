import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/alert_model.dart';
import 'theme.dart';
import 'widgets/map_widget.dart';
import 'widgets/alert_list_widget.dart';
import 'widgets/alert_detail_widget.dart';
import 'widgets/navigation_sidebar.dart';
import 'widgets/management_widgets.dart';

class CommandView extends StatefulWidget {
  final AppController controller;

  const CommandView({super.key, required this.controller});

  @override
  State<CommandView> createState() => _CommandViewState();
}

class _CommandViewState extends State<CommandView> {
  MainMenuTab _currentTab = MainMenuTab.operacional;
  int _selectedMobileIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final user = controller.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    final totalAlerts = controller.alerts.length;
    final escalatedAlerts = controller.alerts.where((a) => a.escalated).length;
    final resolvedAlerts = controller.alerts.where((a) => a.status == AlertStatus.resolvido).length;

    return Scaffold(
      appBar: _buildTopBar(context, user, controller),
      body: Column(
        children: [
          // Banner de Indicadores Globais do Comando Superior
          Container(
            width: double.infinity,
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.spaceAround,
              children: [
                _buildKpiItem('TOTAL OCORRÊNCIAS', '$totalAlerts', Colors.blueAccent),
                _buildKpiItem('RESOLVIDAS', '$resolvedAlerts', Colors.greenAccent),
                _buildKpiItem('ALERTAS ESCALADOS', '$escalatedAlerts', escalatedAlerts > 0 ? Colors.redAccent : Colors.grey),
                _buildKpiItem('TEMPO MÉDIO RESPOSTA', '4.2 min', Colors.amberAccent),
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

  Widget _buildKpiItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context, User? user, AppController controller) {
    return AppBar(
      elevation: 1,
      titleSpacing: 12,
      title: Row(
        children: const [
          Icon(Icons.shield, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Text('COMANDO SUPERIOR | PAINEL ESTRATÉGICO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, color: Colors.white)),
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
                '${user.name} [COMANDANTE]',
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
        // Sidebar do Comando Geral com Abas Estratégicas Globais (Fundo Padrão)
        NavigationSidebar(
          title: 'COMANDO SUPERIOR',
          titleIcon: Icons.shield,
          allowedTabs: const [
            MainMenuTab.dashboard,
            MainMenuTab.operacional,
            MainMenuTab.rastreioImei,
            MainMenuTab.estabelecimentos,
            MainMenuTab.utilizadores,
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
            SizedBox(
              width: 350,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppTheme.border)),
                ),
                child: AlertListWidget(controller: controller),
              ),
            ),
            Expanded(
              child: MapWidget(controller: controller),
            ),
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

  Widget _buildMobileLayout(AppController controller) {
    switch (_selectedMobileIndex) {
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
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Detalhes'),
      ],
    );
  }
}
