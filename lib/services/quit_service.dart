import 'package:shared_preferences/shared_preferences.dart';

class QuitService {
  static late SharedPreferences _prefs;
  
  static const String _keyStartDate = 'quit_start_date';
  static const String _keyCigsPerDay = 'cigs_per_day';
  static const String _keyCostPerPack = 'cost_per_pack';
  static const String _keyCigsPerPack = 'cigs_per_pack';
  static const String _keyIsPremium = 'is_premium';
  static const String _keyCravingsResisted = 'cravings_resisted';

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
