// lib/screens/dashboard_screen.dart
// Layar utama EcoGrid Energy Simulator
// NIM: 202431091 | Gesture: Tap, Long Press, Drag/Pan

import 'package:flutter/material.dart';
import '../models/energy_simulation.dart';
import '../utils/energy_calculator.dart';
import '../widgets/energy_stat_card.dart';
import '../widgets/energy_control_panel.dart';
import '../widgets/interactive_energy_canvas.dart';
import '../widgets/device_detail_sheet.dart';
import '../widgets/energy_contribution_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // ── Model Simulasi ────────────────────────────────────────────
  final EnergySimulation _sim = EnergySimulation();
  late EnergyResult _result;

  // ── State Gesture ─────────────────────────────────────────────
  /// -1 = tidak ada, 0 = solar card, 1 = wind card, 2 = total card
  int _selectedCardIndex = -1;
  String _lastGestureStatus = 'Belum ada interaksi';
  IconData _lastGestureIcon = Icons.touch_app_outlined;

  // ── Animasi Header (pulse Live indicator) ─────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── Bottom Nav ────────────────────────────────────────────────
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _result = _sim.compute();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 0.7, end: 1.0).animate(
          CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Perhitungan ulang saat parameter berubah ──────────────────
  void _onSimChanged() {
    setState(() {
      _result = _sim.compute();
    });
  }

  // ── Handler: TAP pada kartu statistik ────────────────────────
  void _handleCardTap(int index) {
    setState(() {
      _selectedCardIndex = _selectedCardIndex == index ? -1 : index;
      final names = ['Solar', 'Angin', 'Total'];
      _lastGestureStatus = _selectedCardIndex == index
          ? '👆 Tap: Kartu ${names[index]} dipilih'
          : '👆 Tap: Pilihan kartu ${names[index]} dilepas';
      _lastGestureIcon = Icons.touch_app;
    });
  }

  // ── Handler: LONG PRESS pada kartu statistik ─────────────────
  void _handleCardLongPress(int index) {
    setState(() {
      _lastGestureStatus = '✋ Long Press: Detail kartu dibuka';
      _lastGestureIcon = Icons.pan_tool;
    });
    final isSolar = index == 0;
    showDeviceDetailSheet(
      context: context,
      type: isSolar ? DetailDeviceType.solar : DetailDeviceType.wind,
      sim: _sim,
      onToggle: () {
        // Toggle active state
        if (isSolar) {
          _sim.solarActive = !_sim.solarActive;
        } else {
          _sim.windActive = !_sim.windActive;
        }
        _onSimChanged();
      },
    );
  }

  // ── Handler: TAP pada objek kanvas ───────────────────────────
  void _handleCanvasObjectTap(bool isSolar) {
    setState(() {
      final name = isSolar ? 'Panel Surya' : 'Turbin Angin';
      _lastGestureStatus = '👆 Tap [Kanvas]: $name dipilih';
      _lastGestureIcon = Icons.touch_app;
    });
  }

  // ── Handler: DRAG/PAN update dari kanvas ─────────────────────
  void _handleDragUpdate(String status) {
    setState(() {
      _lastGestureStatus = '↔ Drag: $status';
      _lastGestureIcon = Icons.open_with;
    });
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080F08),
      appBar: _buildAppBar(),
      body: _navIndex == 0
          ? _buildDashboardBody()
          : _navIndex == 1
              ? _buildControlBody()
              : _buildAboutBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A160A),
      elevation: 0,
      title: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('EcoGrid',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1)),
            Text('Energy Simulator',
                style: TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ]),
      actions: [
        // LIVE badge
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4332),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  ),
                ),
                const SizedBox(width: 5),
                const Text('LIVE SIMULATION',
                    style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ══ Tab 0: Dashboard ═══════════════════════════════════════════
  Widget _buildDashboardBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 14),
            _buildSectionLabel('Kartu Statistik',
                'Tap untuk pilih · Tahan untuk detail perangkat'),
            const SizedBox(height: 10),
            _buildStatCards(),
            const SizedBox(height: 14),
            _buildContributionChart(),
            const SizedBox(height: 14),
            _buildSectionLabel('Kanvas Pembangkit',
                'Tap/Seret ikon · Baling-baling berputar otomatis'),
            const SizedBox(height: 10),
            SizedBox(
              height: 230,
              child: InteractiveEnergyCanvas(
                sim: _sim,
                onDragUpdate: _handleDragUpdate,
                onObjectTap: _handleCanvasObjectTap,
              ),
            ),
            const SizedBox(height: 14),
            _buildGestureGuide(),
            const SizedBox(height: 10),
            _buildGestureStatus(),
            const SizedBox(height: 14),
            _buildHomesCard(),
            const SizedBox(height: 10),
            _buildSimNote(),
            const SizedBox(height: 10),
            _buildSdgBadges(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Hero card — total daya dan energi
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF0A1F0A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.electric_bolt,
              color: Color(0xFF69F0AE), size: 14),
          const SizedBox(width: 6),
          const Text('Total Daya Nominal Sistem',
              style: TextStyle(color: Colors.white60, fontSize: 12)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.withAlpha(70)),
            ),
            child: const Text('⚡ Data Simulasi',
                style: TextStyle(color: Colors.amber, fontSize: 9)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            _result.totalPowerKw.toStringAsFixed(1),
            style: const TextStyle(
                color: Color(0xFF69F0AE),
                fontSize: 46,
                fontWeight: FontWeight.w800,
                height: 1),
          ),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('kW',
                style: TextStyle(color: Color(0xFF69F0AE), fontSize: 18)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _HeroMetric(
            icon: Icons.wb_sunny_rounded,
            label: 'Surya',
            value: '${_result.solarPowerKw.toStringAsFixed(1)} kW',
            color: const Color(0xFFFFC107),
          ),
          const SizedBox(width: 18),
          _HeroMetric(
            icon: Icons.air_rounded,
            label: 'Angin',
            value: '${_result.windPowerKw.toStringAsFixed(1)} kW',
            color: const Color(0xFF4FC3F7),
          ),
          const SizedBox(width: 18),
          _HeroMetric(
            icon: Icons.home_rounded,
            label: 'Rumah',
            value: '${_result.homesPowered} unit',
            color: const Color(0xFF81C784),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
          'Total Energi/Hari: ${_result.totalEnergyKwh.toStringAsFixed(1)} kWh/hari',
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ]),
    );
  }

  // Tiga kartu statistik utama
  Widget _buildStatCards() {
    return Row(children: [
      Expanded(
        child: EnergyStatCard(
          title: 'Energi Surya',
          value: _result.solarEnergyKwh.toStringAsFixed(1),
          unit: 'kWh/hari',
          subtitle:
              '${_sim.solarPanelCount} panel · ${_result.solarPowerKw.toStringAsFixed(1)} kW',
          icon: Icons.wb_sunny_rounded,
          accentColor: const Color(0xFFFFC107),
          isSelected: _selectedCardIndex == 0,
          // TAP gesture
          onTap: () => _handleCardTap(0),
          // LONG PRESS gesture
          onLongPress: () => _handleCardLongPress(0),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: EnergyStatCard(
          title: 'Energi Angin',
          value: _result.windEnergyKwh.toStringAsFixed(1),
          unit: 'kWh/hari',
          subtitle:
              '${_sim.windTurbineCount} turbin · ${_result.windPowerKw.toStringAsFixed(1)} kW',
          icon: Icons.air_rounded,
          accentColor: const Color(0xFF4FC3F7),
          isSelected: _selectedCardIndex == 1,
          onTap: () => _handleCardTap(1),
          onLongPress: () => _handleCardLongPress(1),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: EnergyStatCard(
          title: 'Total Energi',
          value: _result.totalEnergyKwh.toStringAsFixed(1),
          unit: 'kWh/hari',
          subtitle:
              'Surya+Angin · ${_result.homesPowered} rumah',
          icon: Icons.flash_on,
          accentColor: const Color(0xFF69F0AE),
          isSelected: _selectedCardIndex == 2,
          onTap: () => _handleCardTap(2),
          onLongPress: () {
            setState(() {
              _lastGestureStatus = '✋ Long Press: Statistik total dibuka';
              _lastGestureIcon = Icons.pan_tool;
            });
            _showTotalStatsSheet();
          },
        ),
      ),
    ]);
  }

  void _showTotalStatsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1E10),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF69F0AE).withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on,
                  color: Color(0xFF69F0AE), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Statistik Total Sistem',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          _buildStatRow('Total Daya Nominal',
              '${_result.totalPowerKw.toStringAsFixed(2)} kW'),
          _buildStatRow('Daya Surya',
              '${_result.solarPowerKw.toStringAsFixed(2)} kW'),
          _buildStatRow('Daya Angin',
              '${_result.windPowerKw.toStringAsFixed(2)} kW'),
          _buildStatRow('Energi Surya/Hari',
              '${_result.solarEnergyKwh.toStringAsFixed(2)} kWh'),
          _buildStatRow('Energi Angin/Hari',
              '${_result.windEnergyKwh.toStringAsFixed(2)} kWh'),
          _buildStatRow('Total Energi/Hari',
              '${_result.totalEnergyKwh.toStringAsFixed(2)} kWh'),
          _buildStatRow(
              'Rumah Tersuplai', '${_result.homesPowered} rumah'),
          _buildStatRow('Kontribusi Surya',
              '${_result.solarContributionPercent.toStringAsFixed(1)}%'),
          _buildStatRow('Kontribusi Angin',
              '${_result.windContributionPercent.toStringAsFixed(1)}%'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
        ]),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12))),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF69F0AE),
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ]),
    );
  }

  Widget _buildContributionChart() {
    return EnergyContributionChart(
      solarPercent: _result.solarContributionPercent,
      windPercent: _result.windContributionPercent,
      solarKwh: _result.solarEnergyKwh,
      windKwh: _result.windEnergyKwh,
    );
  }

  Widget _buildHomesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF81C784).withAlpha(35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.home_rounded,
              color: Color(0xFF81C784), size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimasi Rumah Tersuplai',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  '${_result.homesPowered}',
                  style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4, left: 4),
                  child: Text('rumah/hari',
                      style: TextStyle(
                          color: Color(0xFF81C784), fontSize: 12)),
                ),
              ]),
              Text(
                'Asumsi ${_sim.householdConsumptionKwhPerDay.toStringAsFixed(0)} kWh/rumah/hari · Data Simulasi',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildGestureGuide() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline, color: Color(0xFF69F0AE), size: 15),
            SizedBox(width: 7),
            Text('Panduan Gesture',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 10),
          _GuideItem(
              icon: Icons.touch_app,
              color: const Color(0xFF69F0AE),
              label: 'Tap',
              desc: 'Ketuk kartu atau ikon kanvas untuk memilihnya'),
          const SizedBox(height: 7),
          _GuideItem(
              icon: Icons.pan_tool,
              color: const Color(0xFF4FC3F7),
              label: 'Long Press',
              desc: 'Tahan kartu Solar/Angin untuk detail & toggle aktif'),
          const SizedBox(height: 7),
          _GuideItem(
              icon: Icons.open_with,
              color: const Color(0xFFFFC107),
              label: 'Drag / Pan',
              desc: 'Seret ikon di kanvas — posisi mengikuti jari'),
        ],
      ),
    );
  }

  Widget _buildGestureStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF132213),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Icon(_lastGestureIcon, color: const Color(0xFF69F0AE), size: 17),
        const SizedBox(width: 9),
        const Text('Status: ',
            style: TextStyle(color: Colors.white38, fontSize: 11)),
        Expanded(
          child: Text(_lastGestureStatus,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }

  Widget _buildSimNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(65)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 15),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Simulasi Edukatif. Semua nilai produksi energi adalah estimasi berdasarkan rumus teknis. '
              'Produksi aktual bergantung pada cuaca, efisiensi perangkat, dan kondisi instalasi.',
              style: TextStyle(
                  color: Colors.amber, fontSize: 10, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSdgBadges() {
    return Row(children: [
      _SdgBadge(
          number: '7',
          label: 'Energi Bersih',
          color: const Color(0xFFFCC30B)),
      const SizedBox(width: 10),
      _SdgBadge(
          number: '13',
          label: 'Aksi Iklim',
          color: const Color(0xFF3F7E44)),
    ]);
  }

  // ══ Tab 1: Kontrol ═════════════════════════════════════════════
  Widget _buildControlBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          _buildSectionLabel('Parameter Simulasi',
              'Ubah nilai untuk melihat hasil perhitungan'),
          const SizedBox(height: 10),
          EnergyControlPanel(sim: _sim, onChanged: _onSimChanged),
          const SizedBox(height: 14),
          // Preview hasil setelah mengubah parameter
          _buildResultPreview(),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _buildResultPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withAlpha(80)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.calculate_outlined,
              color: Color(0xFF69F0AE), size: 16),
          SizedBox(width: 8),
          Text('Hasil Perhitungan Saat Ini',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        _buildStatRow(
            'Daya Surya Nominal',
            '${_result.solarPowerKw.toStringAsFixed(2)} kW'),
        _buildStatRow(
            'Energi Surya/Hari',
            '${_result.solarEnergyKwh.toStringAsFixed(2)} kWh'),
        _buildStatRow(
            'Daya Angin Nominal',
            '${_result.windPowerKw.toStringAsFixed(2)} kW'),
        _buildStatRow(
            'Energi Angin/Hari',
            '${_result.windEnergyKwh.toStringAsFixed(2)} kWh'),
        const Divider(color: Colors.white12, height: 20),
        _buildStatRow(
            'Total Daya Nominal',
            '${_result.totalPowerKw.toStringAsFixed(2)} kW'),
        _buildStatRow(
            'Total Energi/Hari',
            '${_result.totalEnergyKwh.toStringAsFixed(2)} kWh'),
        _buildStatRow(
            'Estimasi Rumah',
            '${_result.homesPowered} rumah/hari'),
      ]),
    );
  }

  // ══ Tab 2: Tentang ════════════════════════════════════════════
  Widget _buildAboutBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _buildAboutHeader(),
          const SizedBox(height: 16),
          _buildFormulaCard(),
          const SizedBox(height: 16),
          _buildAboutInfoCard(),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _buildAboutHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF0A1F0A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.public, color: Color(0xFF69F0AE), size: 20),
          SizedBox(width: 10),
          Text('SDG — Pembangunan Berkelanjutan',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ]),
        const SizedBox(height: 14),
        _SdgBlock(
          number: 'SDG 7',
          title: 'Energi Bersih dan Terjangkau',
          body:
              'EcoGrid mensimulasikan produksi energi dari panel surya dan turbin angin '
              'untuk menunjukkan potensi sumber energi terbarukan dalam memenuhi kebutuhan listrik.',
          color: const Color(0xFFFCC30B),
        ),
        const SizedBox(height: 12),
        _SdgBlock(
          number: 'SDG 13',
          title: 'Penanganan Perubahan Iklim',
          body:
              'Setiap kWh dari sumber terbarukan menggantikan bahan bakar fosil dan '
              'mengurangi emisi CO₂, berkontribusi pada target nol emisi karbon.',
          color: const Color(0xFF3F7E44),
        ),
      ]),
    );
  }

  Widget _buildFormulaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.functions, color: Color(0xFF69F0AE), size: 16),
          SizedBox(width: 8),
          Text('Rumus Perhitungan',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        _FormulaRow('Energi Surya',
            'panel × Wp × jam_matahari × PR / 1000'),
        _FormulaRow('Energi Angin',
            'turbin × kW/turbin × CF × 24 jam'),
        _FormulaRow('Total Energi', 'Surya + Angin'),
        _FormulaRow('Rumah Tersuplai',
            'floor(Total Energi / konsumsi_rumah)'),
        const SizedBox(height: 10),
        const Text(
          'Nilai default: Panel=20, 450Wp, 5jam, PR=0.80\n'
          'Turbin=3, 2kW, CF=0.30, Konsumsi=5 kWh/hari\n'
          'Hasil: Surya=36, Angin=43.2, Total=79.2 kWh/hari, 15 rumah',
          style: TextStyle(
              color: Colors.white38, fontSize: 10, height: 1.6),
        ),
      ]),
    );
  }

  Widget _buildAboutInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tentang Aplikasi',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 12),
        const _InfoRow(label: 'Aplikasi', value: 'EcoGrid Energy Simulator'),
        const _InfoRow(label: 'Versi', value: '2.0.0'),
        const _InfoRow(label: 'NIM', value: '202431091'),
        const _InfoRow(label: 'Platform', value: 'Android (Flutter)'),
        const _InfoRow(label: 'Gesture', value: 'Tap · Long Press · Drag/Pan'),
        const _InfoRow(
            label: 'Data', value: 'Simulasi edukatif (bukan sensor nyata)'),
        const _InfoRow(label: 'GitHub', value: '(isi URL setelah upload)'),
        const _InfoRow(label: 'Anggota', value: '(isi nama anggota kelompok)'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withAlpha(70)),
          ),
          child: const Text(
            '⚠  Semua nilai produksi energi merupakan Data Simulasi Edukatif. '
            'Nilai aktual bergantung pada cuaca, efisiensi perangkat, dan kondisi instalasi.',
            style: TextStyle(
                color: Colors.amber, fontSize: 10, height: 1.5),
          ),
        ),
      ]),
    );
  }

  // ══ Helpers ════════════════════════════════════════════════════

  Widget _buildSectionLabel(String title, String subtitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold)),
      Text(subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 10)),
    ]);
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      backgroundColor: const Color(0xFF0A160A),
      selectedItemColor: const Color(0xFF69F0AE),
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.tune_rounded), label: 'Kontrol'),
        BottomNavigationBarItem(
            icon: Icon(Icons.info_outline_rounded), label: 'Tentang'),
      ],
    );
  }
}

// ── Standalone helper widgets ───────────────────────────────────────────────

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _HeroMetric(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 3),
        Text(label,
            style:
                const TextStyle(color: Colors.white38, fontSize: 9)),
      ]),
      const SizedBox(height: 2),
      Text(value,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }
}

class _GuideItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String desc;

  const _GuideItem(
      {required this.icon,
      required this.color,
      required this.label,
      required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 17),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
          Text(desc,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 10)),
        ]),
      ),
    ]);
  }
}

class _SdgBadge extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _SdgBadge(
      {required this.number, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 7),
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      ]),
    );
  }
}

class _SdgBlock extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final Color color;

  const _SdgBlock(
      {required this.number,
      required this.title,
      required this.body,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(number,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 3),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        const SizedBox(height: 7),
        Text(body,
            style: const TextStyle(
                color: Colors.white54, fontSize: 11, height: 1.5)),
      ]),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  final String label;
  final String formula;

  const _FormulaRow(this.label, this.formula);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF69F0AE), fontSize: 11,
                fontWeight: FontWeight.w600)),
        Text('= $formula',
            style:
                const TextStyle(color: Colors.white38, fontSize: 10)),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(
          width: 76,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 11)),
        ),
        const Text(': ',
            style: TextStyle(color: Colors.white38)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
        ),
      ]),
    );
  }
}
