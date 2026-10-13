// lib/widgets/energy_contribution_chart.dart
// Grafik kontribusi surya vs angin menggunakan CustomPainter

import 'package:flutter/material.dart';

/// Menampilkan grafik bar kontribusi energi solar dan angin.
class EnergyContributionChart extends StatelessWidget {
  final double solarPercent;
  final double windPercent;
  final double solarKwh;
  final double windKwh;

  const EnergyContributionChart({
    super.key,
    required this.solarPercent,
    required this.windPercent,
    required this.solarKwh,
    required this.windKwh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kontribusi Sumber Energi',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withAlpha(70)),
                ),
                child: const Text(
                  '⚡ Data Simulasi',
                  style: TextStyle(color: Colors.amber, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Solar bar
          _BarRow(
            label: 'Panel Surya',
            icon: Icons.wb_sunny_rounded,
            color: const Color(0xFFFFC107),
            percent: solarPercent,
            kwh: solarKwh,
          ),
          const SizedBox(height: 10),
          // Wind bar
          _BarRow(
            label: 'Turbin Angin',
            icon: Icons.air_rounded,
            color: const Color(0xFF4FC3F7),
            percent: windPercent,
            kwh: windKwh,
          ),
          const SizedBox(height: 14),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LayoutBuilder(
              builder: (_, constraints) {
                final total = solarPercent + windPercent;
                final solarW = total > 0
                    ? constraints.maxWidth * (solarPercent / total)
                    : 0.0;
                final windW = total > 0
                    ? constraints.maxWidth * (windPercent / total)
                    : 0.0;
                return Row(
                  children: [
                    Container(
                      width: solarW,
                      height: 12,
                      color: const Color(0xFFFFC107),
                    ),
                    Container(
                      width: windW,
                      height: 12,
                      color: const Color(0xFF4FC3F7),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double percent;
  final double kwh;

  const _BarRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.percent,
    required this.kwh,
  });

  @override
  Widget build(BuildContext context) {
    final pct = percent.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 11)),
            const Spacer(),
            Text(
              '${pct.toStringAsFixed(1)}%  ·  ${kwh.toStringAsFixed(1)} kWh/hari',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100.0,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
