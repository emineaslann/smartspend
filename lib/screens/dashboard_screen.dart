import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'transactions_screen.dart';
import 'add_transaction_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _secilenIndex = 0;

  final List<Widget> _ekranlar = const [
    _DashboardIcerigi(),
    TransactionsScreen(),
    AddTransactionScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _ekranlar[_secilenIndex],
      floatingActionButton: _secilenIndex != 2
          ? FloatingActionButton(
              onPressed: () => setState(() => _secilenIndex = 2),
              backgroundColor: AppTheme.primary,
              elevation: 8,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _altNavigasyon(),
    );
  }

  Widget _altNavigasyon() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          top: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navButon(Icons.home_rounded, 'Ana Sayfa', 0),
              _navButon(Icons.receipt_long_rounded, 'İşlemler', 1),
              const SizedBox(width: 48),
              _navButon(Icons.bar_chart_rounded, 'İstatistik', 3),
              _navButon(Icons.person_outline_rounded, 'Profil', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButon(IconData ikon, String etiket, int index) {
    final aktif = _secilenIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _secilenIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: aktif
              ? AppTheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ikon,
              color: aktif ? AppTheme.primary : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              etiket,
              style: GoogleFonts.spaceGrotesk(
                color:
                    aktif ? AppTheme.primary : AppTheme.textMuted,
                fontSize: 10,
                fontWeight:
                    aktif ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard Ana İçeriği ─────────────────────────────────
class _DashboardIcerigi extends StatelessWidget {
  const _DashboardIcerigi();

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _ustBaslik()),
              SliverToBoxAdapter(child: _bakiyeKarti(provider)),
              SliverToBoxAdapter(
                  child: _gelirGiderSatiri(provider)),
              SliverToBoxAdapter(child: _grafikBolumu(provider)),
              SliverToBoxAdapter(
                  child: _sonIslemler(context, provider)),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _ustBaslik() {
    final simdi = DateTime.now();
    final ayAdi = DateFormat('MMMM yyyy', 'tr_TR').format(simdi);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba 👋',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Dashboard',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppTheme.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  ayAdi,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bakiyeKarti(TransactionProvider provider) {
    final format = NumberFormat('#,###', 'tr_TR');
    final tasarrufOrani = provider.thisMonthIncome > 0
        ? (provider.thisMonthBalance / provider.thisMonthIncome)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2740), Color(0xFF131827)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aylık Net Bakiye',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₺${format.format(provider.thisMonthBalance)}',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.income.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Bu ay',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.income,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: tasarrufOrani,
              backgroundColor: AppTheme.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.income),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gelirinin %${(tasarrufOrani * 100).toStringAsFixed(0)}\'ini tasarruf ediyorsun',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gelirGiderSatiri(TransactionProvider provider) {
    final format = NumberFormat('#,###', 'tr_TR');
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: _ozedKart(
              'Gelir',
              '₺${format.format(provider.thisMonthIncome)}',
              Icons.arrow_upward_rounded,
              AppTheme.income,
              AppTheme.incomeLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ozedKart(
              'Gider',
              '₺${format.format(provider.thisMonthExpense)}',
              Icons.arrow_downward_rounded,
              AppTheme.expense,
              AppTheme.expenseLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ozedKart(String etiket, String deger, IconData ikon,
      Color renk, Color arkaplan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: arkaplan,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ikon, color: renk, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiket,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                deger,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _grafikBolumu(TransactionProvider provider) {
    final giderler = provider.expenseByCategory;
    if (giderler.isEmpty) return const SizedBox.shrink();

    final renkler = [
      AppTheme.primary,
      AppTheme.income,
      AppTheme.gold,
      AppTheme.expense,
      const Color(0xFF4ECDC4),
      const Color(0xFFFF6B9D),
    ];

    final liste = giderler.entries.toList();
    final toplam = liste.fold(0.0, (t, e) => t + e.value);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
            'Harcama Dağılımı',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: liste.asMap().entries.map((e) {
                      return PieChartSectionData(
                        value: e.value.value,
                        color: renkler[e.key % renkler.length],
                        radius: 30,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: liste.asMap().entries.map((e) {
                    final yuzde =
                        (e.value.value / toplam * 100)
                            .toStringAsFixed(0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: renkler[
                                  e.key % renkler.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.value.key,
                              style: GoogleFonts.spaceGrotesk(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '%$yuzde',
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sonIslemler(
      BuildContext context, TransactionProvider provider) {
    final format = NumberFormat('#,###', 'tr_TR');
    final sonIslemler =
        provider.sortedTransactions.take(5).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son İşlemler',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Tümünü Gör',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sonIslemler.map((t) => _islemSatiri(t, format)),
        ],
      ),
    );
  }

  Widget _islemSatiri(Transaction t, NumberFormat format) {
    final gelirMi = t.isIncome;
    final renk = gelirMi ? AppTheme.income : AppTheme.expense;
    final arkaplan =
        gelirMi ? AppTheme.incomeLight : AppTheme.expenseLight;
    final tarih =
        DateFormat('dd MMM', 'tr_TR').format(t.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: arkaplan,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                TransactionCategories.getCategoryIcon(
                    t.category),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.category,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  t.note.isEmpty ? tarih : t.note,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${gelirMi ? '+' : '-'}₺${format.format(t.amount)}',
                style: GoogleFonts.spaceGrotesk(
                  color: renk,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                tarih,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}