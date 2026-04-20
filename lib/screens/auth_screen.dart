import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  final int initialTab;
  const AuthScreen({super.key, this.initialTab = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Giriş formu için controller'lar
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Kayıt formu için controller'lar
  final _registerFormKey = GlobalKey<FormState>();
  final _adSoyadController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regPasswordTekrarController = TextEditingController();

  bool _loginSifreGoster = false;
  bool _regSifreGoster = false;
  bool _regSifreTekrarGoster = false;
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adSoyadController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regPasswordTekrarController.dispose();
    super.dispose();
  }

  // Giriş başarılı olunca dashboard'a geç
  void _dashboardaGit() async {
    setState(() => _yukleniyor = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Arka plan dekor
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.2),
                    AppTheme.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _ustBaslik(),
                const SizedBox(height: 32),
                _tabBar(),
                const SizedBox(height: 32),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _girisFormu(),
                      _kayitFormu(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Yüklenme göstergesi
          if (_yukleniyor)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ustBaslik() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SmartSpend',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Hesabına erişim sağla',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          indicator: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
          tabs: const [
            Tab(text: 'Giriş Yap'),
            Tab(text: 'Kayıt Ol'),
          ],
        ),
      ),
    );
  }

  // ── Giriş Formu ───────────────────────────────────────
  Widget _girisFormu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _etiket('E-posta'),
            const SizedBox(height: 8),
            _inputAlani(
              controller: _emailController,
              ipucu: 'ornek@email.com',
              ikon: Icons.email_outlined,
              klavyeTipi: TextInputType.emailAddress,
              dogrulama: (v) =>
                  v!.isEmpty ? 'E-posta alanı boş bırakılamaz' : null,
            ),
            const SizedBox(height: 20),
            _etiket('Şifre'),
            const SizedBox(height: 8),
            _inputAlani(
              controller: _passwordController,
              ipucu: '••••••••',
              ikon: Icons.lock_outline_rounded,
              sifreMi: true,
              sifreGoster: _loginSifreGoster,
              sifreToggle: () {
                setState(() => _loginSifreGoster = !_loginSifreGoster);
              },
              dogrulama: (v) =>
                  v!.length < 6 ? 'Şifre en az 6 karakter olmalıdır' : null,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Şifremi Unuttum?',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _anaButon('Giriş Yap', () {
              if (_loginFormKey.currentState!.validate()) {
                _dashboardaGit();
              }
            }),
            const SizedBox(height: 24),
            _ayirici(),
            const SizedBox(height: 24),
            _googleButon(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Kayıt Formu ───────────────────────────────────────
  Widget _kayitFormu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _etiket('Ad Soyad'),
            const SizedBox(height: 8),
            _inputAlani(
              controller: _adSoyadController,
              ipucu: 'Adınız Soyadınız',
              ikon: Icons.person_outline_rounded,
              dogrulama: (v) =>
                  v!.isEmpty ? 'Ad soyad boş bırakılamaz' : null,
            ),
            const SizedBox(height: 20),
            _etiket('E-posta'),
            const SizedBox(height: 8),
            _inputAlani(
              controller: _regEmailController,
              ipucu: 'ornek@email.com',
              ikon: Icons.email_outlined,
              klavyeTipi: TextInputType.emailAddress,
              dogrulama: (v) =>
                  v!.isEmpty ? 'E-posta alanı boş bırakılamaz' : null,
            ),
            const SizedBox(height: 20),
            _etiket('Şifre'),
            const SizedBox(height: 8),
            _inputAlani(
              controller: _regPasswordController,
              ipucu: '••••••••',
              ikon: Icons.lock_outline_rounded,
              sifreMi: true,
              sifreGoster: _regSifreGoster,
              sifreToggle: () {
                setState(() => _regSifreGoster = !_regSifreGoster);
              },
              dogrulama: (v) =>
                  v!.length < 6 ? 'Şifre en az 6 karakter olmalıdır' : null,
            ),
            const SizedBox(height: 20),
            _etiket('Şifre Tekrar'),
            const SizedBox(height: 8),
            _inputAlani(
              controller: _regPasswordTekrarController,
              ipucu: '••••••••',
              ikon: Icons.lock_outline_rounded,
              sifreMi: true,
              sifreGoster: _regSifreTekrarGoster,
              sifreToggle: () {
                setState(
                  () => _regSifreTekrarGoster = !_regSifreTekrarGoster,
                );
              },
              dogrulama: (v) => v != _regPasswordController.text
                  ? 'Şifreler eşleşmiyor' : null,
            ),
            const SizedBox(height: 32),
            _anaButon('Hesap Oluştur', () {
              if (_registerFormKey.currentState!.validate()) {
                _dashboardaGit();
              }
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Yardımcı Widget'lar ───────────────────────────────
  Widget _etiket(String metin) {
    return Text(
      metin,
      style: GoogleFonts.spaceGrotesk(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _inputAlani({
    required TextEditingController controller,
    required String ipucu,
    required IconData ikon,
    TextInputType? klavyeTipi,
    bool sifreMi = false,
    bool sifreGoster = false,
    VoidCallback? sifreToggle,
    String? Function(String?)? dogrulama,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: sifreMi && !sifreGoster,
      keyboardType: klavyeTipi,
      style: GoogleFonts.spaceGrotesk(
        color: AppTheme.textPrimary,
        fontSize: 15,
      ),
      validator: dogrulama,
      decoration: InputDecoration(
        hintText: ipucu,
        prefixIcon: Icon(ikon, color: AppTheme.textMuted, size: 20),
        suffixIcon: sifreMi
            ? IconButton(
                icon: Icon(
                  sifreGoster
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
                onPressed: sifreToggle,
              )
            : null,
      ),
    );
  }

  Widget _anaButon(String metin, VoidCallback tikla) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: tikla,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          metin,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _ayirici() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.cardBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.cardBorder)),
      ],
    );
  }

  Widget _googleButon() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _dashboardaGit,
        icon: const Text(
          'G',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        label: Text(
          'Google ile devam et',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: const BorderSide(color: AppTheme.cardBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}