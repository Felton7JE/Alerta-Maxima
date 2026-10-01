import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../models/alert_model.dart';
import 'theme.dart';
import 'widgets/alert_detail_widget.dart';

class DonoView extends StatefulWidget {
  final AppController controller;

  const DonoView({super.key, required this.controller});

  @override
  State<DonoView> createState() => _DonoViewState();
}

class _DonoViewState extends State<DonoView> with SingleTickerProviderStateMixin {
  bool _panicActive = false;
  int _sosCountdown = 3;
  bool _isCountingDown = false;
  late AnimationController _animController;
  final TextEditingController _notesController = TextEditingController();

  // Selected tab in Dono View
  int _selectedTab = 0; // 0: Visão Geral / SOS, 1: Meus Alertas, 2: Ficha do Estabelecimento, 3: Contactos Directos

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _triggerPanic() async {
    setState(() {
      _isCountingDown = true;
      _sosCountdown = 3;
    });

    for (int i = 3; i > 0; i--) {
      if (!mounted || !_isCountingDown) return;
      setState(() {
        _sosCountdown = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted || !_isCountingDown) return;

    setState(() {
      _isCountingDown = false;
      _panicActive = true;
    });

    // Create real panic alert in system controller
    widget.controller.triggerDemoButtonAlert();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('🚨 SOS ENVIADO COM SUCESSO! Alarme comercial ativado. Central da PRM notificada.'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade900,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _cancelPanicTrigger() {
    setState(() {
      _isCountingDown = false;
    });
  }

  void _deactivatePanic() {
    setState(() {
      _panicActive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarme SOS Silencioso desativado.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final user = controller.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final storeAlerts = controller.alerts.where((a) => (a.locationName?.contains('Bomba') ?? false) || a.source == 'botao' || (a.establishmentName != null)).toList();

        return Scaffold(
          backgroundColor: AppTheme.lightBg,
          appBar: _buildCommercialHeader(context, user, controller),
          body: Column(
            children: [
              // Commercial Status Banner
              _buildTopStatusBanner(),

              // Content Area
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Navigation & Quick Specs Sidebar
                          SizedBox(
                            width: 280,
                            child: _buildCommercialSidebar(),
                          ),
                          // Main Dynamic Tab Content
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: _buildActiveTabContent(storeAlerts, controller),
                            ),
                          ),
                          // Right Detail Drawer if alert selected
                          if (controller.selectedAlert != null)
                            SizedBox(
                              width: 360,
                              child: Container(
                                margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: AlertDetailWidget(controller: controller),
                              ),
                            ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildMobileTabs(),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: _buildActiveTabContent(storeAlerts, controller),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildCommercialHeader(BuildContext context, User? user, AppController controller) {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      elevation: 2,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'PORTAL DO ESTABELECIMENTO COMERCIAL',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8, color: Colors.white),
              ),
              Text(
                'Gestão Integrada de Segurança & Linha Direta PRM',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (user != null)
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.person, size: 12, color: Colors.black),
                ),
                const SizedBox(width: 8),
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        IconButton(
          icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
          tooltip: 'Sair do Sistema',
          onPressed: () => controller.logout(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTopStatusBanner() {
    if (_panicActive) {
      return FadeTransition(
        opacity: _animController,
        child: Container(
          width: double.infinity,
          color: Colors.red.shade900,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning, color: Colors.amber, size: 20),
                  SizedBox(width: 10),
                  Text(
                    '🚨 ATENÇÃO: SOS SILENCIOSO ATIVADO! COMANDO PRM E ESQUADRA LOCAL EM ALERTA MÁXIMO',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: _deactivatePanic,
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('CANCELAR ALARME SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, color: Colors.greenAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'SISTEMA DE SEGURANÇA: OPERACIONAL | CONEXÃO ENCRIPTADA COM A 2ª ESQUADRA PRM (BEIRA)',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                SizedBox(width: 4),
                Text('MONITORIZADO', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommercialSidebar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Summary Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.appBarBg.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_gas_station, color: AppTheme.appBarBg, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Posto Total Macurungo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                          ),
                          Text(
                            'Cód: COM-BEIRA-8821',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Tabs
          const SizedBox(height: 8),
          _buildSidebarNavItem(0, Icons.touch_app, 'Painel SOS & Gatilho'),
          _buildSidebarNavItem(1, Icons.history, 'Histórico de Ocorrências'),
          _buildSidebarNavItem(2, Icons.badge_outlined, 'Ficha do Estabelecimento'),
          _buildSidebarNavItem(3, Icons.phone_in_talk, 'Contactos de Emergência'),

          const Spacer(),

          // Security Status Footer Card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.security, size: 16, color: Color(0xFF1D4ED8)),
                    SizedBox(width: 6),
                    Text('Esquadra de Referência', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E40AF))),
                  ],
                ),
                SizedBox(height: 4),
                Text('2ª Esquadra PRM - Baixa / Macurungo', style: TextStyle(fontSize: 11, color: Color(0xFF1E3A8A))),
                Text('Distância estimada: ~1.2 km', style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.appBarBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : AppTheme.textMuted),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _buildMobileTabButton(0, 'SOS')),
          Expanded(child: _buildMobileTabButton(1, 'Histórico')),
          Expanded(child: _buildMobileTabButton(2, 'Ficha')),
          Expanded(child: _buildMobileTabButton(3, 'Contactos')),
        ],
      ),
    );
  }

  Widget _buildMobileTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? AppTheme.appBarBg : Colors.transparent, width: 2)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.appBarBg : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(List<AlertItem> storeAlerts, AppController controller) {
    switch (_selectedTab) {
      case 0:
        return _buildPanicOverviewTab();
      case 1:
        return _buildHistoryTab(storeAlerts, controller);
      case 2:
        return _buildEstablishmentProfileTab();
      case 3:
        return _buildEmergencyContactsTab();
      default:
        return _buildPanicOverviewTab();
    }
  }

  // TAB 0: PAINEL SOS SILENCIOSO
  Widget _buildPanicOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gatilho de Emergência Comercial (SOS Silencioso)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pressione o botão de pânico abaixo para emitir um alerta imediato e silencioso diretamente ao Centro de Comando da PRM na Beira.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Center(
              child: _isCountingDown
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'EMITINDO ALERTA EM',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                        ),
                        const SizedBox(height: 12),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.red.shade700,
                          child: Text(
                            '$_sosCountdown',
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: _cancelPanicTrigger,
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text('CANCELAR DISPARO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _triggerPanic,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _panicActive
                                    ? [Colors.orange.shade700, Colors.red.shade900]
                                    : [Colors.red.shade600, Colors.red.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.touch_app, size: 64, color: Colors.white),
                                SizedBox(height: 8),
                                Text(
                                  'GATILHO SOS',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
                                ),
                                Text(
                                  '1 TOQUE SILENCIOSO',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            border: Border.all(color: Colors.amber.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.info_outline, color: Colors.amber, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'A sirene local não tocará. A notificação será enviada diretamente à Esquadra da PRM.',
                                style: TextStyle(fontSize: 11, color: Colors.brown),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: HISTÓRICO DE OCORRÊNCIAS
  Widget _buildHistoryTab(List<AlertItem> storeAlerts, AppController controller) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Histórico de Chamados & Ocorrências',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    'Registos de alertas emitidos por este estabelecimento comercial',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              Chip(
                backgroundColor: AppTheme.lightBg,
                label: Text('${storeAlerts.length} Registos', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),

          Expanded(
            child: storeAlerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                        SizedBox(height: 12),
                        Text('Nenhuma ocorrência registada recentemente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Seu estabelecimento não possui alertas ativos ou pendentes.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: storeAlerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final alert = storeAlerts[index];
                      final isSelected = controller.selectedAlert?.alertUid == alert.alertUid;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: isSelected ? AppTheme.appBarBg : AppTheme.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                        child: ListTile(
                          onTap: () => controller.selectAlert(alert),
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(alert.status).withValues(alpha: 0.15),
                            child: Icon(_getStatusIcon(alert.status), color: _getStatusColor(alert.status), size: 20),
                          ),
                          title: Row(
                            children: [
                              Text(
                                'CÓDIGO: ${alert.alertUid}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(alert.status),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                alert.details ?? alert.buttonLabel ?? alert.category ?? 'Disparo de Alarme Comercial',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Acionado em: ${DateFormat('dd/MM/yyyy - HH:mm').format(alert.createdAt)}',
                                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.textMuted),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // TAB 2: FICHA DO ESTABELECIMENTO
  Widget _buildEstablishmentProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados Cadastrais do Estabelecimento Comercial',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const Text(
              'Informações compartilhadas com a Polícia da Beira para pronta resposta',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const Divider(height: 24),

            _buildProfileDataRow('Razão Social / Nome Fantasia', 'Posto de Combustível Total Macurungo'),
            _buildProfileDataRow('Tipo de Licença Commercial', 'Posto de Abastecimento & Conveniência 24h'),
            _buildProfileDataRow('NUIT Commercial', '400192837'),
            _buildProfileDataRow('Endereço Físico (Beira)', 'Av. Eduardo Mondlane, Bairro Macurungo, Beira'),
            _buildProfileDataRow('Ponto de Referência', 'Em frente ao Cruzamento da Ponta Gêa / Macurungo'),
            _buildProfileDataRow('Contacto Directo do Gerente', '+258 84 000 0006 (Ativo 24/7)'),
            _buildProfileDataRow('Empresa de Segurança Privada', 'G4S Mozambique - Contrato #8819'),
            _buildProfileDataRow('Esquadra PRM Jurisdicional', '2ª Esquadra PRM - Baixa / Macurungo'),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: AppTheme.appBarBg, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Segurança de Dados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Estes dados são transmitidos via canal encriptado para a Central Operacional da Polícia da Beira.', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  // TAB 3: CONTACTOS DE EMERGÊNCIA DIRECTOS
  Widget _buildEmergencyContactsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Directório de Contactos Rápido - Beira',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const Text(
            'Linha direta de emergência para apoio imediato em situações de risco',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const Divider(height: 24),

          Expanded(
            child: ListView(
              children: [
                _buildContactCard(
                  title: 'Comando Provincial PRM Sofala (Beira)',
                  phone: '+258 23 322 222',
                  subtitle: 'Central General de Emergências da Polícia',
                  icon: Icons.local_police,
                  color: Colors.blue.shade900,
                ),
                _buildContactCard(
                  title: '2ª Esquadra PRM (Macurungo / Baixa)',
                  phone: '+258 23 324 500',
                  subtitle: 'Esquadra responsável pela sua zona comercial',
                  icon: Icons.shield,
                  color: Colors.indigo.shade800,
                ),
                _buildContactCard(
                  title: 'Corpo de Salvação de Bombeiros da Beira',
                  phone: '+258 23 323 333',
                  subtitle: 'Combate a Incêndios e Resgate Urbano',
                  icon: Icons.local_fire_department,
                  color: Colors.red.shade800,
                ),
                _buildContactCard(
                  title: 'Hospital Central da Beira - Urgências',
                  phone: '+258 23 320 820',
                  subtitle: 'Pronto-Socorro Geral 24 horas',
                  icon: Icons.local_hospital,
                  color: Colors.teal.shade800,
                ),
                _buildContactCard(
                  title: 'Centro de Saúde da Ponta Gêa',
                  phone: '+258 23 325 110',
                  subtitle: 'Unidade Sanitária Próxima ao Estabelecimento',
                  icon: Icons.medical_services,
                  color: Colors.green.shade800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String phone,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        trailing: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📞 A discar para $title ($phone)...'),
                backgroundColor: color,
              ),
            );
          },
          icon: const Icon(Icons.phone, size: 14, color: Colors.white),
          label: Text(phone, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }

  Color _getStatusColor(AlertStatus status) {
    switch (status) {
      case AlertStatus.novo:
        return Colors.red;
      case AlertStatus.assumido:
      case AlertStatus.equipaACaminho:
        return Colors.orange;
      case AlertStatus.equipaNoLocal:
        return Colors.purple;
      case AlertStatus.resolvido:
        return Colors.green;
      case AlertStatus.falsoAlarme:
      case AlertStatus.canceladoPeloUtilizador:
      case AlertStatus.expirado:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(AlertStatus status) {
    switch (status) {
      case AlertStatus.novo:
        return Icons.warning_amber;
      case AlertStatus.assumido:
      case AlertStatus.equipaACaminho:
        return Icons.directions_car;
      case AlertStatus.equipaNoLocal:
        return Icons.pin_drop;
      case AlertStatus.resolvido:
        return Icons.check_circle;
      case AlertStatus.falsoAlarme:
      case AlertStatus.canceladoPeloUtilizador:
      case AlertStatus.expirado:
        return Icons.cancel;
    }
  }

  Widget _buildStatusBadge(AlertStatus status) {
    String text = '';
    Color bg = Colors.grey;
    switch (status) {
      case AlertStatus.novo:
        text = 'NOVO';
        bg = Colors.red;
        break;
      case AlertStatus.assumido:
        text = 'EM ANÁLISE';
        bg = Colors.amber;
        break;
      case AlertStatus.equipaACaminho:
        text = 'POLÍCIA A CAMINHO';
        bg = Colors.orange;
        break;
      case AlertStatus.equipaNoLocal:
        text = 'PATRULHA NO LOCAL';
        bg = Colors.purple;
        break;
      case AlertStatus.resolvido:
        text = 'RESOLVIDO';
        bg = Colors.green;
        break;
      case AlertStatus.falsoAlarme:
        text = 'FALSO ALARME';
        bg = Colors.grey;
        break;
      case AlertStatus.canceladoPeloUtilizador:
        text = 'CANCELADO';
        bg = Colors.grey;
        break;
      case AlertStatus.expirado:
        text = 'EXPIRADO';
        bg = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        border: Border.all(color: bg, width: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: bg, fontWeight: FontWeight.bold, fontSize: 9),
      ),
    );
  }
}

