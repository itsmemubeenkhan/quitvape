import 'package:flutter/material.dart';
import 'package:quitvape/services/quit_service.dart';
import 'package:quitvape/main.dart';

/// Learn center: tabbed article library with read tracking.
/// All content is original and general wellness information.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _tabs = ['Basics', 'Health', 'Mindset'];

  static const Map<String, List<Map<String, String>>> _articles = {
    'Basics': [
      {
        'id': 'how-nicotine-hooks',
        'title': 'How nicotine keeps you hooked',
        'readTime': '4 min read',
        'body':
            'Nicotine reaches your brain within seconds of a puff and triggers a quick release of dopamine — the "feel good" chemical. Your brain starts to expect that hit, and over time it produces less dopamine on its own.\n\nThat is why quitting feels hard at first: your brain needs time to rebalance. The good news is that this rebalancing starts within days of your last puff, and every craving you ride out weakens the old pattern.\n\nUnderstanding the loop — trigger, craving, puff, relief — is the first step to breaking it. When you spot the trigger, you can choose a different response.',
      },
      {
        'id': 'craving-wave',
        'title': 'Cravings come in waves',
        'readTime': '3 min read',
        'body':
            'A craving is not a permanent state. Research on habit change shows that an urge typically peaks within about 3 minutes and then fades — like a wave.\n\nThis is why the SOS tools in this app focus on short, focused activities: breathing, a quick game, a walk. You do not need to fight the craving all day. You only need to ride out a few minutes.\n\nEach time you surf a craving instead of giving in, the next wave tends to be a little weaker. You are literally retraining your brain.',
      },
      {
        'id': 'quit-plan-basics',
        'title': 'Build your personal quit plan',
        'readTime': '5 min read',
        'body':
            'People who write down a plan are more likely to stick with it. A simple plan has four parts:\n\n1. Your quit date — the moment your new streak starts.\n2. Your triggers — the situations where cravings hit hardest.\n3. Your tools — what you will do instead (breathing, walking, SOS).\n4. Your support — who knows about your quit and cheers you on.\n\nReview your plan each morning. On hard days, read your reasons again. Plans are not about perfection — they are about having a next step ready when willpower wobbles.',
      },
    ],
    'Health': [
      {
        'id': 'body-recovers',
        'title': 'How your body recovers after quitting',
        'readTime': '6 min read',
        'body':
            'Your body starts repairing itself remarkably fast after your last puff:\n\n• Within hours, your heart rate and blood pressure begin to settle.\n• Within days, your senses of taste and smell sharpen as they recover.\n• Within weeks, circulation improves and breathing during activity gets easier.\n• Within months, lung function continues to improve and lingering coughs fade.\n\nEveryone recovers at their own pace, and vaping history, age, and overall health all play a role. The timeline in this app shows typical milestones — watch them unlock as your streak grows.',
      },
      {
        'id': 'sleep-energy',
        'title': 'Sleep, energy, and nicotine',
        'readTime': '4 min read',
        'body':
            'Nicotine is a stimulant, and using it late in the day can fragment your sleep — even if you fall asleep easily. Many people report deeper, more restful sleep within the first couple of weeks after quitting.\n\nBetter sleep means steadier energy during the day, which means fewer of those tired, low-willpower moments when cravings hit hardest. If the first week feels tiring, that is normal: your body is adjusting. Protect your sleep — consistent bedtimes and less screen time before bed help a lot.',
      },
      {
        'id': 'money-health',
        'title': 'The true cost of vaping',
        'readTime': '3 min read',
        'body':
            'Devices, pods, coils, e-liquid — it adds up quietly. A moderate daily habit can easily cost the equivalent of a nice vacation every year.\n\nBut the bigger cost is attention: every craving interrupts your focus, every vape break breaks your flow. Quitting gives you back both money and mental bandwidth.\n\nCheck your savings counter on the home screen. Set a goal for what the saved money becomes — a trip, a gadget, an emergency fund. A concrete reward makes the abstract savings feel real.',
      },
    ],
    'Mindset': [
      {
        'id': 'relapse-not-failure',
        'title': 'A slip is not a failure',
        'readTime': '4 min read',
        'body':
            'Most people who quit successfully have tried before. A slip — one puff on a hard day — does not erase your progress or mean you "failed".\n\nWhat matters is what happens next. People who treat a slip as data ("what triggered it? what will I do differently?") get back on track faster than people who treat it as proof they cannot quit.\n\nIf it happens: note the trigger, reset your quit date if you need to, and keep going. Your streak of vape-free days still counts. Every one of them taught your brain something.',
      },
      {
        'id': 'identity-shift',
        'title': 'Become someone who does not vape',
        'readTime': '5 min read',
        'body':
            'There is a subtle but powerful shift between "I am trying to quit" and "I am someone who does not vape". The first frames every day as a struggle. The second frames it as identity.\n\nIdentity-based change works because it turns hundreds of small decisions into one big one. When a craving hits, the question is not "can I resist this time?" but "what would a non-vaper do right now?"\n\nYou do not need to feel like that person yet. Act like them — track the streak, use the tools, keep the pledge — and the feeling follows the behavior.',
      },
      {
        'id': 'stress-without-vape',
        'title': 'Handling stress without vaping',
        'readTime': '5 min read',
        'body':
            'Many people vape to "take the edge off" stress. But nicotine does not remove stress — it briefly relieves the withdrawal that feels like stress, then the cycle repeats.\n\nReal stress tools work differently: slow breathing activates your calm-down system, a short walk burns off tension hormones, and writing down worries gets them out of your head.\n\nBuild a personal stress menu of 3–5 things that work for you, and keep it somewhere visible. When stress hits, pick from the menu instead of reaching for the vape. Over time, your brain learns the new route.',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text('Learn',
                  style: AppStyle.headline(size: 26)),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Knowledge is fuel. Read in order for the full picture.',
                style: TextStyle(color: AppStyle.textDim, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppStyle.primary,
              unselectedLabelColor: AppStyle.textFaint,
              indicatorColor: AppStyle.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs
                    .map((t) => _buildArticleList(t))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleList(String tab) {
    final articles = _articles[tab]!;
    final read = QuitService.getReadArticles();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: articles.length,
      itemBuilder: (context, i) {
        final a = articles[i];
        final isRead = read.contains(a['id']);
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _ArticleReader(article: a),
              ),
            );
            setState(() {});
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: AppStyle.card(),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isRead
                        ? AppStyle.primarySoft
                        : AppStyle.bg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: isRead
                        ? const Icon(Icons.check_rounded,
                            color: AppStyle.primary, size: 22)
                        : Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppStyle.textDim)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['title']!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppStyle.ink,
                              height: 1.3)),
                      const SizedBox(height: 4),
                      Text(a['readTime']!,
                          style: const TextStyle(
                              color: AppStyle.textFaint, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: AppStyle.textFaint),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArticleReader extends StatelessWidget {
  final Map<String, String> article;
  const _ArticleReader({required this.article});

  @override
  Widget build(BuildContext context) {
    // Mark as read when opened
    QuitService.markArticleRead(article['id']!);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppStyle.ink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppStyle.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(article['readTime']!,
                  style: const TextStyle(
                      color: AppStyle.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            Text(article['title']!,
                style: AppStyle.headline(size: 28)),
            const SizedBox(height: 20),
            Text(article['body']!,
                style: const TextStyle(
                    fontSize: 16,
                    color: AppStyle.ink,
                    height: 1.7)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: AppStyle.primaryButton(),
                child: const Text('Done reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
