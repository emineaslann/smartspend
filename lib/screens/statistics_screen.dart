import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _format = NumberFormat('#,###', 'tr_TR');
  int _dokunulanDilim = -1;

  final List<Color> _renkler = [
    AppTheme.primary,
    AppTheme.income,
    AppTheme.gold,
    AppTheme.expense,
    const Color(0xFF4ECDC4),
    const Color(0xFFFF6B9D),
    const Color(0xFF95E1D3),
    const Color(0xFFF38181),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _ustBaslik()),
              SliverToBoxAdapter(child: _ozedKartlar(provider)),
              SliverToBoxAdapter(child: _barGrafik(provider)),
              SliverToBoxAdapter(child: _pastaGrafik(provider)),
              SliverToBoxAdapter(child: _kategoriDetay(provider)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _ustBaslik() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İstatistikler',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Bu aylık finansal özet',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ozedKartlar(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _ozedKart(
              'Toplam Gelir',
              '₺${_format.format(provider.thisMonthIncome)}',
              AppTheme.income,
              Icons.trending_up_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ozedKart(
              'Toplam Gider',
              '₺${_format.format(provider.thisMonthExpense)}',
              AppTheme.expense,
              Icons.trending_down_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ozedKart(
      String etiket, String deger, Color renk, IconData ikon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: renk.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 24),
          const SizedBox(height: 8),
          Text(
            deger,
            style: GoogleFonts.spaceGrotesk(
              color: renk,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            etiket,
            style: GoogleFonts.spaceGrotesk(
              color: renk.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barGrafik(TransactionProvider provider) {
    final simdi = DateTime.now();
    // Son 7 günün verilerini topla
    final Map<int, double> gelirGunluk = {};
    final Map<int, double> giderGunluk = {};

    for (int i = 0; i <= 6; i++) {
      gelirGunluk[i] = 0;
      giderGunluk[i] = 0;
    }

    for (final t in provider.transactions) {
      final fark = simdi.difference(t.date).inDays;
      if (fark >= 0 && fark <= 6) {
        if (t.isIncome) {
          gelirGunluk[fark] = (gelirGunluk[fark] ?? 0) + t.amount;
        } else {
          giderGunluk[fark] = (giderGunluk[fark] ?? 0) + t.amount;
        }
      }
    }

    final maksimum = [
      ...gelirGunluk.values,
      ...giderGunluk.values,
    ].fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son 7 Gün',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _graffikAciklama(AppTheme.income, 'Gelir'),
              const SizedBox(width: 16),
              _graffikAciklama(AppTheme.expense, 'Gider'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maksimum == 0 ? 100 : maksimum * 1.3,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppTheme.cardBorder,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (deger, meta) {
                        final gun = deger.toInt();
                        final tarih = simdi.subtract(
                          Duration(days: gun),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('dd/MM').format(tarih),
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: gelirGunluk[i] ?? 0,
                        color: AppTheme.income,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: giderGunluk[i] ?? 0,
                        color: AppTheme.expense,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _graffikAciklama(Color renk, String etiket) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: renk,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          etiket,
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _pastaGrafik(TransactionProvider provider) {
    final giderler = provider.expenseByCategory;
    if (giderler.isEmpty) return const SizedBox.shrink();

    final liste = giderler.entries.toList();
    final toplam = liste.fold(0.0, (t, e) => t + e.value);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gider Kategorileri',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 55,
                centerSpaceColor: AppTheme.surface,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (response?.touchedSection != null) {
                        _dokunulanDilim = response!
                            .touchedSection!
                            .touchedSectionIndex;
                      } else {
                        _dokunulanDilim = -1;
                      }
                    });
                  },
                ),
                sections: liste.asMap().entries.map((e) {
                  final dokunuldu = e.key == _dokunulanDilim;
                  return PieChartSectionData(
                    value: e.value.value,
                    color: _renkler[e.key % _renkler.length],
                    radius: dokunuldu ? 45 : 35,
                    showTitle: dokunuldu,
                    title: dokunuldu
                        ? '%${(e.value.value / toplam * 100).toStringAsFixed(0)}'
                        : '',
                    titleStyle: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Renk açıklamaları
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: liste.asMap().entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _renkler[e.key % _renkler.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.value.key,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _kategoriDetay(TransactionProvider provider) {
    final giderler = provider.expenseByCategory;
    if (giderler.isEmpty) return const SizedBox.shrink();

    // Büyükten küçüğe sırala
    final liste = giderler.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final toplam = liste.fold(0.0, (t, e) => t + e.value);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Detayı',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...liste.asMap().entries.map((e) {
            final oran = e.value.value / toplam;
            final renk = _renkler[e.key % _renkler.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            TransactionCategories
                                .getCategoryIcon(e.value.key),
                            style:
                                const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e.value.key,
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₺${_format.format(e.value.value)}',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.expense,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: oran,
                      backgroundColor: renk.withOpacity(0.1),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(renk),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}