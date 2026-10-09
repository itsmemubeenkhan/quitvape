import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/paywall_screen.dart';
import 'package:quitvape/main.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    await QuitService.setUserName(name);
    await QuitService.setUserEmail(_emailController.text.trim());
    await QuitService.setUserWeight(double.tryParse(_weightController.text.trim()) ?? 0);
    await QuitService.setUserHeight(double.tryParse(_heightController.text.trim()) ?? 0);

    if (mounted) {
      // Go to paywall, then to main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen(isOnboarding: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppStyle.gradientEmerald,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Text('👤', style: TextStyle(fontSize: 36))),
              ),
              const SizedBox(height: 24),
              const Text(
                'Let\'s get to\nknow you! 👋',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your AI Doctor will personalize advice based on your profile.',
                style: TextStyle(color: AppStyle.textDim, fontSize: 15),
              ),
              const SizedBox(height: 32),
              _buildField('Your Name *', 'e.g. Ahmed Khan', _nameController, TextInputType.name, Icons.person_rounded),
              const SizedBox(height: 16),
              _buildField('Email', 'e.g. ahmed@email.com', _emailController, TextInputType.emailAddress, Icons.email_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Weight (kg)', 'e.g. 70', _weightController, TextInputType.number, Icons.monitor_weight_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Height (cm)', 'e.g. 175', _heightController, TextInputType.number, Icons.height_rounded)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppStyle.gradientEmerald,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppStyle.emerald.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Continue →',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '🔒 Your data stays on your device',
                  style: TextStyle(color: AppStyle.textFaint, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, TextInputType type, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppStyle.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E2A24)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppStyle.textFaint, fontSize: 15),
              prefixIcon: Icon(icon, color: AppStyle.emerald, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
