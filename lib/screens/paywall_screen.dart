import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/screens/home_screen.dart';
import 'package:quitvape/main.dart';

class PaywallScreen extends StatefulWidget {
  final bool isOnboarding;
  const PaywallScreen({super.key, this.isOnboarding = false});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  bool _loading = true;
  int _selectedIndex = 0;
  String? _error;
  String? _diagInfo;

  // DO NOT CHANGE — must match Play Console subscription IDs
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
    // Listen for purchase updates from the start (independent of query).
    _iap.purchaseStream.listen(_onPurchaseUpdate);
    try {
      // Billing client connection can hang forever (e.g. Play Store IPC
      // issues) — never leave the user on an infinite spinner.
      _available = await _iap.isAvailable().timeout(
        const Duration(seconds: 12),
        onTimeout: () =>
            throw TimeoutException('Google Play connection timed out'),
      );
      if (!_available) {
        throw StateError('store-unavailable');
      }
      final response =
          await _iap.queryProductDetails(_productIds).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Plan query timed out'),
      );
      // Debug info for diagnosing missing products.
      final diag =
          'code=${response.error?.code ?? "ok"} msg=${response.error?.message ?? "-"} notFound=${response.notFoundIDs} count=${response.productDetails.length}';
      debugPrint('[QuitVape billing] $diag');
      if (mounted) {
        // Store diagnostic for display in error state (helps remote debugging).
        _diagInfo = diag;
      }
      final sorted = response.productDetails.toList()
        ..sort((a, b) => _sortOrder(a.id).compareTo(_sortOrder(b.id)));
      if (mounted) {
        setState(() {
          _products = sorted;
          _loading = false;
          _error = response.error != null
              ? 'Could not load plans. Check your connection and try again.'
              : (sorted.isEmpty ? 'empty' : null);
          if (_products.isNotEmpty) {
            // default to yearly (index 2) if present
            _selectedIndex =
                _products.indexWhere((p) => p.id.contains('yearly'));
            if (_selectedIndex < 0) _selectedIndex = 0;
          }
        });
      }
    } on TimeoutException catch (e) {
      debugPrint('[QuitVape billing] timeout: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'Taking too long to reach Google Play. Check your connection and tap Try again.';
        });
      }
    } catch (e) {
      debugPrint('[QuitVape billing] init failed: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().contains('store-unavailable')
              ? 'Google Play Store is not available on this device.'
              : 'Could not load plans. Check your connection and try again.';
        });
      }
    }
  }

  int _sortOrder(String id) {
    if (id.contains('weekly')) return 0;
    if (id.contains('monthly')) return 1;
    return 2;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (var p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        QuitService.setPremium(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Welcome to Premium!')),
          );
          _close();
        }
      } else if (p.status == PurchaseStatus.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Purchase failed: ${p.error?.message ?? 'unknown error'}')),
          );
        }
      }
      if (p.pendingCompletePurchase) _iap.completePurchase(p);
    }
  }

  void _buy() {
    if (_products.isEmpty) return;
    final product = _products[_selectedIndex.clamp(0, _products.length - 1)];
    // buyNonConsumable handles subscription purchases in in_app_purchase
    _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  void _close() {
    if (widget.isOnboarding) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  String _periodLabel(String id) {
    if (id.contains('weekly')) return 'week';
    if (id.contains('monthly')) return 'month';
    return 'year';
  }

  String _planName(String id) {
    if (id.contains('weekly')) return 'Weekly';
    if (id.contains('monthly')) return 'Monthly';
    return 'Yearly';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppStyle.ink),
            onPressed: _close,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppStyle.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Try Premium\nfree for 3 days',
                        style: AppStyle.headline(size: 32)),
                    const SizedBox(height: 16),
                    const Text(
                      'Picture yourself a year from now: breathing easy, money in the bank, cravings a distant memory. That future starts with the next three days — on us.',
                      style: TextStyle(
                          color: AppStyle.textDim, fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    _buildTimeline(),
                    const SizedBox(height: 28),
                    Text('Choose your plan',
                        style: AppStyle.headline(size: 20)),
                    const SizedBox(height: 4),
                    const Text(
                      'Free trial on all plans. Cancel anytime.',
                      style:
                          TextStyle(color: AppStyle.textDim, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      _buildError()
                    else
                      ..._products.asMap().entries.map(
                          (e) => _buildPlanCard(e.value, e.key)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _iap.restorePurchases(),
                      child: const Center(
                        child: Text('Restore purchases',
                            style: TextStyle(
                                color: AppStyle.textDim, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _loading || _error != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _products.isEmpty ? null : _buy,
                        style: AppStyle.primaryButton(),
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _trialLine(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppStyle.textFaint, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _timelineRow(
          icon: Icons.lock_open_outlined,
          title: 'Today',
          desc: 'Instant access to all Premium features',
          isLast: false,
        ),
        _timelineRow(
          icon: Icons.notifications_outlined,
          title: 'In 3 days',
          desc: "We'll remind you before your trial ends",
          isLast: false,
        ),
        _timelineRow(
          icon: Icons.star_outline,
          title: 'Day 4',
          desc: _products.isEmpty
              ? 'Your plan starts only if you keep it'
              : "You'll be charged ${_selectedPrice()} if you don't cancel",
          isLast: true,
        ),
      ],
    );
  }

  String _selectedPrice() {
    if (_products.isEmpty) return '';
    final p = _products[_selectedIndex.clamp(0, _products.length - 1)];
    return '${p.price} per ${_periodLabel(p.id)}';
  }

  String _trialLine() {
    if (_products.isEmpty) return '3-day free trial, then cancel anytime';
    final p = _products[_selectedIndex.clamp(0, _products.length - 1)];
    return '3-day free trial, then ${p.price}/${_periodLabel(p.id)}';
  }

  Widget _timelineRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppStyle.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    Icon(icon, color: AppStyle.primary, size: 24),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: AppStyle.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppStyle.ink)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppStyle.textDim,
                          height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(ProductDetails p, int index) {
    final selected = _selectedIndex == index;
    final isYearly = p.id.contains('yearly');
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppStyle.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppStyle.primary : AppStyle.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppStyle.primary : AppStyle.textFaint,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_planName(p.id),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: AppStyle.ink)),
                      if (isYearly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppStyle.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('BEST VALUE',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('3-day free trial included',
                      style: TextStyle(
                          color: AppStyle.textDim, fontSize: 13)),
                ],
              ),
            ),
            Text(
              p.price,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppStyle.ink),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    final activating = _error == 'empty';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyle.card(),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 40, color: AppStyle.textFaint),
          const SizedBox(height: 12),
          Text(
            activating
                ? 'Plans are being activated'
                : _error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppStyle.textDim, fontSize: 15, height: 1.4),
          ),
          if (activating)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please check back in a little while.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppStyle.textFaint, fontSize: 13),
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _initStore();
            },
            child: const Text('Try again',
                style: TextStyle(
                    color: AppStyle.primary, fontWeight: FontWeight.w700)),
          ),
          if (_diagInfo != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _diagInfo!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppStyle.textFaint, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
