import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/alert_model.dart';
import '../models/management_dtos.dart';

class AppController extends ChangeNotifier {
  // Sessão do Utilizador
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Lista de Esquadras e Organizações Reais da Beira
  final List<Organization> organizations = [
    Organization(id: 'cmd1', name: 'Comando Provincial da PRM - Beira', type: 'comando', lat: -19.8322, lon: 34.8488, address: 'Av. Eduardo Mondlane, Beira'),
    Organization(id: 'esq_a', name: '1ª Esquadra - Baixa / Centro', type: 'esquadra', lat: -19.8336, lon: 34.8511, address: 'Av. Armando Tivane, Beira'),
    Organization(id: 'esq_b', name: '2ª Esquadra - Bairro Macuti', type: 'esquadra', lat: -19.8210, lon: 34.8620, address: 'Av. das Moagens, Macuti, Beira'),
    Organization(id: 'esq_c', name: '3ª Esquadra - Bairro Munhava', type: 'esquadra', lat: -19.8520, lon: 34.8400, address: 'Estrada da Munhava, Beira'),
    Organization(id: 'esq_d', name: '4ª Esquadra - Manga / Inhamízua', type: 'esquadra', lat: -19.7950, lon: 34.8720, address: 'Estrada Nacional N6, Manga, Beira'),
  ];

  // Lista de Hospitais Reais da Beira
  final List<HospitalDTO> hospitals = [
    HospitalDTO(
      id: 'hosp_hcb',
      name: 'Hospital Central da Beira (HCB)',
      phone: '+258 23 322 091',
      emergencyPhone: '+258 84 112 0001',
      address: 'Av. Serpa Pinto, Bairro Central, Beira',
      lat: -19.8315,
      lon: 34.8465,
    ),
    HospitalDTO(
      id: 'hosp_ponta_gea',
      name: 'Centro de Saúde da Ponta Gêa',
      phone: '+258 23 325 500',
      emergencyPhone: '+258 84 325 5000',
      address: 'Av. Martires da Revolução, Ponta Gêa, Beira',
      lat: -19.8410,
      lon: 34.8360,
    ),
    HospitalDTO(
      id: 'hosp_privado',
      name: 'Hospital Privado da Beira',
      phone: '+258 23 313 100',
      emergencyPhone: '+258 84 313 1000',
      address: 'Av. Poder Popular, Beira',
      lat: -19.8280,
      lon: 34.8550,
    ),
    HospitalDTO(
      id: 'hosp_munhava',
      name: 'Centro de Saúde da Munhava',
      phone: '+258 23 340 120',
      emergencyPhone: '+258 84 340 1200',
      address: 'Estrada Principal da Munhava, Beira',
      lat: -19.8505,
      lon: 34.8395,
    ),
    HospitalDTO(
      id: 'hosp_manga',
      name: 'Centro de Saúde da Manga',
      phone: '+258 23 350 090',
      emergencyPhone: '+258 84 350 0900',
      address: 'EN6, Bairro da Manga, Beira',
      lat: -19.7920,
      lon: 34.8710,
    ),
  ];

  // Lista de Bombeiros Reais da Beira
  final List<FireStationDTO> fireStations = [
    FireStationDTO(
      id: 'bomb_beira',
      name: 'Corpo de Salvação Pública / Bombeiros da Beira',
      phone: '+258 23 323 333',
      emergencyPhone: '198',
      address: 'Av. Eduardo Mondlane, Próximo ao Prédio das Finanças, Beira',
      lat: -19.8330,
      lon: 34.8470,
    ),
  ];

  // Obter Hospital mais próximo da emergência
  HospitalDTO getNearestHospital(double lat, double lon) {
    HospitalDTO nearest = hospitals.first;
    double minDistance = double.infinity;

    for (var h in hospitals) {
      final dist = _calculateDistanceKm(lat, lon, h.lat, h.lon);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = h;
      }
    }
    return nearest;
  }

  // Obter Corpo de Bombeiros
  FireStationDTO getNearestFireStation(double lat, double lon) {
    return fireStations.first;
  }

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return 6371 * c; // Raio da Terra em km
  }

  // Registar contacto efetuado ao Hospital
  void contactHospital(AlertItem alert, HospitalDTO hospital) {
    alert.ambulanceRequested = true;
    alert.timeline.add(TimelineItem(
      action: '📞 CONTACTO HOSPITALAR: ${hospital.name} notificado por chamada telefónica (Emergência: ${hospital.emergencyPhone})',
      actorName: _currentUser?.name,
      at: DateTime.now(),
    ));
    notifyListeners();
  }

  // Registar contacto efetuado aos Bombeiros
  void contactFirefighters(AlertItem alert, FireStationDTO fireStation) {
    alert.firefightersRequested = true;
    alert.timeline.add(TimelineItem(
      action: '📞 CONTACTO BOMBEIROS: ${fireStation.name} acionado por chamada telefónica (Linha 198 / Tel: ${fireStation.phone})',
      actorName: _currentUser?.name,
      at: DateTime.now(),
    ));
    notifyListeners();
  }

  // Patrulhas por Esquadra
  late List<Patrol> patrols;

  // Lista de Alertas Ativos
  final List<AlertItem> _alerts = [];
  List<AlertItem> get alerts => List.unmodifiable(_alerts);

  // Alerta Selecionado
  AlertItem? _selectedAlert;
  AlertItem? get selectedAlert => _selectedAlert;

  // Filtro de Histórico
  bool showOnlyActive = true;

  // Temporizadores Mocks
  Timer? _movementTimer;
  Timer? _escalationCheckTimer;

  // Feedback do utilizador
  String? errorMessage;

  AppController() {
    _initPatrols();
    _initMockData();
    _startSimulations();
  }

  void _initPatrols() {
    patrols = [
      Patrol(id: 'p1', name: 'Patrulha Alfa 1', vehicle: 'Viatura 01', status: PatrolStatus.disponivel, organizationId: 'esq_a', lat: -19.8340, lon: 34.8520, teamMembers: 'Sgt. Silva, Ag. Costa', type: PatrolType.policia),
      Patrol(id: 'p2', name: 'Patrulha Alfa 2', vehicle: 'Viatura 02', status: PatrolStatus.disponivel, organizationId: 'esq_a', lat: -19.8310, lon: 34.8480, teamMembers: 'Ag. Langa, Ag. Mabote', type: PatrolType.policia),
      Patrol(id: 'p3', name: 'Patrulha Bravo 1', vehicle: 'Viatura 03', status: PatrolStatus.disponivel, organizationId: 'esq_b', lat: -19.8220, lon: 34.8600, teamMembers: 'Sgt. Tembe, Ag. Cossa', type: PatrolType.policia),
      Patrol(id: 'p4', name: 'Patrulha Bravo 2', vehicle: 'Viatura 04', status: PatrolStatus.indisponivel, organizationId: 'esq_b', lat: -19.8240, lon: 34.8650, teamMembers: 'Ag. Sitoe', type: PatrolType.policia),
      Patrol(id: 'p5', name: 'Patrulha Charlie 1', vehicle: 'Viatura 05', status: PatrolStatus.disponivel, organizationId: 'esq_c', lat: -19.8500, lon: 34.8420, teamMembers: 'Ag. Macamo, Ag. Nhaca', type: PatrolType.policia),
      // Unidades de emergência médica e bombeiros
      Patrol(id: 'amb1', name: 'Ambulância INEM 01', vehicle: 'Ambulância UTI 01', status: PatrolStatus.disponivel, organizationId: 'esq_a', lat: -19.8360, lon: 34.8540, teamMembers: 'Dr. Mendes, Enf. Rita', type: PatrolType.ambulancia),
      Patrol(id: 'bomb1', name: 'Bombeiros Auto-Prancha 01', vehicle: 'Caminhão Tanque 02', status: PatrolStatus.disponivel, organizationId: 'esq_a', lat: -19.8300, lon: 34.8450, teamMembers: 'Cap. Fonseca, B. Mateus', type: PatrolType.bombeiros),
    ];
  }

  void login(String phone, String password) {
    // Logins estáticos de seed conforme a especificação
    if (phone.contains('002')) {
      _currentUser = User(id: 'u2', name: 'Operador 1', phone: phone, role: UserRole.operador);
    } else if (phone.contains('004')) {
      _currentUser = User(id: 'u4', name: 'Despachante Esquadra A', phone: phone, role: UserRole.despachante, organizationId: 'esq_a');
    } else if (phone.contains('005')) {
      _currentUser = User(id: 'u5', name: 'Comandante Silva', phone: phone, role: UserRole.comando, organizationId: 'cmd1');
    } else if (phone.contains('006')) {
      _currentUser = User(id: 'u6', name: 'Dono Comercial (Bomba)', phone: phone, role: UserRole.donoEstabelecimento);
    } else if (phone.contains('007') || phone.contains('cidadao')) {
      _currentUser = User(id: 'u7', name: 'João Mandlate (Cidadão)', phone: phone, role: UserRole.cidadao);
    } else {
      _currentUser = User(id: 'u1', name: 'Operador Geral', phone: phone, role: UserRole.operador);
    }
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _selectedAlert = null;
    notifyListeners();
  }

  void selectAlert(AlertItem? alert) {
    _selectedAlert = alert;
    notifyListeners();
  }

  // --- MODO EMERGÊNCIA (SOS PÂNICO DO CIDADÃO) ---
  void triggerCitizenPanicAlert() {
    if (_currentUser == null) return;

    final uid = 'SOS-${Random().nextInt(9000) + 1000}';
    final now = DateTime.now();
    final pos = Position(
      lat: -19.8350 + (Random().nextDouble() - 0.5) * 0.01,
      lon: 34.8500 + (Random().nextDouble() - 0.5) * 0.01,
      accuracyM: 8,
      capturedAt: now,
      battery: 88,
    );

    final newAlert = AlertItem(
      alertUid: uid,
      status: AlertStatus.novo,
      source: 'cidadao',
      userName: _currentUser!.name,
      userPhone: _currentUser!.phone,
      routing: RoutingInfo(
        responsible: organizations[1], // Esquadra A
        supervision: organizations[0], // Comando
        reserve: organizations[2], // Esquadra B
        responsibleDistanceKm: 1.1,
        reserveDistanceKm: 2.5,
      ),
      lastPosition: pos,
      positions: [pos],
      timeline: [
        TimelineItem(action: 'PÂNICO EMERGÊNCIA: Disparado por ${_currentUser!.name}', at: now),
      ],
      assignedPatrols: [],
      createdAt: now,
      updatedAt: now,
    );

    _alerts.insert(0, newAlert);
    notifyListeners();
  }

  // --- MODO DENÚNCIA (REPORTAR OCORRÊNCIA / TESTEMUNHA) ---
  void submitDenuncia({
    required String category,
    required String details,
    required bool isAnonymous,
  }) {
    final uid = 'DEN-${Random().nextInt(9000) + 1000}';
    final now = DateTime.now();
    final pos = Position(
      lat: -19.8400 + (Random().nextDouble() - 0.5) * 0.01,
      lon: 34.8480 + (Random().nextDouble() - 0.5) * 0.01,
      accuracyM: 15,
      capturedAt: now,
      battery: 92,
    );

    final newAlert = AlertItem(
      alertUid: uid,
      status: AlertStatus.novo,
      source: 'denuncia',
      userName: isAnonymous ? 'Denúncia Anónima' : (_currentUser?.name ?? 'Cidadão'),
      userPhone: isAnonymous ? 'Não divulgado' : (_currentUser?.phone ?? 'N/A'),
      category: category,
      details: details,
      isAnonymous: isAnonymous,
      routing: RoutingInfo(
        responsible: organizations[1],
        supervision: organizations[0],
        reserve: organizations[3],
        responsibleDistanceKm: 1.5,
        reserveDistanceKm: 3.2,
      ),
      lastPosition: pos,
      positions: [pos],
      timeline: [
        TimelineItem(action: 'DENÚNCIA REGISTADA: [$category]', at: now),
      ],
      assignedPatrols: [],
      createdAt: now,
      updatedAt: now,
    );

    _alerts.insert(0, newAlert);
    notifyListeners();
  }

  // Ações do Operador / Despachante
  void assumeAlert(AlertItem alert) {
    if (_currentUser == null) return;
    if (alert.assignedTo != null && alert.assignedTo!.id != _currentUser!.id) {
      errorMessage = 'Este alerta já foi assumido por ${alert.assignedTo!.name}';
      notifyListeners();
      return;
    }

    alert.status = AlertStatus.assumido;
    alert.assignedTo = _currentUser;
    alert.updatedAt = DateTime.now();
    alert.timeline.add(TimelineItem(
      action: 'Alerta assumido por ${_currentUser!.name}',
      actorName: _currentUser!.name,
      at: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateAlertStatus(AlertItem alert, AlertStatus newStatus) {
    alert.status = newStatus;
    alert.updatedAt = DateTime.now();
    alert.timeline.add(TimelineItem(
      action: 'Estado alterado para ${newStatus.label}',
      actorName: _currentUser?.name ?? 'Sistema',
      at: DateTime.now(),
    ));
    notifyListeners();
  }

  void dispatchPatrols(AlertItem alert, List<Patrol> selectedPatrols) {
    for (var patrol in selectedPatrols) {
      patrol.status = PatrolStatus.despachada;
      patrol.currentAlertUid = alert.alertUid;
      patrol.routeWaypoints = null;
      patrol.routeIndex = 0;
      if (!alert.assignedPatrols.contains(patrol)) {
        alert.assignedPatrols.add(patrol);
      }
      _fetchRouteForPatrol(patrol, alert);
    }
    alert.updatedAt = DateTime.now();
    alert.timeline.add(TimelineItem(
      action: '${selectedPatrols.length} patrulha(s) despachada(s)',
      actorName: _currentUser?.name,
      at: DateTime.now(),
    ));
    notifyListeners();
  }

  void _fetchRouteForPatrol(Patrol patrol, AlertItem alert) async {
    if (patrol.lat == null || patrol.lon == null) return;
    try {
      final startLat = patrol.lat!;
      final startLon = patrol.lon!;
      final endLat = alert.lastPosition.lat;
      final endLon = alert.lastPosition.lon;

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final waypoints = coords.map((c) => Position(
          lat: (c[1] as num).toDouble(),
          lon: (c[0] as num).toDouble(),
          accuracyM: 5,
          capturedAt: DateTime.now(),
          battery: 90,
        )).toList();

        if (waypoints.isNotEmpty) {
          patrol.routeWaypoints = waypoints;
          patrol.routeIndex = 0;
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  void requestAmbulance(AlertItem alert) {
    alert.ambulanceRequested = true;
    final amb = patrols.firstWhere(
      (p) => p.type == PatrolType.ambulancia && p.status == PatrolStatus.disponivel,
      orElse: () => Patrol(
        id: 'amb_gen_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Ambulância de Emergência',
        vehicle: 'Ambulância UTI 02',
        status: PatrolStatus.disponivel,
        organizationId: alert.routing.responsible?.id ?? 'esq_a',
        lat: alert.lastPosition.lat + 0.008,
        lon: alert.lastPosition.lon + 0.008,
        teamMembers: 'Equipa Médica de Resgate',
        type: PatrolType.ambulancia,
      ),
    );

    if (!patrols.contains(amb)) {
      patrols.add(amb);
    }
    dispatchPatrols(alert, [amb]);
    alert.timeline.add(TimelineItem(
      action: '🚑 SOCORRO MÉDICO / AMBULÂNCIA ACIONADA',
      actorName: _currentUser?.name,
      at: DateTime.now(),
    ));
    notifyListeners();
  }

  void requestFirefighters(AlertItem alert) {
    alert.firefightersRequested = true;
    final bomb = patrols.firstWhere(
      (p) => p.type == PatrolType.bombeiros && p.status == PatrolStatus.disponivel,
      orElse: () => Patrol(
        id: 'bomb_gen_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Viatura de Bombeiros',
        vehicle: 'Caminhão de Combate a Incêndio',
        status: PatrolStatus.disponivel,
        organizationId: alert.routing.responsible?.id ?? 'esq_a',
        lat: alert.lastPosition.lat - 0.007,
        lon: alert.lastPosition.lon - 0.007,
        teamMembers: 'Equipa de Bombeiros',
        type: PatrolType.bombeiros,
      ),
    );

    if (!patrols.contains(bomb)) {
      patrols.add(bomb);
    }
    dispatchPatrols(alert, [bomb]);
    alert.timeline.add(TimelineItem(
      action: '🚒 CORPO DE BOMBEIROS ACIONADO',
      actorName: _currentUser?.name,
      at: DateTime.now(),
    ));
    notifyListeners();
  }

  void updatePatrolStatus(Patrol patrol, PatrolStatus status, AlertItem alert) {
    patrol.status = status;
    if (status == PatrolStatus.aCaminho && alert.status == AlertStatus.assumido) {
      alert.status = AlertStatus.equipaACaminho;
    } else if (status == PatrolStatus.noLocal && (alert.status == AlertStatus.equipaACaminho || alert.status == AlertStatus.assumido)) {
      alert.status = AlertStatus.equipaNoLocal;
    } else if (status == PatrolStatus.disponivel) {
      patrol.currentAlertUid = null;
      alert.assignedPatrols.remove(patrol);
    }
    alert.updatedAt = DateTime.now();
    notifyListeners();
  }

  void reassignAlert(AlertItem alert, Organization newOrganization) {
    alert.routing = RoutingInfo(
      responsible: newOrganization,
      supervision: organizations.firstWhere((o) => o.type == 'comando'),
      reserve: alert.routing.responsible,
      responsibleDistanceKm: 1.2,
      reserveDistanceKm: alert.routing.responsibleDistanceKm,
    );
    alert.updatedAt = DateTime.now();
    alert.timeline.add(TimelineItem(
      action: 'Reatribuído à ${newOrganization.name} pelo Comando',
      actorName: _currentUser?.name,
      at: DateTime.now(),
    ));
    notifyListeners();
  }

  void togglePatrolAvailability(Patrol patrol) {
    if (patrol.status == PatrolStatus.disponivel) {
      patrol.status = PatrolStatus.indisponivel;
    } else if (patrol.status == PatrolStatus.indisponivel) {
      patrol.status = PatrolStatus.disponivel;
    }
    notifyListeners();
  }

  void addPatrol(Patrol newPatrol) {
    patrols.add(newPatrol);
    notifyListeners();
  }

  void removePatrol(String patrolId) {
    patrols.removeWhere((p) => p.id == patrolId);
    notifyListeners();
  }

  void setPatrolStatus(Patrol patrol, PatrolStatus status) {
    patrol.status = status;
    notifyListeners();
  }

  // Disparar simulador de botão (Demo)
  void triggerDemoButtonAlert() {
    final uid = 'SOS-${Random().nextInt(9000) + 1000}';
    final now = DateTime.now();
    final pos = Position(
      lat: -19.8380,
      lon: 34.8450,
      accuracyM: 5,
      capturedAt: now,
      battery: 95,
      address: 'Bomba de Combustível Total - Maquinino',
    );

    final newAlert = AlertItem(
      alertUid: uid,
      status: AlertStatus.novo,
      source: 'botao',
      establishmentName: 'Bomba de Combustível (Demo)',
      buttonLabel: 'Balcão Caixa 2',
      locationName: 'Bomba de Combustível Total - Maquinino',
      routing: RoutingInfo(
        responsible: organizations[1], // Esquadra A
        supervision: organizations[0], // Comando
        reserve: organizations[2], // Esquadra B
        responsibleDistanceKm: 0.8,
        reserveDistanceKm: 2.1,
      ),
      lastPosition: pos,
      positions: [pos],
      timeline: [
        TimelineItem(action: 'Alerta de Botão Disparado', at: now),
      ],
      assignedPatrols: [],
      createdAt: now,
      updatedAt: now,
    );

    _alerts.insert(0, newAlert);
    _selectedAlert = newAlert;
    notifyListeners();
  }

  // Disparar simulador de SOS de Cidadão (Demo)
  void triggerDemoCitizenAlert() {
    final uid = 'SOS-${Random().nextInt(9000) + 1000}';
    final now = DateTime.now();
    final lat = -19.8360 + (Random().nextDouble() - 0.5) * 0.01;
    final lon = 34.8480 + (Random().nextDouble() - 0.5) * 0.01;

    final pos = Position(
      lat: lat,
      lon: lon,
      accuracyM: 6,
      capturedAt: now,
      battery: 92,
      address: 'Av. Eduardo Mondlane, Beira',
    );

    final newAlert = AlertItem(
      alertUid: uid,
      status: AlertStatus.novo,
      source: 'cidadao',
      userName: 'Carlos Nhamposse (Demo)',
      userPhone: '+258 84 555 6677',
      locationName: 'Av. Eduardo Mondlane, Beira',
      routing: RoutingInfo(
        responsible: organizations[1], // Esquadra A
        supervision: organizations[0], // Comando
        reserve: organizations[2], // Esquadra B
        responsibleDistanceKm: 0.9,
        reserveDistanceKm: 2.3,
      ),
      lastPosition: pos,
      positions: [pos],
      timeline: [
        TimelineItem(action: 'Alerta SOS de Cidadão Disparado', at: now),
      ],
      assignedPatrols: [],
      createdAt: now,
      updatedAt: now,
    );

    _alerts.insert(0, newAlert);
    _selectedAlert = newAlert;
    notifyListeners();
  }

  // Alternar rapidamente de perfil (Para Apresentação/Demo)
  void switchUserRole(UserRole role) {
    switch (role) {
      case UserRole.operador:
        _currentUser = User(id: 'u2', name: 'Operador 1', phone: '+258840000002', role: UserRole.operador);
        break;
      case UserRole.despachante:
        _currentUser = User(id: 'u4', name: 'Despachante Esquadra A', phone: '+258840000004', role: UserRole.despachante, organizationId: 'esq_a');
        break;
      case UserRole.comando:
        _currentUser = User(id: 'u5', name: 'Comandante Silva', phone: '+258840000005', role: UserRole.comando, organizationId: 'cmd1');
        break;
      case UserRole.donoEstabelecimento:
        _currentUser = User(id: 'u6', name: 'Dono Comercial (Bomba)', phone: '+258840000006', role: UserRole.donoEstabelecimento);
        break;
      case UserRole.cidadao:
        _currentUser = User(id: 'u7', name: 'João Mandlate (Cidadão)', phone: '+258840000007', role: UserRole.cidadao);
        break;
      default:
        _currentUser = User(id: 'u2', name: 'Operador 1', phone: '+258840000002', role: UserRole.operador);
    }
    notifyListeners();
  }

  // --- Inicialização Mock e Simulação ---
  void _initMockData() {
    final now = DateTime.now();

    final pos1 = Position(lat: -19.83365, lon: 34.85107, accuracyM: 12, capturedAt: now, battery: 64, address: 'Av. Armando Tivane, Bairro Central, Beira');
    final pos2 = Position(lat: -19.82100, lon: 34.86200, accuracyM: 8, capturedAt: now.subtract(const Duration(minutes: 10)), battery: 80, address: 'Av. das Moagens, Bairro Macuti, Beira');

    _alerts.addAll([
      AlertItem(
        alertUid: 'A7K29Q',
        status: AlertStatus.novo,
        source: 'cidadao',
        userName: 'Ana Maria',
        userPhone: '+258841234567',
        locationName: 'Av. Armando Tivane, Bairro Central, Beira',
        routing: RoutingInfo(
          responsible: organizations[1],
          supervision: organizations[0],
          reserve: organizations[2],
          responsibleDistanceKm: 1.4,
          reserveDistanceKm: 2.9,
        ),
        lastPosition: pos1,
        positions: [pos1],
        timeline: [TimelineItem(action: 'Alerta SOS Criado', at: now)],
        assignedPatrols: [],
        createdAt: now,
        updatedAt: now,
      ),
      AlertItem(
        alertUid: 'K3M9PX',
        status: AlertStatus.assumido,
        source: 'botao',
        establishmentName: 'Farmácia Central',
        buttonLabel: 'Caixa Principal',
        locationName: 'Av. das Moagens, Bairro Macuti, Beira',
        assignedTo: User(id: 'u2', name: 'Operador 1', phone: '+258840000002', role: UserRole.operador),
        routing: RoutingInfo(
          responsible: organizations[1],
          supervision: organizations[0],
          reserve: organizations[3],
          responsibleDistanceKm: 0.5,
          reserveDistanceKm: 3.1,
        ),
        lastPosition: pos2,
        positions: [pos2],
        timeline: [
          TimelineItem(action: 'Alerta Criado', at: now.subtract(const Duration(minutes: 10))),
          TimelineItem(action: 'Assumido por Operador 1', at: now.subtract(const Duration(minutes: 9))),
        ],
        assignedPatrols: [],
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 9)),
      ),
    ]);
  }

  // --- DADOS E MÉTODOS PARA GESTÃO DE UTILIZADORES ---
  final List<UserDTO> _systemUsers = [
    UserDTO(id: 'u1', name: 'Operador Geral', phone: '+258 84 000 0001', role: UserRole.operador, lastLoginAt: DateTime.now().subtract(const Duration(minutes: 15))),
    UserDTO(id: 'u2', name: 'Operador 1', phone: '+258 84 000 0002', role: UserRole.operador, lastLoginAt: DateTime.now().subtract(const Duration(hours: 1))),
    UserDTO(id: 'u4', name: 'Despachante Esquadra A', phone: '+258 84 000 0004', role: UserRole.despachante, organizationId: 'esq_a', organizationName: 'Esquadra A - Centro', lastLoginAt: DateTime.now().subtract(const Duration(minutes: 5))),
    UserDTO(id: 'u5', name: 'Comandante Silva', phone: '+258 84 000 0005', role: UserRole.comando, organizationId: 'cmd1', organizationName: 'Comando Central (Beira)', lastLoginAt: DateTime.now().subtract(const Duration(hours: 3))),
    UserDTO(id: 'u6', name: 'Dono Comercial (Bomba)', phone: '+258 84 000 0006', role: UserRole.donoEstabelecimento, lastLoginAt: DateTime.now().subtract(const Duration(days: 1))),
    UserDTO(id: 'u7', name: 'João Mandlate', phone: '+258 84 000 0007', role: UserRole.cidadao, lastLoginAt: DateTime.now().subtract(const Duration(minutes: 40))),
  ];

  List<UserDTO> get systemUsers => List.unmodifiable(_systemUsers);

  void addUser(UserDTO user) {
    _systemUsers.add(user);
    notifyListeners();
  }

  void toggleUserStatus(String userId) {
    final index = _systemUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _systemUsers[index];
      _systemUsers[index] = UserDTO(
        id: user.id,
        name: user.name,
        phone: user.phone,
        role: user.role,
        organizationId: user.organizationId,
        organizationName: user.organizationName,
        isActive: !user.isActive,
        lastLoginAt: user.lastLoginAt,
      );
      notifyListeners();
    }
  }

  // --- DADOS E MÉTODOS PARA GESTÃO DE ESTABELECIMENTOS ---
  final List<EstablishmentDTO> _establishments = [
    EstablishmentDTO(
      id: 'est1',
      name: 'Bomba Total - Maquinino',
      category: 'Bomba de Combustível',
      address: 'Av. Armando Tivane, Beira',
      ownerName: 'Dono Comercial (Bomba)',
      ownerPhone: '+258 84 000 0006',
      responsibleEsquadraId: 'esq_a',
      responsibleEsquadraName: 'Esquadra A - Centro',
      activePanicButtons: 3,
      lat: -19.8355,
      lon: 34.8490,
      isPanicActive: false,
    ),
    EstablishmentDTO(
      id: 'est2',
      name: 'Supermercado Shoprite Beira',
      category: 'Supermercado',
      address: 'Av. Eduardo Mondlane, Beira',
      ownerName: 'Gerência Shoprite',
      ownerPhone: '+258 84 111 2233',
      responsibleEsquadraId: 'esq_a',
      responsibleEsquadraName: 'Esquadra A - Centro',
      activePanicButtons: 6,
      lat: -19.8320,
      lon: 34.8530,
      isPanicActive: false,
    ),
    EstablishmentDTO(
      id: 'est3',
      name: 'BOM / Millennium bim - Macuti',
      category: 'Banco / Agência',
      address: 'Av. das Moagens, Macuti',
      ownerName: 'Segurança BIM',
      ownerPhone: '+258 84 333 4455',
      responsibleEsquadraId: 'esq_b',
      responsibleEsquadraName: 'Esquadra B - Macuti',
      activePanicButtons: 4,
      lat: -19.8225,
      lon: 34.8610,
      isPanicActive: false,
    ),
    EstablishmentDTO(
      id: 'est4',
      name: 'Farmácia Central Munhava',
      category: 'Farmácia',
      address: 'Estrada da Munhava, Beira',
      ownerName: 'Dr. Alberto Namburete',
      ownerPhone: '+258 84 999 8877',
      responsibleEsquadraId: 'esq_c',
      responsibleEsquadraName: 'Esquadra C - Munhava',
      activePanicButtons: 2,
      lat: -19.8510,
      lon: 34.8415,
      isPanicActive: false,
    ),
  ];

  List<EstablishmentDTO> get establishments => List.unmodifiable(_establishments);

  void addEstablishment(EstablishmentDTO est) {
    _establishments.add(est);
    notifyListeners();
  }

  // --- MÉTODOS PARA METRICAS DA DASHBOARD ---
  DashboardMetrics getDashboardMetrics() {
    final activeCount = _alerts.where((a) => a.status != AlertStatus.resolvido && a.status != AlertStatus.falsoAlarme).length;
    final resolvedCount = _alerts.where((a) => a.status == AlertStatus.resolvido).length;
    final falseCount = _alerts.where((a) => a.status == AlertStatus.falsoAlarme).length;
    final activePatrols = patrols.where((p) => p.status == PatrolStatus.disponivel || p.status == PatrolStatus.aCaminho || p.status == PatrolStatus.noLocal).length;

    Map<String, int> categories = {};
    Map<String, int> esquadras = {};

    for (var a in _alerts) {
      final cat = a.category ?? (a.source == 'cidadao' ? 'Pânico SOS' : 'Outro');
      categories[cat] = (categories[cat] ?? 0) + 1;

      final esqName = a.routing.responsible?.name ?? 'Não atribuído';
      esquadras[esqName] = (esquadras[esqName] ?? 0) + 1;
    }

    return DashboardMetrics(
      totalAlertsToday: _alerts.length,
      activeAlertsCount: activeCount,
      resolvedTodayCount: resolvedCount,
      falseAlertsCount: falseCount,
      avgResponseTimeMinutes: 4.5,
      activePatrolsCount: activePatrols,
      alertsByCategory: categories,
      alertsByEsquadra: esquadras,
    );
  }

  // --- MÉTODOS PARA RELATÓRIOS ---
  List<ReportSummaryItem> getReportSummary() {
    final total = _alerts.isEmpty ? 1 : _alerts.length;
    final resolvidos = _alerts.where((a) => a.status == AlertStatus.resolvido).length;
    final falsoAlarme = _alerts.where((a) => a.status == AlertStatus.falsoAlarme).length;
    final emAndamento = _alerts.where((a) => a.status != AlertStatus.resolvido && a.status != AlertStatus.falsoAlarme).length;

    return [
      ReportSummaryItem(title: 'Ocorrências Resolvidas', count: resolvidos, percentage: (resolvidos / total) * 100, statusLabel: 'Concluído'),
      ReportSummaryItem(title: 'Em Atendimento / Andamento', count: emAndamento, percentage: (emAndamento / total) * 100, statusLabel: 'Ativo'),
      ReportSummaryItem(title: 'Falsos Alarmes', count: falsoAlarme, percentage: (falsoAlarme / total) * 100, statusLabel: 'Falso Alarme'),
    ];
  }

  void _startSimulations() {
    _movementTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      bool changed = false;

      // 1. Movimento apenas para Alertas de Cidadão / Denúncia Mobile (Botões de Estabelecimento permanecem 100% ESTÁTICOS)
      for (var alert in _alerts) {
        if (alert.source == 'cidadao' || alert.source == 'denuncia') {
          if (alert.status == AlertStatus.novo || alert.status == AlertStatus.assumido || alert.status == AlertStatus.equipaACaminho) {
            final randLat = (Random().nextDouble() - 0.5) * 0.0003;
            final randLon = (Random().nextDouble() - 0.5) * 0.0003;
            final newPos = Position(
              lat: alert.lastPosition.lat + randLat,
              lon: alert.lastPosition.lon + randLon,
              accuracyM: 8,
              capturedAt: DateTime.now(),
              battery: max(1, alert.lastPosition.battery - 1),
              address: alert.locationName ?? alert.lastPosition.address,
            );
            alert.lastPosition = newPos;
            alert.positions.add(newPos);
            alert.updatedAt = DateTime.now();
            changed = true;
          }
        }
      }

      // 2. Movimento Progressivo das Patrulhas Despachadas Seguindo as Estradas (Waypoints)
      for (var alert in _alerts) {
        for (var patrol in alert.assignedPatrols) {
          if (patrol.lat != null && patrol.lon != null && (patrol.status == PatrolStatus.despachada || patrol.status == PatrolStatus.aCaminho)) {
            final waypoints = patrol.routeWaypoints;

            if (waypoints != null && waypoints.isNotEmpty) {
              // Avançar pelos pontos reais da estrada trazidos pelo OSRM
              if (patrol.routeIndex < waypoints.length - 1) {
                patrol.routeIndex += 1;
                final nextPoint = waypoints[patrol.routeIndex];
                patrol.lat = nextPoint.lat;
                patrol.lon = nextPoint.lon;
                changed = true;
              } else {
                // Chegou ao final da estrada: estaciona com offset tático de 30m ao lado do alerta
                patrol.lat = alert.lastPosition.lat + 0.0003;
                patrol.lon = alert.lastPosition.lon + 0.0003;
                patrol.status = PatrolStatus.noLocal;

                if (alert.status == AlertStatus.equipaACaminho || alert.status == AlertStatus.assumido) {
                  alert.status = AlertStatus.equipaNoLocal;
                  alert.timeline.add(TimelineItem(
                    action: '${patrol.name} chegou ao local da ocorrência (Estacionada no perímetro)',
                    at: DateTime.now(),
                  ));
                }
                changed = true;
              }
            } else {
              // Fallback se ainda a carregar rota da estrada
              final targetLat = alert.lastPosition.lat;
              final targetLon = alert.lastPosition.lon;
              final dLat = targetLat - patrol.lat!;
              final dLon = targetLon - patrol.lon!;

              if (dLat.abs() > 0.0005 || dLon.abs() > 0.0005) {
                patrol.lat = patrol.lat! + (dLat * 0.15);
                patrol.lon = patrol.lon! + (dLon * 0.15);
                changed = true;
              }
            }
          }
        }
      }

      if (changed) {
        notifyListeners();
      }
    });

    _escalationCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      for (var alert in _alerts) {
        if (alert.status == AlertStatus.novo && !alert.escalated) {
          if (now.difference(alert.createdAt).inSeconds >= 30) {
            alert.escalated = true;
            alert.timeline.add(TimelineItem(
              action: 'ESCALADA: Sem resposta a tempo da esquadra responsável',
              at: now,
            ));
            notifyListeners();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _escalationCheckTimer?.cancel();
    super.dispose();
  }
}

