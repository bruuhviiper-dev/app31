import 'package:flutter/material.dart';

/// Fundos-imagem ESTÉTICOS. Começa pelos temáticos originais (bokeh, céu,
/// corações, flores, pastel, pôr do sol — a identidade) e segue com 96 gerados
/// (pastel, flores, bokeh, corações, borboletas, lua, girassol, glitter — 8
/// cenas × 10 paletas × variações). Assets leves, offline.
class ImageBackgrounds {
  ImageBackgrounds._();

  static const List<String> _estetico = [
    'assets/backgrounds/bg_bokeh.png',
    'assets/backgrounds/bg_ceu.png',
    'assets/backgrounds/bg_coracoes.png',
    'assets/backgrounds/bg_flores.png',
    'assets/backgrounds/bg_pastel.png',
    'assets/backgrounds/bg_pordosol.png',
  ];

  static List<String> get all => [
        ..._estetico,
        for (var i = 1; i <= 96; i++)
          'assets/backgrounds/bg${i.toString().padLeft(2, '0')}.jpg',
      ];
}

/// Filtros de cor aplicados por cima do fundo (tinta translúcida). Dão a
/// sensação de "mais opções" sem precisar de mil imagens.
class CardFilters {
  CardFilters._();

  static const List<String> names = [
    'Original',
    'Quente',
    'Frio',
    'Rosé',
    'Vintage',
    'Escuro',
    'Claro',
  ];

  /// Cor da tinta do filtro [i] (0 = Original / sem filtro).
  static Color? color(int i) => switch (i) {
        1 => const Color(0x33FF7A18), // quente
        2 => const Color(0x332A6FFF), // frio
        3 => const Color(0x33FF3D8B), // rosé
        4 => const Color(0x40C9A24B), // vintage
        5 => const Color(0x59000000), // escuro
        6 => const Color(0x26FFFFFF), // claro
        _ => null,
      };
}
