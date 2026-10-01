// --- MODELS ---

enum AlertStatus {
  novo,
  assumido,
  equipaACaminho,
  equipaNoLocal,
  resolvido,
  falsoAlarme,
  canceladoPeloUtilizador,
  expirado,
}

extension AlertStatusExtension on AlertStatus {
  String get label {
    switch (this) {
      case AlertStatus.novo:
        return 'NOVO';
      case AlertStatus.assumido:
        return 'ASSUMIDO';
      case AlertStatus.equipaACaminho:
        return 'EQUIPA A CAMINHO';
      case AlertStatus.equipaNoLocal:
        return 'EQUIPA NO LOCAL';
      case AlertStatus.resolvido:
        return 'RESOLVIDO';
      case AlertStatus.falsoAlarme:
        return 'FALSO ALARME';
      case AlertStatus.canceladoPeloUtilizador:
        return 'CANCELADO';
      case AlertStatus.expirado:
        return 'EXPIRADO';
    }
  }

  String get labelDono {
    switch (this) {
      case AlertStatus.novo:
        return 'Polícia notificada';
      case AlertStatus.assumido:
        return 'A polícia está a tratar do caso';
      case AlertStatus.equipaACaminho:
        return 'Equipa a caminho';
      case AlertStatus.equipaNoLocal:
        return 'Equipa no local';
      case AlertStatus.resolvido:
        return 'Situação resolvida';
      case AlertStatus.falsoAlarme:
        return 'Marcado como falso alarme';
      case AlertStatus.canceladoPeloUtilizador:
        return 'Cancelado pelo utilizador';
      case AlertStatus.expirado:
        return 'Sem resposta';
    }
  }
}

enum PatrolStatus {
  disponivel,
  despachada,
  aCaminho,
  noLocal,
  indisponivel,
}

extension PatrolStatusExtension on PatrolStatus {
  String get label {
    switch (this) {
      case PatrolStatus.disponivel:
        return 'Disponível';
      case PatrolStatus.despachada:
        return 'Despachada';
      case PatrolStatus.aCaminho:
        return 'A caminho';
      case PatrolStatus.noLocal:
        return 'No local';
      case PatrolStatus.indisponivel:
        return 'Indisponível';
    }
  }
}

enum UserRole {
  operador,
  despachante,
  comando,
  donoEstabelecimento,
  cidadao,
  admin,
}

class User {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? organizationId;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.organizationId,
  });
}

class Position {
  final double lat;
  final double lon;
  final double accuracyM;
  final DateTime capturedAt;
  final int battery;
  final String channel;
  final String? address;

  Position({
    required this.lat,
    required this.lon,
    required this.accuracyM,
    required this.capturedAt,
    required this.battery,
    this.channel = 'internet',
    this.address,
  });
}

class Organization {
  final String id;
  final String name;
  final String type; // 'esquadra' ou 'comando'
  final double lat;
  final double lon;
  final String? address;

  Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    this.address,
  });
}

class RoutingInfo {
  final Organization? responsible;
  final Organization? supervision;
  final Organization? reserve;
  final double? responsibleDistanceKm;
  final double? reserveDistanceKm;

  RoutingInfo({
    this.responsible,
    this.supervision,
    this.reserve,
    this.responsibleDistanceKm,
    this.reserveDistanceKm,
  });
}

enum PatrolType {
  policia,
  ambulancia,
  bombeiros,
}

extension PatrolTypeExtension on PatrolType {
  String get label {
    switch (this) {
      case PatrolType.policia:
        return 'Polícia';
      case PatrolType.ambulancia:
        return 'Ambulância';
      case PatrolType.bombeiros:
        return 'Bombeiros';
    }
  }
}

class Patrol {
  final String id;
  final String name;
  final String? vehicle;
  PatrolStatus status;
  final String organizationId;
  String? currentAlertUid;
  double? lat;
  double? lon;
  String? teamMembers;
  List<Position>? routeWaypoints;
  int routeIndex = 0;
  PatrolType type;

  Patrol({
    required this.id,
    required this.name,
    this.vehicle,
    required this.status,
    required this.organizationId,
    this.currentAlertUid,
    this.lat,
    this.lon,
    this.teamMembers,
    this.routeWaypoints,
    this.routeIndex = 0,
    this.type = PatrolType.policia,
  });
}

class TimelineItem {
  final String action;
  final String? actorName;
  final DateTime at;

  TimelineItem({
    required this.action,
    this.actorName,
    required this.at,
  });
}

class AlertItem {
  final String alertUid;
  AlertStatus status;
  bool escalated;
  final String source; // 'cidadao', 'denuncia', 'botao'
  final String? userName;
  final String? userPhone;
  final String? establishmentName;
  final String? buttonLabel;
  final String? category; // ex: Assalto, Violência Doméstica, Suspeito, Outros
  final String? details; // Descrição opcional da denúncia
  final bool isAnonymous;
  String? locationName; // Endereço geocodificado
  bool ambulanceRequested;
  bool firefightersRequested;
  RoutingInfo routing;
  User? assignedTo;
  Position lastPosition;
  final List<Position> positions;
  final List<TimelineItem> timeline;
  final List<Patrol> assignedPatrols;
  final DateTime createdAt;
  DateTime updatedAt;

  AlertItem({
    required this.alertUid,
    required this.status,
    this.escalated = false,
    required this.source,
    this.userName,
    this.userPhone,
    this.establishmentName,
    this.buttonLabel,
    this.category,
    this.details,
    this.isAnonymous = false,
    this.locationName,
    this.ambulanceRequested = false,
    this.firefightersRequested = false,
    required this.routing,
    this.assignedTo,
    required this.lastPosition,
    required this.positions,
    required this.timeline,
    required this.assignedPatrols,
    required this.createdAt,
    required this.updatedAt,
  });
}
