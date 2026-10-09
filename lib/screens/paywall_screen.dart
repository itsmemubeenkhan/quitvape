import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quitvape/services/quit_service.dart';

class PaywallScreen extends StatefulWidget {
  final bool showAtStart;
  const PaywallScreen({super.key, this.showAtStart = false});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  bool _loading = true;
  int _selectedIndex = 2; // Default to yearly (best value)

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
      final sorted = response.productDetails.toList()
        ..sort((a, b) => _sortOrder(a.id).compareTo(_sortOrder(b.id)));
      setState(() {
        _products = sorted;
        _loading = false;
      });
      _iap.purchaseStream.listen(_onPurchaseUpdate);
    } else {
      setState(() => _loading = false);
    }
  }

  int _sortOrder(String id) {
    if (id.contains('weekly')) return 0;
    if (id.contains('monthly')) return 1;
    return 2;
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
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Special offer banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🔥 ', style: TextStyle(fontSize: 20)),
                        Text(
                          'LIMITED OFFER: 50% OFF + 3-DAY FREE TRIAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('👑', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  const Text(
                    'Quit Faster with Premium',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join 10,000+ people who quit for good',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildBenefit('📊', 'Advanced Statistics', 'Detailed charts & health insights'),
                  _buildBenefit('🎯', 'Personal Goals', 'Set custom milestones & rewards'),
                  _buildBenefit('🔔', 'Smart Reminders', 'Motivational notifications that work'),
                  _buildBenefit('🧘', 'Craving SOS Kit', 'Emergency tools when urges hit hard'),
                  _buildBenefit('🚫', 'No Ads', 'Clean, focused experience'),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose your plan:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )
                  else if (_products.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Subscriptions will appear here once configured in Play Console.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ..._products.asMap().entries.map((e) => _buildProductCard(e.value, e.key)),
                  const SizedBox(height: 8),
                  const Text(
                    '3-day free trial, then charged. Cancel anytime.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => _iap.restorePurchases(),
                    child: const Text('Restore Purchases'),
                  ),
                ],
              ),
            ),
            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Sticky CTA button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _products.isEmpty ? null : () => _buy(_products[_selectedIndex.clamp(0, _products.length - 1)]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Start 3-Day FREE Trial 🎉',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductDetails p, int index) {
    final isSelected = _selectedIndex == index;
    final isYearly = p.id.contains('yearly');
    final isMonthly = p.id.contains('monthly');

    String planName = 'Weekly';
    String strikePrice = '';
    if (isYearly) {
      planName = 'Yearly';
      strikePrice = '\$99.99';
    } else if (isMonthly) {
      planName = 'Monthly';
      strikePrice = '\$19.99';
    } else {
      strikePrice = '\$9.99';
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? const Color(0xFF10B981).withOpacity(0.06) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF10B981) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(planName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (isYearly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '50% OFF',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('3-day free trial included', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  strikePrice,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                Text(
                  p.price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
