import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../controllers/app_controller.dart';
import '../../models/alert_model.dart';
import '../theme.dart';

class MapWidget extends StatefulWidget {
  final AppController controller;

  const MapWidget({super.key, required this.controller});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  final Map<String, List<LatLng>> _routeCache = {};

  Future<List<LatLng>> _getRoutePoints(LatLng start, LatLng end) async {
    final cacheKey = '${start.latitude.toStringAsFixed(4)},${start.longitude.toStringAsFixed(4)}_${end.latitude.toStringAsFixed(4)},${end.longitude.toStringAsFixed(4)}';
    if (_routeCache.containsKey(cacheKey)) {
      return _routeCache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final points = coords.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
        _routeCache[cacheKey] = points;
        return points;
      }
    } catch (_) {
      // Fallback em linha direta se sem internet / timeout
    }
    return [start, end];
  }

  Color _getStatusColor(AlertStatus status) {
    switch (status) {
      case AlertStatus.novo:
        return AppTheme.statusNovo;
      case AlertStatus.assumido:
        return AppTheme.statusAssumido;
      case AlertStatus.equipaACaminho:
        return AppTheme.statusEquipaACaminho;
      case AlertStatus.equipaNoLocal:
        return AppTheme.statusEquipaNoLocal;
      case AlertStatus.resolvido:
        return AppTheme.statusResolvido;
      case AlertStatus.falsoAlarme:
        return AppTheme.statusFalsoAlarme;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final selectedAlert = controller.selectedAlert;

    // Coordenadas centrais da Cidade da Beira
    final initialCenter = const LatLng(-19.8436, 34.8389);

    return Container(
      color: const Color(0xFFE2E8F0),
      child: Stack(
        children: [
          // Mapa Interativo OpenStreetMap via flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedAlert != null
                  ? LatLng(selectedAlert.lastPosition.lat, selectedAlert.lastPosition.lon)
                  : initialCenter,
              initialZoom: 13.5,
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.blindspot.app',
              ),

              // PolylineLayer - Desenha Linhas de Trajeto/Direção Seguindo as Estradas Reais (OSRM)
              for (var alert in controller.alerts)
                for (var patrol in alert.assignedPatrols)
                  if (patrol.lat != null && patrol.lon != null)
                    FutureBuilder<List<LatLng>>(
                      future: _getRoutePoints(
                        LatLng(patrol.lat!, patrol.lon!),
                        LatLng(alert.lastPosition.lat, alert.lastPosition.lon),
                      ),
                      builder: (context, snapshot) {
                        final points = snapshot.data ?? [
                          LatLng(patrol.lat!, patrol.lon!),
                          LatLng(alert.lastPosition.lat, alert.lastPosition.lon),
                        ];
                        final isSelected = selectedAlert?.alertUid == alert.alertUid;

                        return PolylineLayer(
                          polylines: [
                            Polyline(
                              points: points,
                              strokeWidth: isSelected ? 4.5 : 3.0,
                              color: isSelected
                                  ? Colors.orange.shade800
                                  : Colors.blue.shade700,
                            ),
                          ],
                        );
                      },
                    ),

              MarkerLayer(
                markers: [
                  // Marcadores de Esquadras / Organizações
                  ...controller.organizations.map((org) {
                    return Marker(
                      point: LatLng(org.lat, org.lon),
                      width: 120,
                      height: 50,
                      child: Tooltip(
                        message: org.name,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.shade700,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                ],
                              ),
                              child: Text(
                                org.name,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.local_police, color: Colors.blueAccent, size: 24),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Marcadores de Patrulhas/Viaturas/Ambulâncias/Bombeiros no Terreno
                  ...controller.patrols.where((p) => p.lat != null && p.lon != null).map((patrol) {
                    final isAvail = patrol.status == PatrolStatus.disponivel;
                    final isBusy = patrol.status == PatrolStatus.despachada || patrol.status == PatrolStatus.aCaminho || patrol.status == PatrolStatus.noLocal;

                    Color color;
                    IconData iconData;

                    if (patrol.type == PatrolType.ambulancia) {
                      color = isAvail ? Colors.red.shade600 : Colors.red.shade900;
                      iconData = Icons.medical_services;
                    } else if (patrol.type == PatrolType.bombeiros) {
                      color = isAvail ? Colors.deepOrange : Colors.red.shade800;
                      iconData = Icons.local_fire_department;
                    } else {
                      color = isAvail ? Colors.green.shade700 : (isBusy ? Colors.orange.shade800 : Colors.grey);
                      iconData = Icons.directions_car;
                    }

                    return Marker(
                      point: LatLng(patrol.lat!, patrol.lon!),
                      width: 110,
                      height: 44,
                      child: Tooltip(
                        message: '${patrol.name} (${patrol.type.label})\nVeículo: ${patrol.vehicle ?? "N/A"}\nStatus: ${patrol.status.label}\nEquipa: ${patrol.teamMembers ?? "N/A"}',
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                patrol.name,
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(iconData, color: color, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Marcadores de Alertas Ativos
                  ...controller.alerts.map((alert) {
                    final isSelected = selectedAlert?.alertUid == alert.alertUid;
                    final color = _getStatusColor(alert.status);

                    return Marker(
                      point: LatLng(alert.lastPosition.lat, alert.lastPosition.lon),
                      width: isSelected ? 50 : 40,
                      height: isSelected ? 50 : 40,
                      child: GestureDetector(
                        onTap: () {
                          controller.selectAlert(alert);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : color,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 10, spreadRadius: 3)]
                                : null,
                          ),
                          child: Icon(
                            Icons.warning_rounded,
                            color: color,
                            size: isSelected ? 28 : 22,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Legenda no canto inferior esquerdo
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.border),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('LEGENDA DO MAPA (OPENSTREETMAP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  _buildLegendItem('Novo Alerta', AppTheme.statusNovo),
                  _buildLegendItem('Assumido', AppTheme.statusAssumido),
                  _buildLegendItem('Equipa a Caminho', AppTheme.statusEquipaACaminho),
                  _buildLegendItem('Equipa no Local', AppTheme.statusEquipaNoLocal),
                  _buildLegendItem('Patrulhas no Terreno', Colors.green.shade700),
                  _buildLegendItem('Rota de Despacho', Colors.orange.shade800),
                  _buildLegendItem('Esquadras', Colors.blueAccent),
                ],
              ),
            ),
          ),

          // Painel do Alerta Selecionado no canto superior direito
          if (selectedAlert != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.panelBg.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(
                          'SELECIONADO: #${selectedAlert.alertUid}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'GPS: ${selectedAlert.lastPosition.lat.toStringAsFixed(4)}, ${selectedAlert.lastPosition.lon.toStringAsFixed(4)} (±${selectedAlert.lastPosition.accuracyM.toInt()}m)',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
