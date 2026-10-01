import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../models/alert_model.dart';

class LoginView extends StatefulWidget {
  final AppController controller;

  const LoginView({super.key, required this.controller});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController(text: '+258840000002');
  final _passController = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ALERTA SOS INVISÍVEL',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
              ),
              const SizedBox(height: 4),
              const Text(
                'Painel de Gestão e Controlo de Emergências',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Palavra-passe',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  widget.controller.login(_phoneController.text, _passController.text);
                },
                child: const Text('ENTRAR NO SISTEMA', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Contas de Teste (Clique rápido):', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildQuickLoginChip('Operador', '+258840000002'),
                  _buildQuickLoginChip('Esquadra', '+258840000004'),
                  _buildQuickLoginChip('Comando', '+258840000005'),
                  _buildQuickLoginChip('Dono', '+258840000006'),
                  _buildQuickLoginChip('Cidadão', '+258840000007'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginChip(String label, String phone) {
    return InkWell(
      onTap: () {
        _phoneController.text = phone;
        widget.controller.login(phone, '123456');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}
