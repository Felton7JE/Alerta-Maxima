import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/alert_model.dart';
import 'theme.dart';

class CitizenView extends StatefulWidget {
  final AppController controller;

  const CitizenView({super.key, required this.controller});

  @override
  State<CitizenView> createState() => _CitizenViewState();
}

class _CitizenViewState extends State<CitizenView> {
  int _currentIndex = 0;
  bool _sosDisparado = false;
  
  // Estado do formulário de Denúncia
  String? _selectedCategory;
  String _selectedPriority = 'ALTA';
  final _locationReferenceController = TextEditingController(text: 'Zona Central');
  final _detailsController = TextEditingController();
  bool _useMyLocation = true;
  double _currentLat = -19.8436;
  double _currentLon = 34.8389;
  bool _isGettingLocation = false;
  String _locationStatusText = 'Lat: -19.8436, Lon: 34.8389 (Precisão: ±4m)';

  bool _isAnonymous = false;
  final List<Map<String, String>> _attachedEvidences = [];

  String _searchContactQuery = '';
  String _selectedContactFilter = 'Todos';

  void _getCurrentLocation() {
    setState(() {
      _isGettingLocation = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
          _currentLat = -19.8436 + (DateTime.now().second % 10) * 0.0002;
          _currentLon = 34.8389 + (DateTime.now().second % 10) * 0.0002;
          _locationStatusText = 'Lat: ${_currentLat.toStringAsFixed(5)}, Lon: ${_currentLon.toStringAsFixed(5)} (Precisão: ±2m)';
          _useMyLocation = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Localização exata capturada: ${_currentLat.toStringAsFixed(4)}, ${_currentLon.toStringAsFixed(4)}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    });
  }

  void _openMediaSourceModal(String mediaType) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ANEXAR ${mediaType.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Escolha a origem da mídia para anexar à denúncia:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Câmara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Tirar foto ou gravar vídeo no momento', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _addSimulatedEvidence(mediaType, 'Câmara');
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.photo_library, color: Colors.purple),
                ),
                title: const Text('Galeria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Escolher foto ou vídeo armazenado na galeria', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _addSimulatedEvidence(mediaType, 'Galeria');
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.folder, color: Colors.orange),
                ),
                title: const Text('Explorador de Ficheiros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Carregar ficheiro local, PDF ou documento', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _addSimulatedEvidence(mediaType, 'Ficheiros');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addSimulatedEvidence(String mediaType, String source) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    String filename;
    if (mediaType == 'Foto') {
      filename = 'IMG_$timestamp.jpg';
    } else if (mediaType == 'Vídeo') {
      filename = 'VID_$timestamp.mp4';
    } else {
      filename = 'DOC_$timestamp.pdf';
    }

    setState(() {
      _attachedEvidences.add({
        'name': filename,
        'type': mediaType,
        'source': source,
        'size': '2.4 MB',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$mediaType anexado(a) com sucesso via $source!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Categorias de incidentes sem ícones exagerados
  final List<Map<String, String>> _incidentCategories = [
    {'title': 'Acidente', 'desc': 'Acidentes rodoviários ou de trânsito'},
    {'title': 'Assalto', 'desc': 'Roubo ou furto com/sem ameaça'},
    {'title': 'Agressão', 'desc': 'Violência física ou ameaça'},
    {'title': 'Invasão', 'desc': 'Invasão de propriedade ou domicílio'},
    {'title': 'Esfaqueamento', 'desc': 'Agressão com arma branca'},
    {'title': 'Ameaça com arma', 'desc': 'Porte ou ameaça com arma de fogo'},
    {'title': 'Incêndio', 'desc': 'Fogo em estrutura ou veículo'},
    {'title': 'Emergência médica', 'desc': 'Necessidade de socorro médico'},
  ];

  // Contactos de emergência
  final List<Map<String, String>> _emergencyContacts = [
    {'name': 'Polícia Nacional (Beira)', 'phone': '+258 84 100 0001', 'category': 'Polícia'},
    {'name': 'Bombeiros Voluntários', 'phone': '+258 84 100 0002', 'category': 'Bombeiros'},
    {'name': 'Emergência Médica (SAMU)', 'phone': '+258 84 100 0003', 'category': 'Emergência médica'},
    {'name': 'Central de Segurança SOS', 'phone': '+258 84 100 0004', 'category': 'Central de segurança'},
  ];

  IconData _getCategoryIcon(String title) {
    switch (title) {
      case 'Acidente':
        return Icons.car_crash_outlined;
      case 'Assalto':
        return Icons.shield_outlined;
      case 'Agressão':
        return Icons.warning_amber_rounded;
      case 'Invasão':
        return Icons.home_work_outlined;
      case 'Esfaqueamento':
        return Icons.medication_outlined;
      case 'Ameaça com arma':
        return Icons.gavel_outlined;
      case 'Incêndio':
        return Icons.local_fire_department_outlined;
      case 'Emergência médica':
        return Icons.medical_services_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  @override
  void dispose() {
    _locationReferenceController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MINHA SEGURANÇA',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2, color: Colors.white),
            ),
            Text(
              user?.name ?? 'Cidadão',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 18, color: Colors.white),
            tooltip: 'Sair',
            onPressed: () => widget.controller.logout(),
          ),
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: AppTheme.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.emergency_outlined), label: 'Início (SOS)'),
          BottomNavigationBarItem(icon: Icon(Icons.add_alert_outlined), label: 'Denunciar'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Denúncias'),
          BottomNavigationBarItem(icon: Icon(Icons.phone_outlined), label: 'Contactos'),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildInicioSosTab();
      case 1:
        return _buildDenunciarTab();
      case 2:
        return _buildMinhasDenunciasTab();
      case 3:
        return _buildContactosTab();
      default:
        return _buildInicioSosTab();
    }
  }

  // --- ABA 1: INÍCIO (EMERGÊNCIA SOS PÂNICO) ---
  Widget _buildInicioSosTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_sosDisparado) ...[
              const Text(
                'PÂNICO DE EMERGÊNCIA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.statusNovo, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pressione o botão para enviar a sua localização GPS em tempo real para a Polícia e Central de Operações.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () {
                  widget.controller.triggerCitizenPanicAlert();
                  setState(() {
                    _sosDisparado = true;
                  });
                },
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: AppTheme.statusNovo,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.statusNovo.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 44, color: Colors.white),
                      SizedBox(height: 6),
                      Text(
                        'DISPARAR\nSOS',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 44),
                    const SizedBox(height: 12),
                    const Text(
                      'ALERTA SOS ENVIADO',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'A polícia foi notificada e a sua localização GPS está a ser transmitida em tempo real.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.statusNovo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () {
                        setState(() {
                          _sosDisparado = false;
                        });
                      },
                      child: const Text('CANCELAR / NOVO ALERTA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- ABA 2: DENUNCIAR (SELEÇÃO DE CATEGORIA -> FORMULÁRIO COMPLETO PROFISSIONAL) ---
  Widget _buildDenunciarTab() {
    if (_selectedCategory == null) {
      return _buildSelecaoCategoria();
    }
    return _buildFormularioDenuncia();
  }

  // Passo 1: Selecionar Categoria
  Widget _buildSelecaoCategoria() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Relatar incidente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'A sua denúncia será enviada para análise pela Central.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          const Text(
            'SELECIONE A CATEGORIA DA OCORRÊNCIA',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _incidentCategories.length,
            itemBuilder: (context, index) {
              final cat = _incidentCategories[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['title'];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(cat['title']!),
                          size: 28,
                          color: AppTheme.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Passo 2: Formulário Específico e Profissional da Denúncia
  Widget _buildFormularioDenuncia() {
    final nowStr = '30-Sep-2026 12:05 PM';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão Alterar Categoria
          TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () {
              setState(() {
                _selectedCategory = null;
              });
            },
            icon: const Icon(Icons.arrow_back, size: 16, color: Colors.blueAccent),
            label: const Text('Alterar categoria', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),

          const Text(
            'Relatar incidente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 2),
          const Text(
            'A sua denúncia será enviada para análise pela Central.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),

          // Cartão do Tipo de Ocorrência Selecionado + Prioridade
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TIPO DE OCORRÊNCIA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      _selectedCategory!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    _selectedPriority,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Campo Localização
          const Text('LOCALIZAÇÃO DO INCIDENTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          
          Row(
            children: [
              Checkbox(
                value: _useMyLocation,
                onChanged: (val) {
                  setState(() {
                    _useMyLocation = val ?? true;
                  });
                },
              ),
              const Expanded(
                child: Text('Usar minha localização atual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  side: const BorderSide(color: AppTheme.appBarBg),
                ),
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location, size: 16, color: AppTheme.appBarBg),
                label: Text(
                  _isGettingLocation ? 'Obtendo...' : 'PEGAR LOCALIZAÇÃO EXATA',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.appBarBg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mini Mapa Interativo com Pino
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  // Fundo de Mapa Gráfico
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 36, color: Colors.redAccent),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Text(
                            '📍 Local da Ocorrência\n${_currentLat.toStringAsFixed(4)}, ${_currentLon.toStringAsFixed(4)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Barra de Estado de Localização
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: AppTheme.appBarBg.withValues(alpha: 0.9),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed, size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _locationStatusText,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _locationReferenceController,
            decoration: const InputDecoration(
              labelText: 'Ponto de referência (opcional)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pode arrastar ou clicar no mapa para ajustar a posição exata.',
            style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),

          // Data e Hora
          const Text('DATA E HORA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(nowStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),

          // Descrição
          const Text('DESCRIÇÃO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: _detailsController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Descreva o que aconteceu...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          // Evidências (opcional)
          const Text('EVIDÊNCIAS (OPCIONAL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          
          // Botões para abrir seletor de mídia (Câmara, Galeria ou Ficheiros)
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: () => _openMediaSourceModal('Foto'),
                icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                label: const Text('Foto', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: () => _openMediaSourceModal('Vídeo'),
                icon: const Icon(Icons.videocam, size: 14, color: Colors.white),
                label: const Text('Vídeo', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: () => _openMediaSourceModal('Arquivo'),
                icon: const Icon(Icons.attach_file, size: 14, color: Colors.white),
                label: const Text('Arquivo', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ),
          
          // Lista de Arquivos Anexados
          if (_attachedEvidences.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Ficheiros Anexados:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            Column(
              children: _attachedEvidences.map((ev) {
                IconData evIcon = Icons.insert_drive_file;
                if (ev['type'] == 'Foto') evIcon = Icons.image;
                if (ev['type'] == 'Vídeo') evIcon = Icons.movie;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(evIcon, size: 18, color: AppTheme.appBarBg),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ev['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            Text('Via ${ev['source']} • ${ev['size']}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _attachedEvidences.remove(ev);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 4),
          const Text(
            'Não se coloque em perigo para obter evidências.',
            style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Anónimo
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Quero enviar esta denúncia anonimamente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            subtitle: const Text('A sua identidade não será mostrada a outros utilizadores.', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            value: _isAnonymous,
            onChanged: (val) {
              setState(() {
                _isAnonymous = val ?? false;
              });
            },
          ),
          const SizedBox(height: 16),

          // Botão ENVIAR DENÚNCIA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusNovo,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                widget.controller.submitDenuncia(
                  category: _selectedCategory!,
                  details: _detailsController.text.trim(),
                  isAnonymous: _isAnonymous,
                );
                _detailsController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Denúncia enviada com sucesso para a Central!')),
                );
                setState(() {
                  _selectedCategory = null;
                  _currentIndex = 2; // Ir para Minhas Denúncias
                });
              },
              child: const Text('ENVIAR DENÚNCIA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 12),

          // Aviso de Segurança
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Text(
              'Em situações de risco imediato à vida ou à segurança, utilize o SOS Emergência e procure também os canais oficiais de emergência da sua região.',
              style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // --- ABA 3: MINHAS DENÚNCIAS ---
  Widget _buildMinhasDenunciasTab() {
    final citizenAlerts = widget.controller.alerts.where((a) => a.source == 'denuncia' || a.source == 'cidadao').toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minhas denúncias',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Acompanhe o estado das ocorrências que reportou.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: citizenAlerts.isEmpty
                ? Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.assignment_outlined, size: 40, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text('Ainda não reportou nenhuma ocorrência.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.statusNovo,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: () {
                              setState(() {
                                _currentIndex = 1;
                              });
                            },
                            child: const Text('Denunciar incidente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: citizenAlerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final alert = citizenAlerts[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  alert.category ?? (alert.source == 'cidadao' ? 'Emergência SOS' : 'Denúncia'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    alert.status.labelDono,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                  ),
                                ),
                              ],
                            ),
                            if (alert.details != null && alert.details!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('"${alert.details}"', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
                            ],
                            const SizedBox(height: 6),
                            Text('Reportado às ${alert.createdAt.hour.toString().padLeft(2, '0')}:${alert.createdAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- ABA 4: CONTACTOS DE EMERGÊNCIA ---
  Widget _buildContactosTab() {
    final filteredContacts = _emergencyContacts.where((c) {
      final matchesFilter = _selectedContactFilter == 'Todos' || c['category'] == _selectedContactFilter;
      final matchesSearch = _searchContactQuery.isEmpty || c['name']!.toLowerCase().contains(_searchContactQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contactos de emergência',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Linhas diretas das forças de segurança e resgate.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),

          // Pesquisa
          TextField(
            onChanged: (val) {
              setState(() {
                _searchContactQuery = val;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Pesquisar contacto...',
              prefixIcon: Icon(Icons.search, size: 18),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),

          // Chips de Filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todos', 'Polícia', 'Bombeiros', 'Emergência médica', 'Central de segurança'].map((filter) {
                final isSelected = _selectedContactFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(filter, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppTheme.textPrimary)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1E293B),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedContactFilter = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Lista de Contactos
          Expanded(
            child: ListView.separated(
              itemCount: filteredContacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(contact['phone']!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.phone, size: 14, color: Colors.white),
                        label: const Text('Ligar', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension on Colors {
  static const Color slateBg = Color(0xFF1E293B);
}
