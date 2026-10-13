// lib/models/energy_simulation.dart
// Model parameter simulasi — menyimpan semua input dan hasil perhitungan

import '../utils/energy_calculator.dart';

/// Menyimpan semua parameter input simulasi energi.
/// Hasil perhitungan dihitung ulang setiap kali parameter berubah.
class EnergySimulation {
  // ── Parameter Panel Surya ────────────────────────────────────────
  int solarPanelCount;
  double solarPanelPowerWp;
  double effectiveSunHours;
  double performanceRatio;
  bool solarActive;

  // ── Parameter Turbin Angin ───────────────────────────────────────
  int windTurbineCount;
  double windTurbinePowerKw;
  double windCapacityFactor;
  bool windActive;

  // ── Parameter Konsumsi ───────────────────────────────────────────
  double householdConsumptionKwhPerDay;

  EnergySimulation({
    this.solarPanelCount = EnergyCalculator.defaultSolarPanelCount,
    this.solarPanelPowerWp = EnergyCalculator.defaultSolarPanelPowerWp,
    this.effectiveSunHours = EnergyCalculator.defaultEffectiveSunHours,
    this.performanceRatio = EnergyCalculator.defaultPerformanceRatio,
    this.solarActive = true,
    this.windTurbineCount = EnergyCalculator.defaultWindTurbineCount,
    this.windTurbinePowerKw = EnergyCalculator.defaultWindTurbinePowerKw,
    this.windCapacityFactor = EnergyCalculator.defaultWindCapacityFactor,
    this.windActive = true,
    this.householdConsumptionKwhPerDay =
        EnergyCalculator.defaultHouseholdConsumptionKwhPerDay,
  });

  /// Hitung hasil berdasarkan parameter saat ini.
  /// Panel/turbin yang dinonaktifkan dikontribusikan sebagai 0.
  EnergyResult compute() {
    return EnergyCalculator.calculate(
      solarPanelCount: solarActive ? solarPanelCount : 0,
      solarPanelPowerWp: solarPanelPowerWp,
      effectiveSunHours: effectiveSunHours,
      performanceRatio: performanceRatio,
      windTurbineCount: windActive ? windTurbineCount : 0,
      windTurbinePowerKw: windTurbinePowerKw,
      windCapacityFactor: windCapacityFactor,
      householdConsumptionKwhPerDay: householdConsumptionKwhPerDay,
    );
  }

  /// Reset ke nilai default
  void reset() {
    solarPanelCount = EnergyCalculator.defaultSolarPanelCount;
    solarPanelPowerWp = EnergyCalculator.defaultSolarPanelPowerWp;
    effectiveSunHours = EnergyCalculator.defaultEffectiveSunHours;
    performanceRatio = EnergyCalculator.defaultPerformanceRatio;
    solarActive = true;
    windTurbineCount = EnergyCalculator.defaultWindTurbineCount;
    windTurbinePowerKw = EnergyCalculator.defaultWindTurbinePowerKw;
    windCapacityFactor = EnergyCalculator.defaultWindCapacityFactor;
    windActive = true;
    householdConsumptionKwhPerDay =
        EnergyCalculator.defaultHouseholdConsumptionKwhPerDay;
  }

  // ── Batas Validasi ───────────────────────────────────────────────
  static const int minPanels = 0;
  static const int maxPanels = 100;
  static const int minTurbines = 0;
  static const int maxTurbines = 20;
  static const double minPanelPower = 100;
  static const double maxPanelPower = 700;
  static const double minSunHours = 1;
  static const double maxSunHours = 10;
  static const double minPerfRatio = 0.5;
  static const double maxPerfRatio = 1.0;
  static const double minTurbinePower = 0.5;
  static const double maxTurbinePower = 10.0;
  static const double minCapacityFactor = 0.1;
  static const double maxCapacityFactor = 0.6;
}
