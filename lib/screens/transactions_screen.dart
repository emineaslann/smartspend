import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // Seçili filtre: Tümü, Gelir veya Gider
  String _secilenFiltre = 'Tümü';
  String? _secilenKategori;
  final _format = NumberFormat('#,###', 'tr_TR');

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        // Filtreye göre işlemleri getir
        List<Transaction> filtrelenmis;
        if (_secilenFiltre == 'Gelir') {
          filtrelenmis = provider.filterTransactions(type: 'income');
        } else if (_secilenFiltre == 'Gider') {
          filtrelenmis = provider.filterTransactions(type: 'expense');
        } else {
          filtrelenmis = provider.sortedTransactions;
        }

        // Kategori filtresi de seçildiyse uygula
        if (_secilenKategori != null) {
          filtrelenmis = filtrelenmis
              .where((t) => t.category == _secilenKategori)
              .toList();
        }

        return SafeArea(
          child: Column(
            children: [
              _ustBaslik(context),
              _filtreSecenekleri(),
              if (_secilenKategori != null) _kategoriEtiketi(),
              const SizedBox(height: 8),
              Expanded(
                child: filtrelenmis.isEmpty
                    ? _bosEkran()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtrelenmis.length,
                        itemBuilder: (context, i) {
                          return _islemKarti(
                            context,
                            filtrelenmis[i],
                            provider,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ustBaslik(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'İşlemler',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          // Kategori filtre butonu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: PopupMenuButton<String>(
              color: AppTheme.surfaceElevated,
              icon: const Icon(
                Icons.filter_list_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              onSelected: (secilen) {
                setState(() {
                  _secilenKategori =
                      secilen == 'Tümü' ? null : secilen;
                });
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'Tümü',
                  child: Text('Tüm kategoriler'),
                ),
                ...TransactionCategories.incomeCategories.map(
                  (k) => PopupMenuItem(value: k, child: Text(k)),
                ),
                ...TransactionCategories.expenseCategories.map(
                  (k) => PopupMenuItem(value: k, child: Text(k)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtreSecenekleri() {
    final filtreler = ['Tümü', 'Gelir', 'Gider'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filtreler.map((f) {
          final aktif = _secilenFiltre == f;
          Color renk;
          if (f == 'Gelir') renk = AppTheme.income;
          else if (f == 'Gider') renk = AppTheme.expense;
          else renk = AppTheme.primary;

          return GestureDetector(
            onTap: () => setState(() => _secilenFiltre = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: aktif
                    ? renk.withOpacity(0.15)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: aktif ? renk : AppTheme.cardBorder,
                ),
              ),
              child: Text(
                f,
                style: GoogleFonts.spaceGrotesk(
                  color: aktif ? renk : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Seçili kategori varsa üstte etiket göster
  Widget _kategoriEtiketi() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.goldLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.gold.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _secilenKategori ?? '',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () =>
                      setState(() => _secilenKategori = null),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.gold,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _islemKarti(
    BuildContext context,
    Transaction t,
    TransactionProvider provider,
  ) {
    final gelirMi = t.isIncome;
    final renk = gelirMi ? AppTheme.income : AppTheme.expense;
    final arkaplan =
        gelirMi ? AppTheme.incomeLight : AppTheme.expenseLight;
    final tarih =
        DateFormat('dd MMM yyyy', 'tr_TR').format(t.date);

    // Sola kaydırınca sil butonu çıksın
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.expense.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppTheme.expense,
          size: 24,
        ),
      ),
      onDismissed: (_) => provider.deleteTransaction(t.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            // Kategori ikonu
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: arkaplan,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(
                  TransactionCategories.getCategoryIcon(
                      t.category),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.category,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        tarih,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (t.note.isNotEmpty) ...[
                        const Text(
                          '  ·  ',
                          style:
                              TextStyle(color: AppTheme.textMuted),
                        ),
                        Expanded(
                          child: Text(
                            t.note,
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${gelirMi ? '+' : '-'}₺${_format.format(t.amount)}',
                  style: GoogleFonts.spaceGrotesk(
                    color: renk,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: arkaplan,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    gelirMi ? 'Gelir' : 'Gider',
                    style: GoogleFonts.spaceGrotesk(
                      color: renk,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bosEkran() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Henüz işlem yok',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni işlem eklemek için + butonuna bas',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}