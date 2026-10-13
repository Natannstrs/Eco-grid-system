// lib/widgets/device_detail_sheet.dart
// Modal bottom sheet — muncul saat Long Press pada kartu/objek perangkat

import 'package:flutter/material.dart';
import '../models/energy_simulation.dart';
import '../utils/energy_calculator.dart';

enum DetailDeviceType { solar, wind }

/// Menampilkan bottom sheet detail perangkat dengan opsi aktif/nonaktif.
void showDeviceDetailSheet({
  required BuildContext context,
  required DetailDeviceType type,
  required EnergySimulation sim,
  required VoidCallback onToggle,  // callback toggle active/inactive
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _DeviceDetailSheet(
      type: type,
      sim: sim,
      onToggle: onToggle,
    ),
  );
}

class _DeviceDetailSheet extends StatefulWidget {
  final DetailDeviceType type;
  final EnergySimulation sim;
  final VoidCallback onToggle;

  const _DeviceDetailSheet({
    required this.type,
    required this.sim,
    required this.onToggle,
  });

  @override
  State<_DeviceDetailSheet> createState() => _DeviceDetailSheetState();
}

class _DeviceDetailSheetState extends State<_DeviceDetailSheet> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.type == DetailDeviceType.solar
        ? widget.sim.solarActive
        : widget.sim.windActive;
  }

  @override
  Widget build(BuildContext context) {
    final isSolar = widget.type == DetailDeviceType.solar;
    final color =
        isSolar ? const Color(0xFFFFC107) : const Color(0xFF4FC3F7);
    final icon =
        isSolar ? Icons.wb_sunny_rounded : Icons.air_rounded;
    final name = isSolar ? 'Panel Surya' : 'Turbin Angin';

    // Hitung data untuk perangkat ini
    final count =
        isSolar ? widget.sim.solarPanelCount : widget.sim.windTurbineCount;
    final energyKwh = isSolar
        ? EnergyCalculator.solarEnergyKwh(
            solarPanelCount: widget.sim.solarPanelCount,
            solarPanelPowerWp: widget.sim.solarPanelPowerWp,
            effectiveSunHours: widget.sim.effectiveSunHours,
            performanceRatio: widget.sim.performanceRatio,
          )
        : EnergyCalculator.windEnergyKwh(
            windTurbineCount: widget.sim.windTurbineCount,
            windTurbinePowerKw: widget.sim.windTurbinePowerKw,
            windCapacityFactor: widget.sim.windCapacityFactor,
          );
    final powerKw = isSolar
        ? EnergyCalculator.solarPowerKw(
            solarPanelCount: widget.sim.solarPanelCount,
            solarPanelPowerWp: widget.sim.solarPanelPowerWp,
          )
        : EnergyCalculator.windPowerKw(
            windTurbineCount: widget.sim.windTurbineCount,
            windTurbinePowerKw: widget.sim.windTurbinePowerKw,
          );

    final capacityStr = isSolar
        ? '${widget.sim.solarPanelPowerWp.toStringAsFixed(0)} Wp/panel'
        : '${widget.sim.windTurbinePowerKw.toStringAsFixed(1)} kW/turbin';

    final extraParam = isSolar
        ? 'Jam matahari: ${widget.sim.effectiveSunHours.toStringAsFixed(1)} jam/hari'
        : 'Capacity factor: ${(widget.sim.windCapacityFactor * 100).toStringAsFixed(0)}%';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1E10),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withAlpha(45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Row(children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isActive
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isActive ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          color: _isActive
                              ? const Color(0xFF4CAF50)
                              : Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              // Badge Long Press
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.pan_tool, color: Colors.white60, size: 11),
                  SizedBox(width: 4),
                  Text('Long Press',
                      style: TextStyle(color: Colors.white60, fontSize: 10)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Data simulasi warning
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withAlpha(70)),
            ),
            child: const Text(
              '⚠  Data Simulasi — bukan data sensor nyata',
              style: TextStyle(color: Colors.amber, fontSize: 10),
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(children: [
            _StatTile(label: 'Jumlah', value: '$count unit', icon: Icons.tag, color: color),
            const SizedBox(width: 10),
            _StatTile(label: 'Kapasitas', value: capacityStr, icon: Icons.bolt, color: color),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _StatTile(
                label: 'Daya Nominal',
                value: '${powerKw.toStringAsFixed(2)} kW',
                icon: Icons.electric_bolt,
                color: color),
            const SizedBox(width: 10),
            _StatTile(
                label: 'Energi/Hari',
                value: '${energyKwh.toStringAsFixed(1)} kWh',
                icon: Icons.today,
                color: color),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A140A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              extraParam,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),

          // Toggle aktif/nonaktif
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _isActive = !_isActive);
                    widget.onToggle();
                  },
                  icon: Icon(
                    _isActive
                        ? Icons.power_off_outlined
                        : Icons.power_outlined,
                    size: 16,
                  ),
                  label: Text(_isActive ? 'Nonaktifkan' : 'Aktifkan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isActive ? Colors.redAccent : const Color(0xFF4CAF50),
                    side: BorderSide(
                        color: _isActive
                            ? Colors.redAccent
                            : const Color(0xFF4CAF50)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A140A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ]),
      ),
    );
  }
}
