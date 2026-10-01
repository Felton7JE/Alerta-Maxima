import 'package:flutter/material.dart';

enum MainMenuTab {
  dashboard,
  operacional,
  estabelecimentos,
  ocorrencias,
  alertas,
  utilizadores,
  relatorios,
  rastreioImei,
}

extension MainMenuTabExtension on MainMenuTab {
  String get label {
    switch (this) {
      case MainMenuTab.dashboard:
        return 'Dashboard';
      case MainMenuTab.operacional:
        return 'Operacional';
      case MainMenuTab.estabelecimentos:
        return 'Estabelecimentos';
      case MainMenuTab.ocorrencias:
        return 'Ocorrências';
      case MainMenuTab.alertas:
        return 'Alertas';
      case MainMenuTab.utilizadores:
        return 'Utilizadores';
      case MainMenuTab.relatorios:
        return 'Relatórios';
      case MainMenuTab.rastreioImei:
        return 'Rastreio IMEI/GPS';
    }
  }

  IconData get icon {
    switch (this) {
      case MainMenuTab.dashboard:
        return Icons.dashboard_outlined;
      case MainMenuTab.operacional:
        return Icons.local_police_outlined;
      case MainMenuTab.estabelecimentos:
        return Icons.storefront_outlined;
      case MainMenuTab.ocorrencias:
        return Icons.assignment_late_outlined;
      case MainMenuTab.alertas:
        return Icons.notifications_active_outlined;
      case MainMenuTab.utilizadores:
        return Icons.people_alt_outlined;
      case MainMenuTab.relatorios:
        return Icons.bar_chart_outlined;
      case MainMenuTab.rastreioImei:
        return Icons.cell_tower_outlined;
    }
  }
}

class NavigationSidebar extends StatelessWidget {
  final MainMenuTab currentTab;
  final ValueChanged<MainMenuTab> onTabSelected;
  final List<MainMenuTab>? allowedTabs;
  final Color backgroundColor;
  final Color selectedColor;
  final String title;
  final IconData titleIcon;

  const NavigationSidebar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.allowedTabs,
    this.backgroundColor = const Color(0xFF0F172A),
    this.selectedColor = const Color(0xFF2563EB),
    this.title = 'PAINEL PRINCIPAL',
    this.titleIcon = Icons.shield,
  });

  @override
  Widget build(BuildContext context) {
    final tabsToDisplay = allowedTabs ?? MainMenuTab.values;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(right: BorderSide(color: Color(0xFF334155))),
      ),
      child: Column(
        children: [
          // Cabeçalho da Navegação
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(titleIcon, color: Colors.amber, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 8),

          // Itens do Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: tabsToDisplay.map((tab) {
                final isSelected = tab == currentTab;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      tab.icon,
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      size: 18,
                    ),
                    title: Text(
                      tab.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () => onTabSelected(tab),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

