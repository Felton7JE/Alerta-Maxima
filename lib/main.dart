import 'package:flutter/material.dart';
import 'controllers/app_controller.dart';
import 'models/alert_model.dart';
import 'views/theme.dart';
import 'views/login_view.dart';
import 'views/dashboard_view.dart';
import 'views/citizen_view.dart';
import 'views/operator_view.dart';
import 'views/esquadra_view.dart';
import 'views/command_view.dart';
import 'views/dono_view.dart';

void main() {
  runApp(const AlertaSosApp());
}

class AlertaSosApp extends StatefulWidget {
  const AlertaSosApp({super.key});

  @override
  State<AlertaSosApp> createState() => _AlertaSosAppState();
}

class _AlertaSosAppState extends State<AlertaSosApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    _controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget homeScreen;

    final user = _controller.currentUser;
    if (user == null) {
      homeScreen = LoginView(controller: _controller);
    } else {
      switch (user.role) {
        case UserRole.operador:
          homeScreen = OperatorView(controller: _controller);
          break;
        case UserRole.despachante:
          homeScreen = EsquadraView(controller: _controller);
          break;
        case UserRole.comando:
          homeScreen = CommandView(controller: _controller);
          break;
        case UserRole.donoEstabelecimento:
          homeScreen = DonoView(controller: _controller);
          break;
        case UserRole.cidadao:
          homeScreen = CitizenView(controller: _controller);
          break;
        default:
          homeScreen = DashboardView(controller: _controller);
      }
    }

    return MaterialApp(
      title: 'Alerta SOS Invisível',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: homeScreen,
    );
  }
}
