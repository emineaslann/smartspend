import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartspend/models/transaction.dart';
import 'package:smartspend/providers/transaction_provider.dart';
import 'package:smartspend/screens/welcome_screen.dart';
import 'package:smartspend/screens/auth_screen.dart';
import 'package:smartspend/theme/app_theme.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget uygulamaOlustur(Widget ekran) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: ekran,
      ),
    );
  }

  group('Karşılama Ekranı Testleri', () {
    testWidgets('TC-01: SmartSpend başlığı görünüyor mu',
        (WidgetTester tester) async {
      await tester.pumpWidget(uygulamaOlustur(const WelcomeScreen()));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('SmartSpend'), findsOneWidget);
    });

    testWidgets('TC-02: Giriş Yap butonu görünüyor mu',
        (WidgetTester tester) async {
      await tester.pumpWidget(uygulamaOlustur(const WelcomeScreen()));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Giriş Yap'), findsOneWidget);
    });

    testWidgets('TC-03: Kayıt Ol butonu görünüyor mu',
        (WidgetTester tester) async {
      await tester.pumpWidget(uygulamaOlustur(const WelcomeScreen()));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Kayıt Ol'), findsOneWidget);
    });

    testWidgets('TC-04: Giriş Yap butonuna tıklanınca Auth ekranı açılıyor mu',
        (WidgetTester tester) async {
      await tester.pumpWidget(uygulamaOlustur(const WelcomeScreen()));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Giriş Yap'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(AuthScreen), findsOneWidget);
    });
  });

  group('Giriş Ekranı Testleri', () {
    testWidgets('TC-05: E-posta alanı görünüyor mu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          uygulamaOlustur(const AuthScreen(initialTab: 0)));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('E-posta'), findsOneWidget);
    });

    testWidgets('TC-06: Şifre alanı görünüyor mu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          uygulamaOlustur(const AuthScreen(initialTab: 0)));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Şifre'), findsOneWidget);
    });

    testWidgets('TC-07: Boş form ile giriş yapılınca hata mesajı çıkıyor mu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          uygulamaOlustur(const AuthScreen(initialTab: 0)));
      await tester.pump(const Duration(seconds: 1));
      final girisButonu = find.widgetWithText(ElevatedButton, 'Giriş Yap');
      await tester.tap(girisButonu);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('E-posta alanı boş bırakılamaz'), findsOneWidget);
    });

    testWidgets('TC-08: Kısa şifre girilince hata mesajı çıkıyor mu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          uygulamaOlustur(const AuthScreen(initialTab: 0)));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(
          find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      final girisButonu = find.widgetWithText(ElevatedButton, 'Giriş Yap');
      await tester.tap(girisButonu);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Şifre en az 6 karakter olmalıdır'), findsOneWidget);
    });
  });

  group('Transaction Model Testleri', () {
    test('TC-09: Gelir işlemi doğru oluşturuluyor mu', () {
      final islem = Transaction(
        id: '1',
        amount: 5000,
        type: 'income',
        category: 'Maaş',
        date: DateTime.now(),
        note: 'Test geliri',
      );
      expect(islem.isIncome, true);
      expect(islem.isExpense, false);
      expect(islem.amount, 5000);
      expect(islem.category, 'Maaş');
    });

    test('TC-10: Gider işlemi doğru oluşturuluyor mu', () {
      final islem = Transaction(
        id: '2',
        amount: 250,
        type: 'expense',
        category: 'Market',
        date: DateTime.now(),
        note: 'Test gideri',
      );
      expect(islem.isExpense, true);
      expect(islem.isIncome, false);
      expect(islem.amount, 250);
    });

    test('TC-11: Transaction toMap ve fromMap doğru çalışıyor mu', () {
      final islem = Transaction(
        id: 'test-123',
        amount: 1500,
        type: 'income',
        category: 'Freelance',
        date: DateTime(2024, 1, 15),
        note: 'Proje ödemesi',
      );
      final map = islem.toMap();
      final geriYuklenen = Transaction.fromMap(map);
      expect(geriYuklenen.id, islem.id);
      expect(geriYuklenen.amount, islem.amount);
      expect(geriYuklenen.type, islem.type);
      expect(geriYuklenen.category, islem.category);
      expect(geriYuklenen.note, islem.note);
    });

    test('TC-12: Kategori ikonları doğru döndürülüyor mu', () {
      expect(TransactionCategories.getCategoryIcon('Market'), '🛒');
      expect(TransactionCategories.getCategoryIcon('Maaş'), '💼');
      expect(TransactionCategories.getCategoryIcon('Restoran'), '🍽️');
    });
  });

  group('TransactionProvider Testleri', () {
    test('TC-13: Başlangıçta işlem listesi boş değil mi', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = TransactionProvider();
      await Future.delayed(const Duration(milliseconds: 500));
      expect(provider.transactions, isNotNull);
    });

    test('TC-14: Gelir ve gider hesaplamaları doğru mu', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = TransactionProvider();
      await Future.delayed(const Duration(milliseconds: 500));
      final bakiye = provider.thisMonthIncome - provider.thisMonthExpense;
      expect(provider.thisMonthBalance, bakiye);
    });

    test('TC-15: İşlem ekleme çalışıyor mu', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = TransactionProvider();
      await Future.delayed(const Duration(milliseconds: 500));
      final baslangicSayisi = provider.transactions.length;
      await provider.addTransaction(
        amount: 3000,
        type: 'income',
        category: 'Maaş',
        date: DateTime.now(),
        note: 'Test işlemi',
      );
      expect(provider.transactions.length, baslangicSayisi + 1);
    });

    test('TC-16: İşlem silme çalışıyor mu', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = TransactionProvider();
      await Future.delayed(const Duration(milliseconds: 500));
      await provider.addTransaction(
        amount: 500,
        type: 'expense',
        category: 'Market',
        date: DateTime.now(),
        note: 'Silinecek işlem',
      );
      final eklenenId = provider.sortedTransactions.first.id;
      final oncekiSayi = provider.transactions.length;
      await provider.deleteTransaction(eklenenId);
      expect(provider.transactions.length, oncekiSayi - 1);
    });

    test('TC-17: Filtreleme doğru çalışıyor mu', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = TransactionProvider();
      await Future.delayed(const Duration(milliseconds: 500));
      final sadecGelir = provider.filterTransactions(type: 'income');
      final sadecGider = provider.filterTransactions(type: 'expense');
      expect(sadecGelir.every((t) => t.isIncome), true);
      expect(sadecGider.every((t) => t.isExpense), true);
    });
  });
}