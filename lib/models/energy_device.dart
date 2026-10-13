// lib/models/energy_device.dart
// Model perangkat energi terbarukan — Data Simulasi
import 'package:flutter/material.dart';

/// Enum tipe perangkat energi
enum DeviceType { solar, wind, battery }

/// Model data untuk setiap perangkat energi terbarukan
class EnergyDevice {
  final String id;
  final String name;
  final String description;
  final DeviceType type;
  final double productionKw;
  final double efficiencyPct;
  final double capacityKwh;
  final String status;
  final IconData icon;
  final Color color;

  const EnergyDevice({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.productionKw,
    required this.efficiencyPct,
    required this.capacityKwh,
    required this.status,
    required this.icon,
    required this.color,
  });

  /// Label unit produksi berdasarkan tipe perangkat
  String get productionLabel {
    switch (type) {
      case DeviceType.solar:
        return '${productionKw.toStringAsFixed(1)} kW';
      case DeviceType.wind:
        return '${productionKw.toStringAsFixed(1)} kW';
      case DeviceType.battery:
        return '${capacityKwh.toStringAsFixed(0)} kWh';
    }
  }
}
