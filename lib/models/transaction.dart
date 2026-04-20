class Transaction {
  final String id;
  final double amount;
  final String type; // 'income' veya 'expense'
  final String category;
  final DateTime date;
  final String note;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  // Kaydetmek için Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  // Map'ten Transaction oluştur
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      note: map['note'],
    );
  }
}

// ── Kategoriler ───────────────────────────────────────────
class TransactionCategories {
  static const List<String> incomeCategories = [
    'Maaş', 'Freelance', 'Yatırım',
    'Kira Geliri', 'Hediye', 'Diğer Gelir',
  ];

  static const List<String> expenseCategories = [
    'Market', 'Restoran', 'Ulaşım', 'Sağlık',
    'Eğlence', 'Faturalar', 'Alışveriş',
    'Eğitim', 'Diğer Gider',
  ];

  static String getCategoryIcon(String category) {
    const icons = {
      'Maaş': '💼', 'Freelance': '💻', 'Yatırım': '📈',
      'Kira Geliri': '🏠', 'Hediye': '🎁', 'Diğer Gelir': '💰',
      'Market': '🛒', 'Restoran': '🍽️', 'Ulaşım': '🚗',
      'Sağlık': '💊', 'Eğlence': '🎬', 'Faturalar': '📄',
      'Alışveriş': '🛍️', 'Eğitim': '📚', 'Diğer Gider': '💸',
    };
    return icons[category] ?? '💳';
  }
}