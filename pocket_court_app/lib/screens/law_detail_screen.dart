import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/law_model.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';

class LawDetailScreen extends StatefulWidget {
  final String category;
  final String situation;
  final Color accentColor;

  const LawDetailScreen({
    super.key,
    required this.category,
    required this.situation,
    this.accentColor = AppTheme.indigo,
  });

  @override
  State<LawDetailScreen> createState() => _LawDetailScreenState();
}

class _LawDetailScreenState extends State<LawDetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<LawModel> _future;
  bool _bookmarked = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _future = ApiService.getLaw(widget.category, widget.situation).then((law) {
      if (mounted) _fadeCtrl.forward();
      return law;
    });
    _checkBookmark();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBookmark() async {
    final saved =
        await BookmarkService.isBookmarked(widget.category, widget.situation);
    if (mounted) setState(() => _bookmarked = saved);
  }

  Future<void> _toggleBookmark(LawModel law) async {
    if (_bookmarked) {
      await BookmarkService.remove(law.category, law.situation);
      setState(() => _bookmarked = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from bookmarks')));
    } else {
      await BookmarkService.add(law);
      setState(() => _bookmarked = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved to bookmarks')));
    }
  }

  void _share(LawModel law) {
    final text = '''
⚖️ Pocket Court — Know Your Rights

📌 Situation: ${law.situation}
🏷️ Category: ${law.category}

📖 Act: ${law.act}
📄 Section: ${law.section}
💰 Fine / Penalty: ${law.fine}
🔖 Constitutional Article: ${law.article}

ℹ️ ${law.article}

Shared via Pocket Court App
''';
    Share.share(text, subject: 'Know Your Rights — ${law.situation}');
  }

  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LawModel>(
        future: _future,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                actions: [
                  if (snapshot.hasData) ...[
                    IconButton(
                      icon:
                          const Icon(Icons.share_rounded, color: Colors.white),
                      tooltip: 'Share',
                      onPressed: () => _share(snapshot.data!),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: IconButton(
                        key: ValueKey(_bookmarked),
                        icon: Icon(
                          _bookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: _bookmarked ? AppTheme.amber : Colors.white,
                        ),
                        onPressed: () => _toggleBookmark(snapshot.data!),
                      ),
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(56, 0, 100, 16),
                  title: Text(
                    widget.situation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor,
                          widget.accentColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40, right: 20),
                        child: Icon(Icons.gavel_rounded,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                    ),
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() => _future =
                        ApiService.getLaw(widget.category, widget.situation)),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _Chip(
                          label: snapshot.data!.category,
                          color: widget.accentColor),
                      const SizedBox(height: 20),
                      _infoCard('Act', snapshot.data!.act,
                          Icons.menu_book_rounded, AppTheme.indigo),
                      _infoCard('Section', snapshot.data!.section,
                          Icons.article_rounded, const Color(0xFF00897B)),
                      _infoCard('Fine / Penalty', snapshot.data!.fine,
                          Icons.money_off_rounded, const Color(0xFFE53935)),
                      _infoCard(
                          'Constitutional Article',
                          snapshot.data!.article,
                          Icons.account_balance_rounded,
                          const Color(0xFF8E24AA)),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: OutlinedButton.icon(
                          onPressed: () => _share(snapshot.data!),
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Share this Law'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.accentColor,
                            side: BorderSide(
                                color:
                                    widget.accentColor.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
