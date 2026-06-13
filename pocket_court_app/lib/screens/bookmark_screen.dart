import 'package:flutter/material.dart';
import '../models/law_model.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_transitions.dart';
import 'law_detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});
  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with WidgetsBindingObserver {
  List<LawModel> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    final data = await BookmarkService.getAll();
    if (mounted)
      setState(() {
        _bookmarks = data;
        _loading = false;
      });
  }

  Future<void> _remove(LawModel law) async {
    await BookmarkService.remove(law.category, law.situation);
    setState(() => _bookmarks.removeWhere(
        (l) => l.category == law.category && l.situation == law.situation));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Bookmark removed')));
  }

  Color _color(LawModel law) => AppTheme
      .categoryGradients[
          law.category.hashCode.abs() % AppTheme.categoryGradients.length]
      .first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Laws')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                            color: AppTheme.indigo.withValues(alpha: 0.07),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.bookmark_border_rounded,
                            size: 52, color: AppTheme.indigo),
                      ),
                      const SizedBox(height: 20),
                      const Text('No saved laws yet',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Tap the bookmark icon on any law\nto save it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              height: 1.5)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _bookmarks.length,
                    itemBuilder: (context, i) {
                      final law = _bookmarks[i];
                      final color = _color(law);
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              SlideUpRoute(
                                page: LawDetailScreen(
                                    category: law.category,
                                    situation: law.situation,
                                    accentColor: color),
                              ));
                          _load();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(Icons.bookmark_rounded,
                                    color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(law.situation,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                              color:
                                                  color.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(law.category,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: color,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(law.section,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500)),
                                      ]),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.redAccent, size: 20),
                                onPressed: () => _remove(law),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
