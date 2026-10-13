// lib/widgets/interactive_energy_canvas.dart
// Kanvas pembangkit interaktif:
//  - Ilustrasi panel surya, turbin angin berputar, bukit, langit
//  - DRAG/PAN: memindahkan objek panel/turbin di kanvas
//  - LONG PRESS: dibuka oleh parent (tidak ada konflik)
//  - TAP: highlight objek pada kanvas

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/energy_simulation.dart';

/// Data objek yang bisa di-drag di atas kanvas
class _CanvasObject {
  Offset position;
  final String id;
  final bool isSolar; // true = panel surya, false = turbin angin

  _CanvasObject({
    required this.position,
    required this.id,
    required this.isSolar,
  });
}

/// Kanvas interaktif pembangkit energi.
/// Mendukung Drag/Pan gesture dan Tap gesture per objek.
class InteractiveEnergyCanvas extends StatefulWidget {
  final EnergySimulation sim;
  final void Function(String status) onDragUpdate;
  final void Function(bool isSolar) onObjectTap;  // TAP pada objek kanvas

  const InteractiveEnergyCanvas({
    super.key,
    required this.sim,
    required this.onDragUpdate,
    required this.onObjectTap,
  });

  @override
  State<InteractiveEnergyCanvas> createState() =>
      _InteractiveEnergyCanvasState();
}

class _InteractiveEnergyCanvasState extends State<InteractiveEnergyCanvas>
    with TickerProviderStateMixin {
  // ── Animasi Rotasi Turbin ─────────────────────────────────────
  late final AnimationController _turbineController;

  // ── Objek Draggable ───────────────────────────────────────────
  late final List<_CanvasObject> _objects;
  int _activeObjectIndex = -1;  // indeks yang sedang di-drag
  int _selectedObjectIndex = -1; // indeks yang di-tap

  static const double _objectRadius = 32.0; // hit area radius

  @override
  void initState() {
    super.initState();
    // Turbin berputar terus-menerus
    _turbineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Posisi awal objek draggable
    _objects = [
      _CanvasObject(
          position: const Offset(60, 80),
          id: 'solar-main',
          isSolar: true),
      _CanvasObject(
          position: const Offset(200, 60),
          id: 'wind-main',
          isSolar: false),
    ];
  }

  @override
  void dispose() {
    _turbineController.dispose();
    super.dispose();
  }

  /// Hit test: menentukan objek yang disentuh
  int _hitTest(Offset pos) {
    for (int i = _objects.length - 1; i >= 0; i--) {
      final center = _objects[i].position;
      if ((pos - center).distance <= _objectRadius + 10) return i;
    }
    return -1;
  }

  /// Clamp posisi agar tidak keluar batas kanvas
  Offset _clamp(Offset pos, Size size) {
    return Offset(
      pos.dx.clamp(_objectRadius, size.width - _objectRadius),
      pos.dy.clamp(_objectRadius + 20, size.height - _objectRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size =
                Size(constraints.maxWidth, constraints.maxHeight);

            return GestureDetector(
              // ── DRAG/PAN: mulai drag ──────────────────────────
              onPanStart: (d) {
                final idx = _hitTest(d.localPosition);
                setState(() {
                  _activeObjectIndex = idx;
                  if (idx >= 0) _selectedObjectIndex = idx;
                });
              },

              // ── DRAG/PAN: perbarui posisi ─────────────────────
              onPanUpdate: (d) {
                if (_activeObjectIndex < 0) return;
                setState(() {
                  final newPos =
                      _objects[_activeObjectIndex].position + d.delta;
                  _objects[_activeObjectIndex].position =
                      _clamp(newPos, size);
                });
                final obj = _objects[_activeObjectIndex];
                final label = obj.isSolar ? 'Panel Surya' : 'Turbin Angin';
                final cx = obj.position.dx.toInt();
                final cy = obj.position.dy.toInt();
                widget.onDragUpdate('$label → x:$cx, y:$cy');
              },

              // ── DRAG/PAN: selesai drag ────────────────────────
              onPanEnd: (_) {
                if (_activeObjectIndex >= 0) {
                  final obj = _objects[_activeObjectIndex];
                  final label = obj.isSolar ? 'Panel Surya' : 'Turbin Angin';
                  widget.onDragUpdate(
                      '$label ditempatkan di x:${obj.position.dx.toInt()}, y:${obj.position.dy.toInt()}');
                }
                setState(() => _activeObjectIndex = -1);
              },

              // ── TAP: pilih/deselect objek ─────────────────────
              onTapUp: (d) {
                final idx = _hitTest(d.localPosition);
                setState(() {
                  if (idx >= 0) {
                    _selectedObjectIndex =
                        _selectedObjectIndex == idx ? -1 : idx;
                    widget.onObjectTap(_objects[idx].isSolar);
                  } else {
                    _selectedObjectIndex = -1;
                  }
                });
              },

              child: Stack(
                children: [
                  // ── Background: langit + bukit ────────────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LandscapePainter(),
                    ),
                  ),

                  // ── Label kanvas ──────────────────────────────
                  const Positioned(
                    top: 6,
                    left: 10,
                    child: Text(
                      'Kanvas Simulasi — Seret Objek',
                      style:
                          TextStyle(color: Colors.white30, fontSize: 9),
                    ),
                  ),

                  // ── Indikator perangkat (kiri bawah) ─────────
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: _DeviceCountBadge(
                      solarCount: widget.sim.solarPanelCount,
                      windCount: widget.sim.windTurbineCount,
                      solarActive: widget.sim.solarActive,
                      windActive: widget.sim.windActive,
                    ),
                  ),

                  // ── Objek draggable ───────────────────────────
                  for (int i = 0; i < _objects.length; i++)
                    Positioned(
                      left: _objects[i].position.dx - _objectRadius,
                      top: _objects[i].position.dy - _objectRadius,
                      child: _objects[i].isSolar
                          ? _SolarPanelObject(
                              count: widget.sim.solarPanelCount,
                              active: widget.sim.solarActive,
                              isSelected: _selectedObjectIndex == i,
                              isDragging: _activeObjectIndex == i,
                              radius: _objectRadius,
                            )
                          : _WindTurbineObject(
                              count: widget.sim.windTurbineCount,
                              active: widget.sim.windActive,
                              isSelected: _selectedObjectIndex == i,
                              isDragging: _activeObjectIndex == i,
                              radius: _objectRadius,
                              rotationAnimation: _turbineController,
                            ),
                    ),

                  // ── Koordinat aktif / terpilih ────────────────
                  if (_selectedObjectIndex >= 0)
                    Positioned(
                      bottom: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'x:${_objects[_selectedObjectIndex].position.dx.toInt()}'
                          '  y:${_objects[_selectedObjectIndex].position.dy.toInt()}',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 9),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Sub-widget Objek Panel Surya ─────────────────────────────────────────────

class _SolarPanelObject extends StatelessWidget {
  final int count;
  final bool active;
  final bool isSelected;
  final bool isDragging;
  final double radius;

  const _SolarPanelObject({
    required this.count,
    required this.active,
    required this.isSelected,
    required this.isDragging,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? const Color(0xFFFFC107) : Colors.white24;
    final bgColor = isDragging
        ? color.withAlpha(80)
        : isSelected
            ? color.withAlpha(55)
            : color.withAlpha(30);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected || isDragging ? color : color.withAlpha(120),
          width: isSelected || isDragging ? 2.5 : 1.5,
        ),
        boxShadow: isSelected || isDragging
            ? [BoxShadow(color: color.withAlpha(100), blurRadius: 14, spreadRadius: 3)]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_rounded, color: color, size: 20),
          Text(
            '${count}x',
            style: TextStyle(
                color: color, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widget Objek Turbin Angin (dengan rotasi) ────────────────────────────

class _WindTurbineObject extends StatelessWidget {
  final int count;
  final bool active;
  final bool isSelected;
  final bool isDragging;
  final double radius;
  final AnimationController rotationAnimation;

  const _WindTurbineObject({
    required this.count,
    required this.active,
    required this.isSelected,
    required this.isDragging,
    required this.radius,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? const Color(0xFF4FC3F7) : Colors.white24;
    final bgColor = isDragging
        ? color.withAlpha(80)
        : isSelected
            ? color.withAlpha(55)
            : color.withAlpha(30);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected || isDragging ? color : color.withAlpha(120),
          width: isSelected || isDragging ? 2.5 : 1.5,
        ),
        boxShadow: isSelected || isDragging
            ? [BoxShadow(color: color.withAlpha(100), blurRadius: 14, spreadRadius: 3)]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Baling-baling berputar menggunakan AnimatedBuilder + Transform.rotate
          AnimatedBuilder(
            animation: rotationAnimation,
            builder: (_, __) {
              return Transform.rotate(
                angle: active
                    ? rotationAnimation.value * 2 * math.pi
                    : 0,
                child: Icon(Icons.wind_power, color: color, size: 20),
              );
            },
          ),
          Text(
            '${count}x',
            style: TextStyle(
                color: color, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Landscape Background Painter ─────────────────────────────────────────────

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Langit gradasi gelap
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A1F0A), Color(0xFF0D2B1A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Bintang-bintang kecil
    final starPaint = Paint()..color = Colors.white.withAlpha(60);
    final rand = math.Random(42);
    for (int i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(
            rand.nextDouble() * size.width, rand.nextDouble() * size.height * 0.6),
        rand.nextDouble() * 1.2 + 0.3,
        starPaint,
      );
    }

    // Bukit kiri
    final hillPaint1 = Paint()..color = const Color(0xFF1B3A1B);
    final hill1 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.45,
          size.width * 0.5, size.height)
      ..close();
    canvas.drawPath(hill1, hillPaint1);

    // Bukit kanan
    final hillPaint2 = Paint()..color = const Color(0xFF163016);
    final hill2 = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..quadraticBezierTo(
          size.width * 0.65, size.height * 0.40,
          size.width, size.height)
      ..close();
    canvas.drawPath(hill2, hillPaint2);

    // Grid tipis di tanah
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..strokeWidth = 0.5;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_LandscapePainter oldDelegate) => false;
}

// ── Badge Jumlah Perangkat ───────────────────────────────────────────────────

class _DeviceCountBadge extends StatelessWidget {
  final int solarCount;
  final int windCount;
  final bool solarActive;
  final bool windActive;

  const _DeviceCountBadge({
    required this.solarCount,
    required this.windCount,
    required this.solarActive,
    required this.windActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wb_sunny_rounded,
            color: solarActive
                ? const Color(0xFFFFC107)
                : Colors.white30,
            size: 11),
        const SizedBox(width: 3),
        Text('$solarCount',
            style: TextStyle(
                color: solarActive
                    ? const Color(0xFFFFC107)
                    : Colors.white30,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Icon(Icons.wind_power,
            color: windActive
                ? const Color(0xFF4FC3F7)
                : Colors.white30,
            size: 11),
        const SizedBox(width: 3),
        Text('$windCount',
            style: TextStyle(
                color: windActive
                    ? const Color(0xFF4FC3F7)
                    : Colors.white30,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
