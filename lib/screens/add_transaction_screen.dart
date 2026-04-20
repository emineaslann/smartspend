import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  String _tur = 'expense'; // expense veya income
  String? _secilenKategori;
  DateTime _secilenTarih = DateTime.now();
  final _tutarController = TextEditingController();
  final _notController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _tutarController.dispose();
    _notController.dispose();
    super.dispose();
  }

  // Seçili türe göre kategoriler değişsin
  List<String> get _kategoriler => _tur == 'income'
      ? TransactionCategories.incomeCategories
      : TransactionCategories.expenseCategories;

  // Seçili türe göre renk değişsin
  Color get _turRengi =>
      _tur == 'income' ? AppTheme.income : AppTheme.expense;

  Future<void> _tarihSec() async {
    final secilen = await showDatePicker(
      context: context,
      initialDate: _secilenTarih,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: AppTheme.surfaceElevated,
            ),
          ),
          child: child!,
        );
      },
    );
    if (secilen != null) {
      setState(() => _secilenTarih = secilen);
    }
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;

    if (_secilenKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen bir kategori seçin',
            style: GoogleFonts.spaceGrotesk(),
          ),
          backgroundColor: AppTheme.expense,
        ),
      );
      return;
    }

    final tutar = double.tryParse(
      _tutarController.text.replaceAll(',', '.'),
    );
    if (tutar == null || tutar <= 0) return;

    await context.read<TransactionProvider>().addTransaction(
          amount: tutar,
          type: _tur,
          category: _secilenKategori!,
          date: _secilenTarih,
          note: _notController.text.trim(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'İşlem başarıyla eklendi ✓',
            style: GoogleFonts.spaceGrotesk(),
          ),
          backgroundColor: AppTheme.income,
          duration: const Duration(seconds: 2),
        ),
      );
      // Formu sıfırla
      _tutarController.clear();
      _notController.clear();
      setState(() {
        _secilenKategori = null;
        _secilenTarih = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _baslik(),
                const SizedBox(height: 28),
                _turSecimi(),
                const SizedBox(height: 24),
                _tutarAlani(),
                const SizedBox(height: 20),
                _kategoriBaslik(),
                const SizedBox(height: 12),
                _kategoriSecimi(),
                const SizedBox(height: 20),
                _tarihSecimi(),
                const SizedBox(height: 20),
                _notAlani(),
                const SizedBox(height: 32),
                _kaydetButonu(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _baslik() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yeni İşlem',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Gelir veya gider ekle',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _turSecimi() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          _turButonu(
            'expense',
            'Gider',
            Icons.arrow_downward_rounded,
            AppTheme.expense,
          ),
          _turButonu(
            'income',
            'Gelir',
            Icons.arrow_upward_rounded,
            AppTheme.income,
          ),
        ],
      ),
    );
  }

  Widget _turButonu(
      String deger, String etiket, IconData ikon, Color renk) {
    final aktif = _tur == deger;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tur = deger;
            _secilenKategori = null; // kategoriyi sıfırla
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: aktif ? renk.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: aktif
                ? Border.all(color: renk.withOpacity(0.4))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ikon,
                color: aktif ? renk : AppTheme.textMuted,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                etiket,
                style: GoogleFonts.spaceGrotesk(
                  color: aktif ? renk : AppTheme.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tutarAlani() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tutar',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tutarController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          style: GoogleFonts.spaceGrotesk(
            color: _turRengi,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            prefixText: '₺ ',
            prefixStyle: GoogleFonts.spaceGrotesk(
              color: _turRengi,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            hintText: '0',
            hintStyle: GoogleFonts.spaceGrotesk(
              color: AppTheme.textMuted,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            filled: true,
            fillColor: _turRengi.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: _turRengi.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: _turRengi.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _turRengi, width: 2),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Tutar giriniz';
            final tutar =
                double.tryParse(v.replaceAll(',', '.'));
            if (tutar == null || tutar <= 0) {
              return 'Geçerli bir tutar girin';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _kategoriBaslik() {
    return Text(
      'Kategori',
      style: GoogleFonts.spaceGrotesk(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _kategoriSecimi() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kategoriler.map((k) {
        final aktif = _secilenKategori == k;
        return GestureDetector(
          onTap: () => setState(() => _secilenKategori = k),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: aktif
                  ? _turRengi.withOpacity(0.15)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: aktif
                    ? _turRengi.withOpacity(0.5)
                    : AppTheme.cardBorder,
                width: aktif ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TransactionCategories.getCategoryIcon(k),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  k,
                  style: GoogleFonts.spaceGrotesk(
                    color: aktif
                        ? _turRengi
                        : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: aktif
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _tarihSecimi() {
    return GestureDetector(
      onTap: _tarihSec,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarih',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  DateFormat('dd MMMM yyyy', 'tr_TR')
                      .format(_secilenTarih),
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notAlani() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Not (isteğe bağlı)',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notController,
          maxLines: 2,
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: const InputDecoration(
            hintText: 'Açıklama girin...',
            prefixIcon: Icon(
              Icons.notes_rounded,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _kaydetButonu() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _kaydet,
        style: ElevatedButton.styleFrom(
          backgroundColor: _turRengi,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tur == 'income'
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _tur == 'income' ? 'Gelir Ekle' : 'Gider Ekle',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}