import 'package:shared_preferences/shared_preferences.dart';

class QuitService {
  static late SharedPreferences _prefs;
  
  static const String _keyStartDate = 'quit_start_date';
  static const String _keyCigsPerDay = 'cigs_per_day';
  static const String _keyCostPerPack = 'cost_per_pack';
  static const String _keyCigsPerPack = 'cigs_per_pack';
  static const String _keyIsPremium = 'is_premium';
  static const String _keyCravingsResisted = 'cravings_resisted';
  static const String _keyPostCravingPaywall = 'post_craving_paywall_seen';
  static const String _keyCheckInStreak = 'checkin_streak';
  static const String _keyLastCheckIn = 'last_checkin_date';
  static const String _keyLastPledge = 'last_pledge_date';
  static const String _keyUserName = 'user_name';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyCoins = 'quit_coins';
  static const String _keyLastCoinClaim = 'last_coin_claim';

  static bool hasSeenPostCravingPaywall() {
    return _prefs.getBool(_keyPostCravingPaywall) ?? false;
  }

  static Future<void> markPostCravingPaywallSeen() async {
    await _prefs.setBool(_keyPostCravingPaywall, true);
  }

  // Check-in streak
  static int getCheckInStreak() {
    return _prefs.getInt(_keyCheckInStreak) ?? 0;
  }

  static bool hasCheckedInToday() {
    final last = _prefs.getString(_keyLastCheckIn);
    if (last == null) return false;
    final lastDate = DateTime.parse(last);
    final now = DateTime.now();
    return lastDate.year == now.year && lastDate.month == now.month && lastDate.day == now.day;
  }

  static Future<void> saveCheckIn({required int mood, required int cravingStrength, required List<String> triggers}) async {
    final now = DateTime.now();
    final last = _prefs.getString(_keyLastCheckIn);
    int streak = _prefs.getInt(_keyCheckInStreak) ?? 0;

    if (last != null) {
      final lastDate = DateTime.parse(last);
      final diff = now.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
      // diff == 0 means already checked in today, keep streak
    } else {
      streak = 1;
    }

    await _prefs.setInt(_keyCheckInStreak, streak);
    await _prefs.setString(_keyLastCheckIn, now.toIso8601String());
  }

  // Daily pledge
  static bool hasPledgedToday() {
    final last = _prefs.getString(_keyLastPledge);
    if (last == null) return false;
    final lastDate = DateTime.parse(last);
    final now = DateTime.now();
    return lastDate.year == now.year && lastDate.month == now.month && lastDate.day == now.day;
  }

  static Future<void> makePledge() async {
    await _prefs.setString(_keyLastPledge, DateTime.now().toIso8601String());
  }

  static double getDailyCost() {
    final cigsPerDay = _prefs.getInt(_keyCigsPerDay) ?? 20;
    final costPerPack = _prefs.getDouble(_keyCostPerPack) ?? 8.0;
    final cigsPerPack = _prefs.getInt(_keyCigsPerPack) ?? 20;
    return cigsPerDay * (costPerPack / cigsPerPack);
  }

  // User profile
  static String getUserName() {
    return _prefs.getString(_keyUserName) ?? '';
  }

  static Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }

  // Notifications
  static bool areNotificationsEnabled() {
    return _prefs.getBool(_keyNotifications) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotifications, enabled);
  }

  static Future<void> scheduleDailyMotivation() async {
    // Will be implemented with flutter_local_notifications
    // For now just save the preference
  }

  static Future<void> cancelNotifications() async {
    // Will be implemented with flutter_local_notifications
  }

  // Quit & Earn rewards system
  static int getCoins() {
    return _prefs.getInt(_keyCoins) ?? 0;
  }

  static bool canClaimDailyCoins() {
    final last = _prefs.getString(_keyLastCoinClaim);
    if (last == null) return true;
    final lastDate = DateTime.parse(last);
    final now = DateTime.now();
    return !(lastDate.year == now.year && lastDate.month == now.month && lastDate.day == now.day);
  }

  static int getDailyCoinReward() {
    // Premium users earn 2.5x more - strong incentive to subscribe!
    return isPremium() ? 25 : 10;
  }

  static Future<int> claimDailyCoins() async {
    if (!canClaimDailyCoins()) return 0;
    final reward = getDailyCoinReward();
    final current = getCoins();
    await _prefs.setInt(_keyCoins, current + reward);
    await _prefs.setString(_keyLastCoinClaim, DateTime.now().toIso8601String());
    // Streak bonus: every 7 days = bonus 50 coins
    final days = getQuitDuration().inDays;
    if (days > 0 && days % 7 == 0) {
      final bonus = isPremium() ? 100 : 50;
      await _prefs.setInt(_keyCoins, current + reward + bonus);
      return reward + bonus;
    }
    return reward;
  }

  static double getCoinsValue() {
    // 100 coins = $1 value (virtual)
    return getCoins() / 100.0;
  }

  // Coin Shop - what coins can buy
  static const String _keyUnlockedItems = 'unlocked_items';

  static List<String> getUnlockedItems() {
    return _prefs.getStringList(_keyUnlockedItems) ?? [];
  }

  static bool isItemUnlocked(String itemId) {
    return getUnlockedItems().contains(itemId) || isPremium();
  }

  static Future<bool> purchaseWithCoins(String itemId, int cost) async {
    if (isItemUnlocked(itemId)) return true;
    final coins = getCoins();
    if (coins < cost) return false;
    await _prefs.setInt(_keyCoins, coins - cost);
    final items = getUnlockedItems();
    items.add(itemId);
    await _prefs.setStringList(_keyUnlockedItems, items);
    return true;
  }

  // Shop items - 100% OFFLINE, no backend needed!
  // Note: AI Coach needs NVIDIA API key (user provides)
  static List<Map<String, dynamic>> getShopItems() {
    return [
      {
        'id': 'ai_coach',
        'emoji': '🤖',
        'name': 'AI Quit Coach',
        'desc': '24/7 personal coach in YOUR language',
        'cost': 1500,
        'teaser': 'Talk, share feelings, get help anytime!',
      },
      {
        'id': 'mystery_games',
        'emoji': '🎮',
        'name': 'Mystery Craving Games',
        'desc': '5 secret games revealed when unlocked... 👀',
        'cost': 800,
        'teaser': 'What games? That\'s the surprise! 🎁',
      },
      {
        'id': 'quit_plan',
        'emoji': '📋',
        'name': 'Personal Quit Plan',
        'desc': 'Custom 30-day plan based on YOUR habits',
        'cost': 1000,
        'teaser': 'Built just for you, works offline!',
      },
      {
        'id': 'doctor_report',
        'emoji': '🏥',
        'name': 'Doctor Health Report',
        'desc': 'Professional PDF of your recovery',
        'cost': 700,
        'teaser': 'Show your doctor your progress!',
      },
      {
        'id': 'insights_pro',
        'emoji': '📊',
        'name': 'Advanced Insights',
        'desc': 'Craving patterns & predictions',
        'cost': 600,
        'teaser': 'Know WHEN cravings will hit!',
      },
      {
        'id': 'breathing_pack',
        'emoji': '🌬️',
        'name': 'Breathing Mastery Pack',
        'desc': '7 advanced breathing techniques',
        'cost': 500,
        'teaser': 'Beyond basic breathing! 🧘',
      },
    ];
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool hasStarted() {
    return _prefs.getString(_keyStartDate) != null;
  }

  static Future<void> startQuit({
    required int cigsPerDay,
    required double costPerPack,
    int cigsPerPack = 20,
  }) async {
    await _prefs.setString(_keyStartDate, DateTime.now().toIso8601String());
    await _prefs.setInt(_keyCigsPerDay, cigsPerDay);
    await _prefs.setDouble(_keyCostPerPack, costPerPack);
    await _prefs.setInt(_keyCigsPerPack, cigsPerPack);
    await _prefs.setInt(_keyCravingsResisted, 0);
  }

  static DateTime getStartDate() {
    final str = _prefs.getString(_keyStartDate);
    return str != null ? DateTime.parse(str) : DateTime.now();
  }

  static Duration getQuitDuration() {
    return DateTime.now().difference(getStartDate());
  }

  static double getMoneySaved() {
    final cigsPerDay = _prefs.getInt(_keyCigsPerDay) ?? 20;
    final costPerPack = _prefs.getDouble(_keyCostPerPack) ?? 8.0;
    final cigsPerPack = _prefs.getInt(_keyCigsPerPack) ?? 20;
    final costPerCig = costPerPack / cigsPerPack;
    final days = getQuitDuration().inHours / 24;
    return days * cigsPerDay * costPerCig;
  }

  static int getCigsAvoided() {
    final cigsPerDay = _prefs.getInt(_keyCigsPerDay) ?? 20;
    final days = getQuitDuration().inHours / 24;
    return (days * cigsPerDay).round();
  }

  static int getCravingsResisted() {
    return _prefs.getInt(_keyCravingsResisted) ?? 0;
  }

  static Future<void> incrementCravingsResisted() async {
    final current = getCravingsResisted();
    await _prefs.setInt(_keyCravingsResisted, current + 1);
  }

  static bool isPremium() {
    return _prefs.getBool(_keyIsPremium) ?? false;
  }

  static Future<void> setPremium(bool value) async {
    await _prefs.setBool(_keyIsPremium, value);
  }

  static Future<void> reset() async {
    await _prefs.clear();
  }

  // Health milestones in hours
  static List<Map<String, dynamic>> getMilestones() {
    final hours = getQuitDuration().inHours;
    return [
      {'hours': 0, 'title': 'Last Cigarette', 'desc': 'Your journey begins!', 'icon': '🚭'},
      {'hours': 1, 'title': '20 Minutes', 'desc': 'Heart rate drops to normal', 'icon': '❤️'},
      {'hours': 8, 'title': '8 Hours', 'desc': 'Nicotine level drops 93%', 'icon': '🫁'},
      {'hours': 24, 'title': '1 Day', 'desc': 'Carbon monoxide cleared', 'icon': '💨'},
      {'hours': 48, 'title': '2 Days', 'desc': 'Taste & smell improve', 'icon': '👃'},
      {'hours': 72, 'title': '3 Days', 'desc': 'Nicotine fully out of body', 'icon': '🎉'},
      {'hours': 168, 'title': '1 Week', 'desc': 'Cravings become manageable', 'icon': '💪'},
      {'hours': 336, 'title': '2 Weeks', 'desc': 'Circulation improves', 'icon': '🩸'},
      {'hours': 720, 'title': '1 Month', 'desc': 'Lung function up 30%', 'icon': '🫀'},
      {'hours': 2160, 'title': '3 Months', 'desc': 'Fertility improves', 'icon': '🌟'},
      {'hours': 4320, 'title': '6 Months', 'desc': 'Coughing & congestion fade', 'icon': '😮‍💨'},
      {'hours': 8760, 'title': '1 Year', 'desc': 'Heart disease risk halved!', 'icon': '🏆'},
    ].map((m) => {...m, 'achieved': hours >= (m['hours'] as int)}).toList();
  }
}
