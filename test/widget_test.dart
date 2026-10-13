// test/widget_test.dart
// Pengujian widget dasar EcoGrid Dashboard
// Menguji perubahan state untuk Tap dan Long Press gesture

import 'package:flutter_test/flutter_test.dart';

import 'package:ecosmart/main.dart';

// Helper: pump widget + settle animasi dengan durasi aman
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const EcoGridApp());
  // Pump beberapa frame untuk melewati animasi awal tanpa menunggu repeat animation
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  // ─── UI Dasar ─────────────────────────────────────────────────
  group('UI Dasar', () {
    testWidgets('AppBar menampilkan nama EcoGrid', (tester) async {
      await pumpApp(tester);
      expect(find.text('EcoGrid'), findsOneWidget);
    });

    testWidgets('Panduan gesture ditampilkan', (tester) async {
      await pumpApp(tester);
      expect(find.text('Panduan Gesture'), findsOneWidget);
    });

    testWidgets('Kartu Panel Surya ditampilkan', (tester) async {
      await pumpApp(tester);
      expect(find.text('Panel Surya'), findsWidgets);
    });

    testWidgets('Kartu Turbin Angin ditampilkan', (tester) async {
      await pumpApp(tester);
      expect(find.text('Turbin Angin'), findsWidgets);
    });

    testWidgets('Kartu Baterai ditampilkan', (tester) async {
      await pumpApp(tester);
      expect(find.text('Baterai'), findsWidgets);
    });
  });

  // ─── Tap Gesture ──────────────────────────────────────────────
  group('Tap Gesture', () {
    testWidgets('Tap pada kartu mengubah status gesture', (tester) async {
      await pumpApp(tester);

      // Tap pada kartu Panel Surya
      final solarCard = find.text('Panel Surya').first;
      await tester.tap(solarCard);
      await tester.pump(const Duration(milliseconds: 300));

      // Status bar harus menunjukkan interaksi Tap
      expect(find.textContaining('Tap'), findsWidgets);
    });

    testWidgets('Tap mengubah state selectedCardIndex', (tester) async {
      await pumpApp(tester);

      // Sebelum tap: belum ada yang dipilih (tidak ada badge Dipilih)
      expect(find.textContaining('Dipilih'), findsNothing);

      // Tap pada kartu pertama
      final solarCard = find.text('Panel Surya').first;
      await tester.tap(solarCard);
      await tester.pump(const Duration(milliseconds: 300));

      // Setelah tap: badge Dipilih muncul
      expect(find.textContaining('Dipilih'), findsWidgets);
    });

    testWidgets('Tap kedua kali melepas pilihan', (tester) async {
      await pumpApp(tester);

      final solarCard = find.text('Panel Surya').first;

      // Tap pertama — pilih
      await tester.tap(solarCard);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Dipilih'), findsWidgets);

      // Tap kedua — lepas pilihan
      await tester.tap(solarCard);
      await tester.pump(const Duration(milliseconds: 300));

      // Badge Dipilih hilang (kartu dilepas)
      expect(find.textContaining('dilepas'), findsWidgets);
    });
  });

  // ─── Long Press Gesture ───────────────────────────────────────
  group('Long Press Gesture', () {
    testWidgets('Long Press mengubah status gesture', (tester) async {
      await pumpApp(tester);

      final solarCard = find.text('Panel Surya').first;
      await tester.longPress(solarCard);
      await tester.pump(const Duration(milliseconds: 300));

      // Status bar harus menampilkan Long Press
      expect(find.textContaining('Long Press'), findsWidgets);
    });

    testWidgets('Long Press membuka bottom sheet (tombol Tutup tampil)', (tester) async {
      await pumpApp(tester);

      final solarCard = find.text('Panel Surya').first;
      await tester.longPress(solarCard);
      // Beri waktu bottom sheet muncul
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Tombol Tutup harus tersedia
      expect(find.text('Tutup'), findsOneWidget);
    });

    testWidgets('Bottom sheet dapat ditutup via tombol Tutup', (tester) async {
      await pumpApp(tester);

      final solarCard = find.text('Panel Surya').first;
      await tester.longPress(solarCard);
      // Beri waktu bottom sheet muncul sepenuhnya
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Pastikan tombol Tutup ada sebelum di-tap
      expect(find.text('Tutup'), findsOneWidget);

      // Tutup bottom sheet
      await tester.tap(find.text('Tutup'));
      // Animasi dismiss bottom sheet memerlukan beberapa frame
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));

      // Sheet seharusnya sudah hilang
      expect(find.text('Tutup'), findsNothing);
    });
  });
}
