import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/alert_model.dart';
import 'theme.dart';
import 'widgets/map_widget.dart';
import 'widgets/alert_list_widget.dart';
import 'widgets/alert_detail_widget.dart';

class OperatorView extends StatefulWidget {
  final AppController controller;

  const OperatorView({super.key, required this.controller});

  @override
  State<OperatorView> createState() => _OperatorViewState();
}

class _OperatorViewState extends State<OperatorView> {
  int _selectedTabIndex = 0;

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
          // Banner Operador - Notificação de Triagem
          Container(
            width: double.infinity,
            color: AppTheme.appBarBg,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.headset_mic_outlined, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'CENTRAL DE OPERAÇÕES E TRIAGEM DE EMERGÊNCIAS — MODO ATENDIMENTO ATIVO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),

          // Banner de Escalada (se existir)
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
          const Text('CENTRAL SOS | OPERADOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: Colors.white)),
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
                '${user.name} [OPERADOR]',
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
        SizedBox(
          width: 340,
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
