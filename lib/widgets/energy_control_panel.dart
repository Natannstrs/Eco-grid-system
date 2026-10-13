// lib/widgets/energy_control_panel.dart
// Panel kontrol simulasi: tambah/kurang perangkat, slider parameter, reset

import 'package:flutter/material.dart';
import '../models/energy_simulation.dart';

/// Panel kontrol untuk mengubah parameter simulasi energi.
/// Semua perubahan langsung memanggil [onChanged] agar Dashboard
/// menghitung ulang energi.
class EnergyControlPanel extends StatelessWidget {
  final EnergySimulation sim;
  final VoidCallback onChanged;

  const EnergyControlPanel({
    super.key,
    required this.sim,
    required this.onChanged,
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
            children: [
              const Icon(Icons.tune, color: Color(0xFF69F0AE), size: 16),
              const SizedBox(width: 8),
              const Text(
                'Kontrol Simulasi',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const Spacer(),
              // Tombol Reset
              GestureDetector(
                onTap: () {
                  sim.reset();
                  onChanged();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withAlpha(80)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.redAccent, size: 13),
                      SizedBox(width: 4),
                      Text('Reset',
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Panel Surya ──────────────────────────────────────────
          _SectionTitle(
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFFFFC107),
              label: 'Panel Surya'),
          const SizedBox(height: 10),
          _CounterRow(
            label: 'Jumlah Panel',
            value: sim.solarPanelCount,
            min: EnergySimulation.minPanels,
            max: EnergySimulation.maxPanels,
            color: const Color(0xFFFFC107),
            onDecrement: () {
              if (sim.solarPanelCount > EnergySimulation.minPanels) {
                sim.solarPanelCount--;
                onChanged();
              }
            },
            onIncrement: () {
              if (sim.solarPanelCount < EnergySimulation.maxPanels) {
                sim.solarPanelCount++;
                onChanged();
              }
            },
          ),
          const SizedBox(height: 10),
          _SliderRow(
            label: 'Kapasitas Panel',
            value: sim.solarPanelPowerWp,
            min: EnergySimulation.minPanelPower,
            max: EnergySimulation.maxPanelPower,
            divisions: 12,
            unit: 'Wp',
            color: const Color(0xFFFFC107),
            onChanged: (v) {
              sim.solarPanelPowerWp = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: 'Jam Matahari Efektif',
            value: sim.effectiveSunHours,
            min: EnergySimulation.minSunHours,
            max: EnergySimulation.maxSunHours,
            divisions: 18,
            unit: 'jam/hari',
            color: const Color(0xFFFFC107),
            onChanged: (v) {
              sim.effectiveSunHours = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: 'Performance Ratio',
            value: sim.performanceRatio,
            min: EnergySimulation.minPerfRatio,
            max: EnergySimulation.maxPerfRatio,
            divisions: 10,
            unit: '',
            color: const Color(0xFFFFC107),
            onChanged: (v) {
              sim.performanceRatio = v;
              onChanged();
            },
          ),
          const SizedBox(height: 6),
          // Toggle Solar
          _ToggleRow(
            label: 'Panel Surya',
            value: sim.solarActive,
            color: const Color(0xFFFFC107),
            onChanged: (v) {
              sim.solarActive = v;
              onChanged();
            },
          ),
          const SizedBox(height: 16),

          // ── Turbin Angin ─────────────────────────────────────────
          _SectionTitle(
              icon: Icons.air_rounded,
              color: const Color(0xFF4FC3F7),
              label: 'Turbin Angin'),
          const SizedBox(height: 10),
          _CounterRow(
            label: 'Jumlah Turbin',
            value: sim.windTurbineCount,
            min: EnergySimulation.minTurbines,
            max: EnergySimulation.maxTurbines,
            color: const Color(0xFF4FC3F7),
            onDecrement: () {
              if (sim.windTurbineCount > EnergySimulation.minTurbines) {
                sim.windTurbineCount--;
                onChanged();
              }
            },
            onIncrement: () {
              if (sim.windTurbineCount < EnergySimulation.maxTurbines) {
                sim.windTurbineCount++;
                onChanged();
              }
            },
          ),
          const SizedBox(height: 10),
          _SliderRow(
            label: 'Kapasitas Turbin',
            value: sim.windTurbinePowerKw,
            min: EnergySimulation.minTurbinePower,
            max: EnergySimulation.maxTurbinePower,
            divisions: 19,
            unit: 'kW',
            color: const Color(0xFF4FC3F7),
            onChanged: (v) {
              sim.windTurbinePowerKw = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: 'Capacity Factor Angin',
            value: sim.windCapacityFactor,
            min: EnergySimulation.minCapacityFactor,
            max: EnergySimulation.maxCapacityFactor,
            divisions: 10,
            unit: '',
            color: const Color(0xFF4FC3F7),
            onChanged: (v) {
              sim.windCapacityFactor = v;
              onChanged();
            },
          ),
          const SizedBox(height: 6),
          _ToggleRow(
            label: 'Turbin Angin',
            value: sim.windActive,
            color: const Color(0xFF4FC3F7),
            onChanged: (v) {
              sim.windActive = v;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SectionTitle(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 15),
      const SizedBox(width: 7),
      Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 13)),
    ]);
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final Color color;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12))),
      // Decrement
      GestureDetector(
        onTap: onDecrement,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.remove, color: Colors.white60, size: 16),
        ),
      ),
      // Value
      Container(
        width: 52,
        alignment: Alignment.center,
        child: Text(
          '$value',
          style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
      // Increment
      GestureDetector(
        onTap: onIncrement,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Icon(Icons.add, color: color, size: 16),
        ),
      ),
    ]);
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayVal =
        unit.isEmpty ? value.toStringAsFixed(2) : value.toStringAsFixed(1);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 11))),
        Text(
          '$displayVal ${unit}',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: color,
          inactiveTrackColor: Colors.white10,
          thumbColor: color,
          overlayColor: color.withAlpha(30),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ),
    ]);
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Text(
        'Status $label: ${value ? "Aktif" : "Nonaktif"}',
        style: TextStyle(
            color: value ? color : Colors.white38, fontSize: 11),
      )),
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
        activeTrackColor: color.withAlpha(60),
        inactiveTrackColor: Colors.white12,
        inactiveThumbColor: Colors.white38,
      ),
    ]);
  }
}
