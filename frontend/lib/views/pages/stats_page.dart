import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/data/globals.dart' as globals;
import 'package:app/main.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<ScoreRecord> _allRecords = [];
  List<ScoreRecord> _filteredRecords = [];
  String? _selectedPattern;
  DateTimeRange? _dateRange;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final localIp = globals.localIP;
      final response = await http.get(
        Uri.parse('https://$localIp:5001/api/stats'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched stats: $data');
        List<ScoreRecord> records = [];
        if (data['byPattern'] != null) {
          for (var patternData in data['byPattern']) {
            // Dla każdego patternu tworzymy przykładowy rekord
            // (w rzeczywistości powinieneś mieć więcej danych w odpowiedzi backendu)
            records.add(ScoreRecord(
              timestamp: DateTime.now(), // Powinno pochodzić z backendu
              patternKey: patternData['pattern'],
              beatAccepted: patternData['accepted'] > 0,
              mse: data['averageMSE']?.toDouble() ?? 0.0,
              se: 0.0, // Powinno pochodzić z backendu
              score: patternData['avgScore']?.toInt() ?? 0,
            ));
          }
        };

          setState(() {
            _allRecords = records;
            _filteredRecords = List.from(_allRecords);
            _isLoading = false;
          });
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        final patternMatch = _selectedPattern == null || 
            record.patternKey == _selectedPattern;
        
        final dateMatch = _dateRange == null || 
            (record.timestamp.isAfter(_dateRange!.start) && 
             record.timestamp.isBefore(_dateRange!.end));
        
        return patternMatch && dateMatch;
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange ?? initialDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final uniquePatterns = _allRecords.map((r) => r.patternKey).toSet().toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Statystyki postępów',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                appColors.statsGradientStart,
                appColors.statsGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        elevation: 4,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Błąd podczas ładowania statystyk',
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchStats,
                          child: const Text('Spróbuj ponownie'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filtry
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: appColors.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (!isSmallScreen)
                                  Row(
                                    children: [
                                      _buildPatternFilter(uniquePatterns, context),
                                      const SizedBox(width: 16),
                                      _buildDateRangeFilter(context),
                                      const Spacer(),
                                      _buildResetFiltersButton(),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      _buildPatternFilter(uniquePatterns, context),
                                      const SizedBox(height: 12),
                                      _buildDateRangeFilter(context),
                                      const SizedBox(height: 12),
                                      _buildResetFiltersButton(),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Podsumowanie
                        Text(
                          'Podsumowanie',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryCards(context),
                        const SizedBox(height: 24),
                        
                        // Wykres postępów
                        Text(
                          'Postępy w czasie',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildProgressChart(),
                        const SizedBox(height: 24),
                        
                        // Szczegółowe statystyki
                        Text(
                          'Szczegółowe wyniki',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailedStatsTable(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPatternFilter(List<String> patterns, BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return DropdownButtonFormField<String>(
      value: _selectedPattern,
      decoration: InputDecoration(
        labelText: 'Filtruj po patternie',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Wszystkie patterny'),
        ),
        ...patterns.map((pattern) {
          return DropdownMenuItem(
            value: pattern,
            child: Text(pattern),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPattern = value;
          _applyFilters();
        });
      },
      style: GoogleFonts.poppins(
        color: appColors.secondaryColor,
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return InkWell(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: appColors.navUnselectedColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Text(
              _dateRange == null
                  ? 'Wszystkie daty'
                  : '${dateFormat.format(_dateRange!.start)} - ${dateFormat.format(_dateRange!.end)}',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetFiltersButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPattern = null;
          _dateRange = null;
          _filteredRecords = List.from(_allRecords);
        });
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: const Text('Wyczyść filtry'),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    if (_filteredRecords.isEmpty) {
      return Center(
        child: Text(
          'Brak danych dla wybranych filtrów',
          style: GoogleFonts.poppins(),
        ),
      );
    }
    
    final totalAttempts = _filteredRecords.length;
    final acceptedBeats = _filteredRecords.where((r) => r.beatAccepted).length;
    final acceptanceRate = totalAttempts > 0 ? (acceptedBeats / totalAttempts * 100) : 0;
    final avgScore = _filteredRecords.map((r) => r.score).reduce((a, b) => a + b) / totalAttempts;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _filteredRecords.length < 10 ? 2 : 3,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          context,
          'Próby',
          '$totalAttempts',
          Icons.assignment,
          appColors.patternGradientStart,
        ),
        _buildSummaryCard(
          context,
          'Zaakceptowane',
          '$acceptedBeats (${acceptanceRate.toStringAsFixed(1)}%)',
          Icons.check_circle,
          Colors.green,
        ),
        _buildSummaryCard(
          context,
          'Średni wynik',
          avgScore.toStringAsFixed(1),
          Icons.star,
          Colors.amber,
        ),
        if (_filteredRecords.length < 10)
          _buildSummaryCard(
            context,
            'Najlepszy wynik',
            _filteredRecords.map((r) => r.score).reduce((a, b) => a > b ? a : b).toString(),
            Icons.emoji_events,
            Colors.orange,
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.4), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: appColors.navUnselectedColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: appColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    if (_filteredRecords.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Grupuj rekordy po dacie dla wykresu
    final recordsByDate = _filteredRecords.fold<Map<DateTime, List<ScoreRecord>>>(
      {},
      (map, record) {
        final date = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
        map.putIfAbsent(date, () => []).add(record);
        return map;
      },
    );
    
    final chartData = recordsByDate.entries.map((entry) {
      final avgScore = entry.value.map((r) => r.score).reduce((a, b) => a + b) / entry.value.length;
      return ChartData(entry.key, avgScore);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat('dd.MM'),
              intervalType: chartData.length > 7 ? DateTimeIntervalType.days : DateTimeIntervalType.auto,
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 5,
              interval: 1,
            ),
            series: <CartesianSeries>[
              LineSeries<ChartData, DateTime>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.date,
                yValueMapper: (ChartData data, _) => data.score,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                color: Colors.blue,
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedStatsTable() {
    if (_filteredRecords.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Data')),
              DataColumn(label: Text('Pattern')),
              DataColumn(label: Text('Wynik'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('MSE'), numeric: true),
              DataColumn(label: Text('SE'), numeric: true),
            ],
            rows: _filteredRecords
                .sorted((a, b) => b.timestamp.compareTo(a.timestamp))
                .map((record) {
              return DataRow(cells: [
                DataCell(Text(DateFormat('dd.MM.yyyy HH:mm').format(record.timestamp))),
                DataCell(Text(record.patternKey)),
                DataCell(_buildScoreStars(record.score, 20)),
                DataCell(
                  record.beatAccepted
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.close, color: Colors.red),
                ),
                DataCell(Text(record.mse.toStringAsFixed(0))),
                DataCell(Text(record.se.toStringAsFixed(0))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreStars(int score, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          color: index < score ? Colors.amber : Colors.grey.shade300,
          size: size,
        );
      }),
    );
  }
}

class ChartData {
  final DateTime date;
  final double score;

  ChartData(this.date, this.score);
}

class ScoreRecord {
  final DateTime timestamp;
  final String patternKey;
  final bool beatAccepted;
  final double mse;
  final double se;
  final int score;

  ScoreRecord({
    required this.timestamp,
    required this.patternKey,
    required this.beatAccepted,
    required this.mse,
    required this.se,
    required this.score,
  });

  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    return ScoreRecord(
      timestamp: DateTime.parse(json['timestamp']),
      patternKey: json['patternKey'],
      beatAccepted: json['beatAccepted'],
      mse: json['mse'].toDouble(),
      se: json['se'].toDouble(),
      score: json['score'],
    );
  }
}

extension Sorting on List<ScoreRecord> {
  List<ScoreRecord> sorted(int Function(ScoreRecord a, ScoreRecord b) compare) {
    final list = List<ScoreRecord>.from(this);
    list.sort(compare);
    return list;
  }
}