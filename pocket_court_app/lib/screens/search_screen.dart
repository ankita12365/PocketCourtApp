import 'package:flutter/material.dart';
import '../models/law_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_transitions.dart';
import '../widgets/error_view.dart';
import 'law_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<LawModel> _all = [];
  List<LawModel> _filtered = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final laws = await ApiService.getAllLaws();
      setState(() {
        _all = laws;
        _filtered = laws;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearch(String q) {
    final lower = q.toLowerCase().trim();
    setState(() {
      _query = q;
      _filtered = lower.isEmpty
          ? _all
          : _all
              .where((l) =>
                  l.situation.toLowerCase().contains(lower) ||
                  l.category.toLowerCase().contains(lower) ||
                  l.act.toLowerCase().contains(lower) ||
                  l.section.toLowerCase().contains(lower))
              .toList();
    });
  }

  // Stable color per category — doesn't shift when filter changes
  Color _colorForCategory(String category) {
    final index = category.hashCode.abs() % AppTheme.categoryGradients.length;
    return AppTheme.categoryGradients[index].first;
  }

  Widget _highlight(String text, {TextStyle? style}) {
    if (_query.isEmpty) return Text(text, style: style);
    final lower = text.toLowerCase();
    final q = _query.toLowerCase().trim();
    final start = lower.indexOf(q);
    if (start == -1) return Text(text, style: style);
    final end = start + q.length;
    return RichText(
      text: TextSpan(
        style: style ?? const TextStyle(color: Colors.black87),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(
                backgroundColor: Color(0xFFFFF176),
                fontWeight: FontWeight.w700),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _popular = [
    'Drunk driving',
    'UPI fraud',
    'Domestic violence',
    'Cheque bounce',
    'Cyber bullying',
    'Minimum wage',
    'Eve teasing',
    'Hit and run',
    'Security deposit',
  ];

  Widget _emptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  size: 16, color: AppTheme.indigo),
              const SizedBox(width: 6),
              Text('Popular Searches',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popular.map((term) {
              return GestureDetector(
                onTap: () {
                  _ctrl.text = term;
                  _onSearch(term);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.indigo.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded,
                          size: 13,
                          color: AppTheme.indigo.withValues(alpha: 0.6)),
                      const SizedBox(width: 5),
                      Text(term,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.indigo,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Laws'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _ctrl,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search situation, category, act...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppTheme.indigo),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(Icons.clear_rounded, color: Colors.grey),
                        onPressed: () {
                          _ctrl.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppTheme.indigo, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorView(
                  message: _error!,
                  onRetry: () => setState(() {
                    _loading = true;
                    _error = null;
                    _load();
                  }),
                )
              : Column(
                  children: [
                    if (_query.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_filtered.length} result${_filtered.length == 1 ? '' : 's'}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    Expanded(
                      child: _filtered.isEmpty && _query.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 56, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text('No results for "$_query"',
                                      style: TextStyle(
                                          color: Colors.grey.shade500)),
                                ],
                              ),
                            )
                          : _query.isEmpty
                              ? _emptyState()
                              : ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                  itemCount: _filtered.length,
                                  itemBuilder: (context, i) {
                                    final law = _filtered[i];
                                    final color =
                                        _colorForCategory(law.category);
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        SlideUpRoute(
                                          page: LawDetailScreen(
                                            category: law.category,
                                            situation: law.situation,
                                            accentColor: color,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 6),
                                          leading: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color:
                                                  color.withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(Icons.gavel_rounded,
                                                color: color, size: 20),
                                          ),
                                          title: _highlight(law.situation,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Colors.black87)),
                                          subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: color.withValues(
                                                        alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(law.category,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: color,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(law.section,
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey.shade500)),
                                              ],
                                            ),
                                          ),
                                          trailing: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 14,
                                              color: Colors.grey.shade400),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
    );
  }
}
