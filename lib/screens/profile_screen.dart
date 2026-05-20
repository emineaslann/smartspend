import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../screens/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final format = NumberFormat('#,###', 'tr_TR');
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _baslik(),
                const SizedBox(height: 32),
                _profilKarti(),
                const SizedBox(height: 24),
                _istatistikKartlari(provider, format),
                const SizedBox(height: 24),
                _menuListesi(context),
                const SizedBox(height: 24),
                _cikisButonu(context),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _baslik() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Profil',
        style: GoogleFonts.spaceGrotesk(
          color: AppTheme.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _profilKarti() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'kullanici@email.com';
    final initials = email.isNotEmpty
        ? email.substring(0, 2).toUpperCase()
        : 'EA';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2740), Color(0xFF131827)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Emine Aslan',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Text(
              'SmartSpend Kullanicisi',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _istatistikKartlari(
      TransactionProvider provider, NumberFormat format) {
    return Row(
      children: [
        Expanded(
          child: _miniKart(
            'Toplam Gelir',
            '₺${format.format(provider.totalIncome)}',
            AppTheme.income,
            Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniKart(
            'Toplam Gider',
            '₺${format.format(provider.totalExpense)}',
            AppTheme.expense,
            Icons.arrow_downward_rounded,
          ),
        ),
      ],
    );
  }

  Widget _miniKart(
      String etiket, String deger, Color renk, IconData ikon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: renk.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 20),
          const SizedBox(height: 8),
          Text(
            deger,
            style: GoogleFonts.spaceGrotesk(
              color: renk,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            etiket,
            style: GoogleFonts.spaceGrotesk(
              color: renk.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuListesi(BuildContext context) {
    final menuler = [
      (Icons.person_outline_rounded, 'Hesap Bilgileri', AppTheme.primary,
          () => _hesapBilgileriDialog(context)),
      (Icons.notifications_outlined, 'Bildirimler', AppTheme.gold,
          () => _yakindaDialog(context, 'Bildirimler')),
      (Icons.security_outlined, 'Gizlilik ve Güvenlik', AppTheme.income,
          () => _yakindaDialog(context, 'Gizlilik ve Güvenlik')),
      (Icons.help_outline_rounded, 'Yardım ve Destek', AppTheme.textSecondary,
          () => _yakindaDialog(context, 'Yardım ve Destek')),
      (Icons.info_outline_rounded, 'Hakkında', AppTheme.textSecondary,
          () => _hakkindaDialog(context)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: menuler.asMap().entries.map((e) {
          final sonMu = e.key == menuler.length - 1;
          return Column(
            children: [
              ListTile(
                onTap: e.value.$4,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: e.value.$3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(e.value.$1, color: e.value.$3, size: 18),
                ),
                title: Text(
                  e.value.$2,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ),
              if (!sonMu)
                const Divider(
                  color: AppTheme.cardBorder,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _hesapBilgileriDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Hesap Bilgileri',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bilgiSatiri(Icons.email_outlined, 'E-posta',
                user?.email ?? '-'),
            const SizedBox(height: 16),
            _bilgiSatiri(Icons.calendar_today_rounded, 'Kayit Tarihi',
                user?.metadata.creationTime != null
                    ? '${user!.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}'
                    : '-'),
            const SizedBox(height: 16),
            _bilgiSatiri(Icons.verified_outlined, 'Hesap Durumu',
                'Aktif'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Kapat',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bilgiSatiri(IconData ikon, String baslik, String deger) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(ikon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              deger,
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _hakkindaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Hakkında',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '₺',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SmartSpend',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versiyon 1.0.0',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gelir ve giderlerinizi akillica yonetin. '
              'SmartSpend ile finansal hedeflerinize ulasin.',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code_rounded,
                      color: AppTheme.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Flutter ile gelistirildi',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Kapat',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _yakindaDialog(BuildContext context, String baslik) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$baslik yakinda eklenecek!',
          style: GoogleFonts.spaceGrotesk(),
        ),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _cikisButonu(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppTheme.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Cikis Yap',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                'Hesabinizdan cikis yapmak istediginize emin misiniz?',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Iptal',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.expense,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cikis Yap',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded, color: AppTheme.expense),
        label: Text(
          'Cikis Yap',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.expense,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppTheme.expense.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}