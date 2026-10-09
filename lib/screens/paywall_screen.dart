import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quitvape/services/quit_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  bool _loading = true;

  static const Set<String> _productIds = {
    'quitvape_weekly',
    'quitvape_monthly',
    'quitvape_yearly',
  };

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    _available = await _iap.isAvailable();
    if (_available) {
      final response = await _iap.queryProductDetails(_productIds);
      setState(() {
        _products = response.productDetails;
        _loading = false;
      });
      _iap.purchaseStream.listen(_onPurchaseUpdate);
    } else {
      setState(() => _loading = false);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (var p in purchases) {
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        QuitService.setPremium(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Welcome to Premium!')),
          );
          Navigator.pop(context);
        }
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  void _buy(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: param);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ QuitVape Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('👑', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Quit Faster with Premium',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildBenefit('📊', 'Advanced Statistics', 'Detailed charts & insights'),
            _buildBenefit('🎯', 'Personal Goals', 'Set custom milestones'),
            _buildBenefit('🔔', 'Smart Reminders', 'Motivational notifications'),
            _buildBenefit('🚫', 'No Ads', 'Clean, focused experience'),
            _buildBenefit('☁️', 'Cloud Backup', 'Never lose your progress'),
            const SizedBox(height: 32),
            if (_loading)
              const CircularProgressIndicator()
            else if (_products.isEmpty)
              const Text('Products not available yet.\nCreate subscriptions in Play Console first!',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
            else
              ..._products.map((p) => _buildProductCard(p)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _iap.restorePurchases(),
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(desc, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductDetails p) {
    final isYearly = p.id.contains('yearly');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: isYearly ? const Color(0xFF10B981) : Colors.grey.shade300, width: isYearly ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
        color: isYearly ? const Color(0xFF10B981).withOpacity(0.05) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isYearly)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Text(p.description),
        trailing: ElevatedButton(
          onPressed: () => _buy(p),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          child: Text(p.price),
        ),
      ),
    );
  }
}
