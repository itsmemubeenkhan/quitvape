import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/main.dart';

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
  int _selectedIndex = 2;
  late Timer _countdownTimer;
  Duration _timeLeft = const Duration(hours: 23, minutes: 59, seconds: 59);

  static const Set<String> _productIds = {
    'quitvape_weekly',
    'quitvape_monthly',
    'quitvape_yearly',
  };

  @override
  void initState() {
    super.initState();
    _initStore();
    // FOMO countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft = _timeLeft - const Duration(seconds: 1);
          } else {
            _timeLeft = const Duration(hours: 23, minutes: 59, seconds: 59);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  Future<void> _initStore() async {
    _available = await _iap.isAvailable();
    if (_available) {
      final response = await _iap.queryProductDetails(_productIds);
      final sorted = response.productDetails.toList()
        ..sort((a, b) => _sortOrder(a.id).compareTo(_sortOrder(b.id)));
      if (mounted) {
        setState(() {
          _products = sorted;
          _loading = false;
          if (_products.length > 2) _selectedIndex = 2;
          else if (_products.isNotEmpty) _selectedIndex = _products.length - 1;
        });
      }
      _iap.purchaseStream.listen(_onPurchaseUpdate);
    } else {
      if (mounted) setState(() => _loading = false);
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
            const SnackBar(
              content: Text('🎉 Welcome to Premium! Your quit journey just got serious!'),
              backgroundColor: Color(0xFF00B87D),
            ),
          );
          Navigator.pop(context);
        }
      }
      if (p.pendingCompletePurchase) _iap.completePurchase(p);
    }
  }

  void _buy(ProductDetails product) {
    _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  String _formatCountdown() {
    final h = _timeLeft.inHours.toString().padLeft(2, '0');
    final m = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              child: Column(
                children: [
                  // FOMO banner with countdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppStyle.gradientRed,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppStyle.red.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text('FLASH SALE — 50% OFF ENDS IN',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_formatCountdown(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                  letterSpacing: 2)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Crown + headline
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppStyle.gradientGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppStyle.gold.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                      ],
                    ),
                    child: const Center(child: Text('👑', style: TextStyle(fontSize: 44))),
                  ),
                  const SizedBox(height: 16),
                  Text('Quit Faster.\nStay Quit Forever.',
                      textAlign: TextAlign.center, style: AppStyle.headline(size: 30)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: AppStyle.gold, size: 18),
                      const SizedBox(width: 4),
                      const Text('4.9 rating',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      Text('•  12,400+ happy quitters',
                          style: TextStyle(color: AppStyle.textDim, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Benefits
                  _buildBenefit('📊', 'Advanced Insights & Charts', 'See your patterns, beat them faster'),
                  _buildBenefit('🎮', 'Craving SOS Toolkit', 'Games, grounding & emergency tools'),
                  _buildBenefit('🏅', 'All Rewards Unlocked', 'Every badge, every achievement'),
                  _buildBenefit('🔔', 'Smart Quit Reminders', 'Motivation when you need it most'),
                  _buildBenefit('☁️', 'Cloud Backup', 'Never lose your streak'),
                  _buildBenefit('🚫', 'Zero Ads', 'Pure focus, no distractions'),
                  const SizedBox(height: 20),

                  // Testimonials
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('What quitters say 👇',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  _buildTestimonial('⭐⭐⭐⭐⭐',
                      '"I tried 4 other apps. This is the ONLY one that worked. 8 months vape-free!"',
                      '— Sarah M. • 243 days free'),
                  _buildTestimonial('⭐⭐⭐⭐⭐',
                      '"The SOS tools saved me at least 20 times. Worth every penny."',
                      '— James K. • 156 days free'),
                  _buildTestimonial('⭐⭐⭐⭐⭐',
                      '"Paid for yearly in week 1. Saved \$1,400 so far. Best money ever spent."',
                      '— Ahmed R. • 189 days free'),
                  const SizedBox(height: 20),

                  // Plans
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Choose your plan:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('3-day FREE trial on all plans • Cancel anytime',
                        style: TextStyle(color: AppStyle.textDim, fontSize: 13)),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppStyle.emerald))
                  else if (_products.isEmpty)
                    _buildFallbackPlans()
                  else
                    ..._products.asMap().entries.map((e) => _buildPlanCard(e.value, e.key)),
                  const SizedBox(height: 8),

                  // Guarantee
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppStyle.emerald.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppStyle.emerald.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Text('🛡️', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Quit-or-refund guarantee: If you don\'t love it, cancel in 3 days and pay nothing.',
                              style: TextStyle(color: AppStyle.textDim, fontSize: 13, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _iap.restorePurchases(),
                    child: const Text('Restore Purchases', style: TextStyle(color: AppStyle.textDim)),
                  ),
                ],
              ),
            ),
            // Close
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF1E2A24), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
            // Sticky CTA
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D1310),
                  border: Border(top: BorderSide(color: Color(0xFF1E2A24))),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppStyle.gradientEmerald,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(color: AppStyle.emerald.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _products.isEmpty
                              ? null
                              : () => _buy(_products[_selectedIndex.clamp(0, _products.length - 1)]),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text('Start 3-Day FREE Trial 🎉',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Then 50% off • Cancel anytime in 1 tap',
                        style: TextStyle(color: AppStyle.textFaint, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fallback plans shown before Play Console products load
  Widget _buildFallbackPlans() {
    final plans = [
      {'name': 'Weekly', 'price': '\$4.99', 'strike': '\$9.99', 'badge': null, 'per': '/week'},
      {'name': 'Monthly', 'price': '\$9.99', 'strike': '\$19.99', 'badge': 'POPULAR', 'per': '/month'},
      {'name': 'Yearly', 'price': '\$49.99', 'strike': '\$99.99', 'badge': '50% OFF', 'per': '/year'},
    ];
    return Column(
      children: plans.asMap().entries.map((e) {
        final i = e.key;
        final p = e.value;
        final isSelected = _selectedIndex == i;
        final isYearly = i == 2;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? AppStyle.emerald.withOpacity(0.08) : AppStyle.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isSelected ? AppStyle.emerald : const Color(0xFF1E2A24),
                  width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? AppStyle.emerald : AppStyle.textFaint),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(p['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                          if (p['badge'] != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: isYearly ? AppStyle.gradientRed : AppStyle.gradientGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(p['badge'] as String,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isYearly ? Colors.white : Colors.black)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('3-day free trial included',
                          style: TextStyle(color: AppStyle.textDim, fontSize: 12)),
                      if (isYearly)
                        const Text('Just \$0.14/day — less than a coffee! ☕',
                            style: TextStyle(color: AppStyle.emerald, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(p['strike'] as String,
                        style: const TextStyle(
                            decoration: TextDecoration.lineThrough, color: AppStyle.textFaint, fontSize: 13)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(p['price'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.white)),
                        Text(p['per'] as String, style: const TextStyle(color: AppStyle.textDim, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanCard(ProductDetails p, int index) {
    final isSelected = _selectedIndex == index;
    final isYearly = p.id.contains('yearly');
    final isMonthly = p.id.contains('monthly');
    String planName = isYearly ? 'Yearly' : isMonthly ? 'Monthly' : 'Weekly';
    String strike = isYearly ? '\$99.99' : isMonthly ? '\$19.99' : '\$9.99';

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppStyle.emerald.withOpacity(0.08) : AppStyle.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? AppStyle.emerald : const Color(0xFF1E2A24), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? AppStyle.emerald : AppStyle.textFaint),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(planName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                      if (isYearly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(gradient: AppStyle.gradientRed, borderRadius: BorderRadius.circular(6)),
                          child: const Text('50% OFF',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                      ],
                      if (isMonthly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(gradient: AppStyle.gradientGold, borderRadius: BorderRadius.circular(6)),
                          child: const Text('POPULAR',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)),
                        ),
                      ],
                    ],
                  ),
                  const Text('3-day free trial included', style: TextStyle(color: AppStyle.textDim, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(strike,
                    style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppStyle.textFaint, fontSize: 13)),
                Text(p.price, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
              ],
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppStyle.emerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                Text(desc, style: const TextStyle(color: AppStyle.textDim, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppStyle.emerald, size: 24),
        ],
      ),
    );
  }

  Widget _buildTestimonial(String stars, String quote, String author) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyle.gold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stars, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Text(quote, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white, height: 1.4)),
          const SizedBox(height: 6),
          Text(author, style: const TextStyle(fontSize: 12, color: AppStyle.textDim, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
