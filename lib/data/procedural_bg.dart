import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fundo PROCEDURAL: a arte é desenhada no aparelho (CustomPainter) a partir de
/// um `seed`. Combinando paletas × estilos de ornamento × posições, o espaço de
/// variação é imenso ("infinito") sem guardar nenhuma imagem no APK.
///
/// Mesmo seed => mesma arte (estável por frase). Cada frase recebe um seed
/// diferente, então a galeria nunca parece repetitiva.
class ProceduralBg {
  ProceduralBg._();

  /// Paletas base (gradiente). Bonitas, com bom contraste pra texto claro.
  static const List<List<Color>> palettes = [
    [Color(0xFFFF758C), Color(0xFFFF7EB3)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    [Color(0xFFEB3349), Color(0xFFF45C43)],
    [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    [Color(0xFFDA22FF), Color(0xFF9733EE)],
    [Color(0xFFF12711), Color(0xFFF5AF19)],
    [Color(0xFF141E30), Color(0xFF243B55)],
    [Color(0xFFFC466B), Color(0xFF3F5EFB)],
    [Color(0xFF0F2027), Color(0xFF2C5364)],
    [Color(0xFFee9ca7), Color(0xFFb24592)],
    [Color(0xFFf6d365), Color(0xFFfda085)],
    [Color(0xFF4b6cb7), Color(0xFF182848)],
    [Color(0xFF5f2c82), Color(0xFF49a09d)],
    [Color(0xFFc471f5), Color(0xFFfa71cd)],
    [Color(0xFFf857a6), Color(0xFFff5858)],
  ];

  static const int _styles = 7;

  /// Total de combinações "principais" (paleta × estilo × direção do gradiente).
  static int get variety => palettes.length * _styles * 4;

  static int seedFor(String text) => text.hashCode & 0x7fffffff;
}

/// PRNG determinístico (LCG) — leve e estável.
class _Rnd {
  _Rnd(int seed) : _s = (seed == 0 ? 1 : seed) & 0xffffffff;
  int _s;
  double next() {
    _s = (_s * 1664525 + 1013904223) & 0xffffffff;
    return _s / 0xffffffff;
  }

  double range(double a, double b) => a + (b - a) * next();
  int intg(int n) => (next() * n).floor() % n;
}

class ProceduralPainter extends CustomPainter {
  ProceduralPainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final r = _Rnd(seed);
    final pal = ProceduralBg.palettes[seed % ProceduralBg.palettes.length];
    final rect = Offset.zero & size;

    // --- Base: gradiente com direção variável ---
    final dir = (seed ~/ ProceduralBg.palettes.length) % 4;
    final begins = [
      Alignment.topLeft,
      Alignment.topCenter,
      Alignment.topRight,
      Alignment.centerLeft,
    ];
    final ends = [
      Alignment.bottomRight,
      Alignment.bottomCenter,
      Alignment.bottomLeft,
      Alignment.centerRight,
    ];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
                colors: pal, begin: begins[dir], end: ends[dir])
            .createShader(rect),
    );

    final style =
        (seed ~/ (ProceduralBg.palettes.length * 4)) % ProceduralBg._styles;
    final w = size.width, h = size.height;
    final tint = _mix(pal[0], pal[1], 0.5);

    switch (style) {
      case 0:
        _bokeh(canvas, r, w, h);
        break;
      case 1:
        _dots(canvas, r, w, h);
        break;
      case 2:
        _waves(canvas, r, w, h, tint);
        break;
      case 3:
        _hearts(canvas, r, w, h);
        break;
      case 4:
        _sparkles(canvas, r, w, h);
        break;
      case 5:
        _rings(canvas, r, w, h);
        break;
      case 6:
        _confetti(canvas, r, w, h);
        break;
    }

    // --- Vinheta suave (dá profundidade e contraste pro texto) ---
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.28)],
          stops: const [0.62, 1.0],
        ).createShader(rect),
    );
  }

  Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  void _bokeh(Canvas c, _Rnd r, double w, double h) {
    final n = 10 + r.intg(10);
    for (var i = 0; i < n; i++) {
      final radius = r.range(w * 0.05, w * 0.22);
      c.drawCircle(
        Offset(r.range(0, w), r.range(0, h)),
        radius,
        Paint()..color = Colors.white.withValues(alpha: r.range(0.03, 0.12)),
      );
    }
  }

  void _dots(Canvas c, _Rnd r, double w, double h) {
    final step = w / (5 + r.intg(4));
    final rad = step * 0.10;
    for (var y = step * 0.5; y < h; y += step) {
      for (var x = step * 0.5; x < w; x += step) {
        c.drawCircle(
          Offset(x + r.range(-4, 4), y + r.range(-4, 4)),
          rad,
          Paint()..color = Colors.white.withValues(alpha: 0.10),
        );
      }
    }
  }

  void _waves(Canvas c, _Rnd r, double w, double h, Color tint) {
    final bands = 3 + r.intg(3);
    for (var b = 0; b < bands; b++) {
      final path = Path();
      final baseY = h * (b + 1) / (bands + 1) + r.range(-h * 0.05, h * 0.05);
      final amp = r.range(h * 0.02, h * 0.06);
      final len = r.range(w * 0.35, w * 0.7);
      path.moveTo(0, baseY);
      for (var x = 0.0; x <= w; x += w / 24) {
        path.lineTo(x, baseY + math.sin(x / len * math.pi * 2) * amp);
      }
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.close();
      c.drawPath(
        path,
        Paint()..color = Colors.white.withValues(alpha: 0.06),
      );
    }
  }

  void _hearts(Canvas c, _Rnd r, double w, double h) {
    final n = 7 + r.intg(8);
    for (var i = 0; i < n; i++) {
      final s = r.range(w * 0.05, w * 0.14);
      _heart(c, Offset(r.range(0, w), r.range(0, h)), s,
          Colors.white.withValues(alpha: r.range(0.05, 0.14)));
    }
  }

  void _heart(Canvas c, Offset o, double s, Color color) {
    final p = Path();
    p.moveTo(o.dx, o.dy + s * 0.3);
    p.cubicTo(o.dx - s * 0.5, o.dy - s * 0.3, o.dx - s * 0.5, o.dy + s * 0.35,
        o.dx, o.dy + s * 0.7);
    p.cubicTo(o.dx + s * 0.5, o.dy + s * 0.35, o.dx + s * 0.5, o.dy - s * 0.3,
        o.dx, o.dy + s * 0.3);
    c.drawPath(p, Paint()..color = color);
  }

  void _sparkles(Canvas c, _Rnd r, double w, double h) {
    final n = 12 + r.intg(12);
    for (var i = 0; i < n; i++) {
      _star(c, Offset(r.range(0, w), r.range(0, h)), r.range(4, 14),
          Colors.white.withValues(alpha: r.range(0.15, 0.5)));
    }
  }

  void _star(Canvas c, Offset o, double s, Color color) {
    final p = Path();
    p.moveTo(o.dx, o.dy - s);
    p.quadraticBezierTo(o.dx, o.dy, o.dx + s, o.dy);
    p.quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + s);
    p.quadraticBezierTo(o.dx, o.dy, o.dx - s, o.dy);
    p.quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - s);
    c.drawPath(p, Paint()..color = color);
  }

  void _rings(Canvas c, _Rnd r, double w, double h) {
    final cx = r.range(w * 0.2, w * 0.8), cy = r.range(h * 0.2, h * 0.8);
    final n = 4 + r.intg(4);
    for (var i = 0; i < n; i++) {
      c.drawCircle(
        Offset(cx, cy),
        w * 0.12 * (i + 1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.10),
      );
    }
  }

  void _confetti(Canvas c, _Rnd r, double w, double h) {
    final n = 18 + r.intg(16);
    for (var i = 0; i < n; i++) {
      final o = Offset(r.range(0, w), r.range(0, h));
      final s = r.range(4, 10);
      c.save();
      c.translate(o.dx, o.dy);
      c.rotate(r.range(0, math.pi));
      c.drawRect(
        Rect.fromCenter(center: Offset.zero, width: s, height: s * 0.5),
        Paint()..color = Colors.white.withValues(alpha: r.range(0.08, 0.2)),
      );
      c.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ProceduralPainter old) => old.seed != seed;
}
