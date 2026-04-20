import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  // Tüm işlemlerin tutulduğu liste
  List<Transaction> _transactions = [];
  final _uuid = const Uuid();

  // Dışarıdan sadece okuma yapılabilsin diye getter
  List<Transaction> get transactions => _transactions;

  // Tarihe göre sıralı liste (en yeni en üstte)
  List<Transaction> get sortedTransactions {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  // ── Genel hesaplamalar ────────────────────────────────
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  // ── Bu aya ait hesaplamalar ───────────────────────────
  List<Transaction> get thisMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((t) {
      return t.date.month == now.month && t.date.year == now.year;
    }).toList();
  }

  double get thisMonthIncome => thisMonthTransactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get thisMonthExpense => thisMonthTransactions
      .where((t) => t.isExpense)
      .fold(0, (sum, t) => sum + t.amount);

  double get thisMonthBalance => thisMonthIncome - thisMonthExpense;

  // Bu ayki giderlerin kategoriye göre dağılımı (grafik için)
  Map<String, double> get expenseByCategory {
    final Map<String, double> result = {};
    for (final t in thisMonthTransactions.where((t) => t.isExpense)) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  // Kurucu metod — uygulama açılınca kayıtlı verileri yükle
  TransactionProvider() {
    _loadFromStorage();
  }

  // ── İşlem Ekle ────────────────────────────────────────
  Future<void> addTransaction({
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    required String note,
  }) async {
    final yeniIslem = Transaction(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );
    _transactions.add(yeniIslem);
    await _saveToStorage();
    notifyListeners(); // ekranları güncelle
  }

  // ── İşlem Sil ─────────────────────────────────────────
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  // ── Filtreleme ────────────────────────────────────────
  List<Transaction> filterTransactions({
    String? type,
    String? category,
  }) {
    return sortedTransactions.where((t) {
      if (type != null && t.type != type) return false;
      if (category != null && t.category != category) return false;
      return true;
    }).toList();
  }

  // ── Yerel Depolama ────────────────────────────────────
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _transactions.map((t) => t.toMap()).toList();
    await prefs.setString('transactions', json.encode(data));
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('transactions');

    if (data != null) {
      final List<dynamic> liste = json.decode(data);
      _transactions = liste
          .map((item) => Transaction.fromMap(item))
          .toList();
      notifyListeners();
    } else {
      // İlk açılışta örnek veriler yükle
      _ornekVerileriYukle();
    }
  }

  // Uygulama ilk açıldığında boş görünmesin diye örnek veriler
  void _ornekVerileriYukle() {
    final now = DateTime.now();
    final ornekler = [
      Transaction(
        id: _uuid.v4(),
        amount: 15000,
        type: 'income',
        category: 'Maaş',
        date: DateTime(now.year, now.month, 1),
        note: 'Aylık maaş',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 3000,
        type: 'income',
        category: 'Freelance',
        date: DateTime(now.year, now.month, 5),
        note: 'Web sitesi projesi',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 1200,
        type: 'expense',
        category: 'Market',
        date: DateTime(now.year, now.month, 3),
        note: 'Haftalık alışveriş',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 450,
        type: 'expense',
        category: 'Restoran',
        date: DateTime(now.year, now.month, 7),
        note: 'Arkadaş yemeği',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 800,
        type: 'expense',
        category: 'Faturalar',
        date: DateTime(now.year, now.month, 4),
        note: 'Elektrik ve internet',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 320,
        type: 'expense',
        category: 'Ulaşım',
        date: DateTime(now.year, now.month, 6),
        note: 'Akbil yüklemesi',
      ),
    ];

    _transactions.addAll(ornekler);
    _saveToStorage();
    notifyListeners();
  }
}