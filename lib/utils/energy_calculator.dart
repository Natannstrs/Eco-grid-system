// lib/utils/energy_calculator.dart
// Utilitas perhitungan energi terbarukan — EcoGrid Energy Simulator
// Semua nilai hasil perhitungan bersifat SIMULASI EDUKATIF.
// Produksi aktual bergantung pada cuaca, efisiensi perangkat, dan kondisi instalasi.

import 'dart:math' show floor;

/// Hasil perhitungan energi yang dihitung dari parameter simulasi.
class EnergyResult {
  /// Daya nominal panel surya (kW)
  final double solarPowerKw;

  /// Estimasi energi surya harian (kWh/hari)
  final double solarEnergyKwh;

  /// Daya nominal turbin angin (kW)
  final double windPowerKw;

  /// Estimasi energi angin harian (kWh/hari)
  final double windEnergyKwh;

  /// Total daya nominal sistem (kW)
  final double totalPowerKw;

  /// Total energi harian (kWh/hari)
  final double totalEnergyKwh;

  /// Estimasi jumlah rumah yang bisa disuplai
  final int homesPowered;

  /// Persentase kontribusi surya (0–100)
  final double solarContributionPercent;

  /// Persentase kontribusi angin (0–100)
  final double windContributionPercent;

  const EnergyResult({
    required this.solarPowerKw,
    required this.solarEnergyKwh,
    required this.windPowerKw,
    required this.windEnergyKwh,
    required this.totalPowerKw,
    required this.totalEnergyKwh,
    required this.homesPowered,
    required this.solarContributionPercent,
    required this.windContributionPercent,
  });
}

/// Kelas utilitas statis untuk semua perhitungan energi.
class EnergyCalculator {
  // Private constructor — hanya digunakan sebagai namespace statis
  EnergyCalculator._();

  // ─── Rumus Energi Surya ─────────────────────────────────────────────────

  /// Daya nominal panel surya.
  /// solarPowerKw = solarPanelCount × solarPanelPowerWp / 1000
  static double solarPowerKw({
    required int solarPanelCount,
    required double solarPanelPowerWp,
  }) {
    return solarPanelCount * solarPanelPowerWp / 1000.0;
  }

  /// Energi surya harian.
  /// solarEnergyKwh = solarPanelCount × solarPanelPowerWp
  ///                  × effectiveSunHours × performanceRatio / 1000
  static double solarEnergyKwh({
    required int solarPanelCount,
    required double solarPanelPowerWp,
    required double effectiveSunHours,
    required double performanceRatio,
  }) {
    return solarPanelCount *
        solarPanelPowerWp *
        effectiveSunHours *
        performanceRatio /
        1000.0;
  }

  // ─── Rumus Energi Angin ─────────────────────────────────────────────────

  /// Daya nominal turbin angin.
  /// windPowerKw = windTurbineCount × windTurbinePowerKw
  static double windPowerKw({
    required int windTurbineCount,
    required double windTurbinePowerKw,
  }) {
    return windTurbineCount * windTurbinePowerKw;
  }

  /// Energi angin harian.
  /// windEnergyKwh = windTurbineCount × windTurbinePowerKw
  ///                 × windCapacityFactor × 24
  static double windEnergyKwh({
    required int windTurbineCount,
    required double windTurbinePowerKw,
    required double windCapacityFactor,
  }) {
    return windTurbineCount * windTurbinePowerKw * windCapacityFactor * 24.0;
  }

  // ─── Estimasi Rumah ─────────────────────────────────────────────────────

  /// Estimasi jumlah rumah yang bisa disuplai.
  /// homesPowered = floor(totalEnergyKwh / householdConsumptionKwhPerDay)
  /// Mengembalikan 0 jika householdConsumptionKwhPerDay ≤ 0 atau totalEnergyKwh = 0.
  static int homesPowered({
    required double totalEnergyKwh,
    required double householdConsumptionKwhPerDay,
  }) {
    if (householdConsumptionKwhPerDay <= 0 || totalEnergyKwh <= 0) return 0;
    return (totalEnergyKwh / householdConsumptionKwhPerDay).floor();
  }

  // ─── Kontribusi (%) ─────────────────────────────────────────────────────

  /// Persentase kontribusi sumber tertentu terhadap total.
  /// Mengembalikan 0 jika total = 0 (hindari bagi nol).
  static double contributionPercent(double source, double total) {
    if (total <= 0) return 0;
    return (source / total) * 100.0;
  }

  // ─── Kalkulasi Lengkap ──────────────────────────────────────────────────

  /// Hitung semua hasil energi sekaligus dari parameter simulasi.
  static EnergyResult calculate({
    required int solarPanelCount,
    required double solarPanelPowerWp,
    required double effectiveSunHours,
    required double performanceRatio,
    required int windTurbineCount,
    required double windTurbinePowerKw,
    required double windCapacityFactor,
    required double householdConsumptionKwhPerDay,
  }) {
    final solPow = solarPowerKw(
      solarPanelCount: solarPanelCount,
      solarPanelPowerWp: solarPanelPowerWp,
    );
    final solEn = solarEnergyKwh(
      solarPanelCount: solarPanelCount,
      solarPanelPowerWp: solarPanelPowerWp,
      effectiveSunHours: effectiveSunHours,
      performanceRatio: performanceRatio,
    );
    final windPow = windPowerKw(
      windTurbineCount: windTurbineCount,
      windTurbinePowerKw: windTurbinePowerKw,
    );
    final windEn = windEnergyKwh(
      windTurbineCount: windTurbineCount,
      windTurbinePowerKw: windTurbinePowerKw,
      windCapacityFactor: windCapacityFactor,
    );
    final totalPow = solPow + windPow;
    final totalEn = solEn + windEn;
    final homes = homesPowered(
      totalEnergyKwh: totalEn,
      householdConsumptionKwhPerDay: householdConsumptionKwhPerDay,
    );

    return EnergyResult(
      solarPowerKw: solPow,
      solarEnergyKwh: solEn,
      windPowerKw: windPow,
      windEnergyKwh: windEn,
      totalPowerKw: totalPow,
      totalEnergyKwh: totalEn,
      homesPowered: homes,
      solarContributionPercent: contributionPercent(solEn, totalEn),
      windContributionPercent: contributionPercent(windEn, totalEn),
    );
  }

  // ─── Nilai Default ──────────────────────────────────────────────────────
  static const int defaultSolarPanelCount = 20;
  static const double defaultSolarPanelPowerWp = 450.0;
  static const double defaultEffectiveSunHours = 5.0;
  static const double defaultPerformanceRatio = 0.80;
  static const int defaultWindTurbineCount = 3;
  static const double defaultWindTurbinePowerKw = 2.0;
  static const double defaultWindCapacityFactor = 0.30;
  static const double defaultHouseholdConsumptionKwhPerDay = 5.0;

  /// Hasil kalkulasi default (untuk verifikasi unit test).
  static EnergyResult get defaultResult => calculate(
    solarPanelCount: defaultSolarPanelCount,
    solarPanelPowerWp: defaultSolarPanelPowerWp,
    effectiveSunHours: defaultEffectiveSunHours,
    performanceRatio: defaultPerformanceRatio,
    windTurbineCount: defaultWindTurbineCount,
    windTurbinePowerKw: defaultWindTurbinePowerKw,
    windCapacityFactor: defaultWindCapacityFactor,
    householdConsumptionKwhPerDay: defaultHouseholdConsumptionKwhPerDay,
  );
}
