// --- DTOs e MODELOS PARA DASHBOARD, UTILIZADORES E RELATÓRIOS ---

import 'alert_model.dart';

// DTO / Modelo de Métrica da Dashboard
class DashboardMetrics {
  final int totalAlertsToday;
  final int activeAlertsCount;
  final int resolvedTodayCount;
  final int falseAlertsCount;
  final double avgResponseTimeMinutes;
  final int activePatrolsCount;
  final Map<String, int> alertsByCategory;
  final Map<String, int> alertsByEsquadra;

  DashboardMetrics({
    required this.totalAlertsToday,
    required this.activeAlertsCount,
    required this.resolvedTodayCount,
    required this.falseAlertsCount,
    required this.avgResponseTimeMinutes,
    required this.activePatrolsCount,
    required this.alertsByCategory,
    required this.alertsByEsquadra,
  });
}

// DTO para Gestão de Utilizadores
class UserDTO {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? organizationId;
  final String? organizationName;
  final bool isActive;
  final DateTime lastLoginAt;

  UserDTO({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.organizationId,
    this.organizationName,
    this.isActive = true,
    required this.lastLoginAt,
  });
}

// DTO para Relatórios e Filtros de Pesquisa
class ReportFilterDTO {
  final DateTime startDate;
  final DateTime endDate;
  final AlertStatus? status;
  final String? organizationId;
  final String? category;

  ReportFilterDTO({
    required this.startDate,
    required this.endDate,
    this.status,
    this.organizationId,
    this.category,
  });
}

// DTO para Item de Relatório Consolidado
class ReportSummaryItem {
  final String title;
  final int count;
  final double percentage;
  final String statusLabel;

  ReportSummaryItem({
    required this.title,
    required this.count,
    required this.percentage,
    required this.statusLabel,
  });
}

// DTO para Gestão de Estabelecimentos Comerciais
class EstablishmentDTO {
  final String id;
  final String name;
  final String category; // ex: Bomba de Combustível, Banco, Loja, Supermercado
  final String address;
  final String ownerName;
  final String ownerPhone;
  final String responsibleEsquadraId;
  final String responsibleEsquadraName;
  final int activePanicButtons;
  final double lat;
  final double lon;
  final bool isPanicActive;

  EstablishmentDTO({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.ownerName,
    required this.ownerPhone,
    required this.responsibleEsquadraId,
    required this.responsibleEsquadraName,
    required this.activePanicButtons,
    required this.lat,
    required this.lon,
    this.isPanicActive = false,
  });
}

// DTO para Hospitais e Centros de Saúde da Beira
class HospitalDTO {
  final String id;
  final String name;
  final String phone;
  final String emergencyPhone;
  final String address;
  final double lat;
  final double lon;

  HospitalDTO({
    required this.id,
    required this.name,
    required this.phone,
    required this.emergencyPhone,
    required this.address,
    required this.lat,
    required this.lon,
  });
}

// DTO para Corpo de Bombeiros da Beira
class FireStationDTO {
  final String id;
  final String name;
  final String phone;
  final String emergencyPhone;
  final String address;
  final double lat;
  final double lon;

  FireStationDTO({
    required this.id,
    required this.name,
    required this.phone,
    required this.emergencyPhone,
    required this.address,
    required this.lat,
    required this.lon,
  });
}

