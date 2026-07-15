import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

// 問題：日本語
const ja = [
  '研究',
  '仮説',
  '目的',
  '根拠・証拠',
  '方法・手法',
  '分析',
  '結果',
  '考察',
  '結論',
  '制約・限界',
  '影響・示唆',
  '相関関係',
  '重要な・有意な',
  '示す',
  '提案する・示唆する',
  '実証する',
  '比較する',
  '評価する',
];

// 答え：英語
const en = [
  'research',
  'hypothesis',
  'objective',
  'evidence',
  'methodology',
  'analysis',
  'result',
  'discussion',
  'conclusion',
  'limitation',
  'implication',
  'correlation',
  'significant',
  'indicate',
  'suggest',
  'demonstrate',
  'compare',
  'evaluate',
];

String egg(int level) {
  if (level >= 4) return '🔬';
  if (level >= 3) return '🥼';
  if (level >= 2) return '🧫';
  if (level >= 1) return '🔭';
  return '🧪';
}

void main() {
  final step = ValueNotifier(0);

  runApp(
    MaterialApp(
      home: ValueListenableBuilder(
        valueListenable: step,
        builder: (context, count, _) {
          final i = (count ~/ 2) % en.length;
          final level = (count ~/ 2) ~/ en.length;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text('${egg(level)}論文執筆でよく出てくる英単語 ${level + 1}巡目'),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: count.isEven
                ? const Color.fromARGB(255, 255, 201, 201)
                : const Color.fromARGB(255, 173, 229, 255),
            body: Stack(
              children: [
                Positioned.fill(child: Bubbles(isPink: count.isEven)),
                Positioned.fill(
                  child: InkWell(
                    onTap: () => step.value++,
                    splashFactory: InkRipple.splashFactory,
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      final color = count.isEven
                          ? const Color(0xFFF8D4DC)
                          : const Color(0xFFCFEEF8);
                      if (states.contains(WidgetState.pressed)) {
                        return color.withValues(alpha: 0.42);
                      }
                      if (states.contains(WidgetState.hovered)) {
                        return color.withValues(alpha: 0.18);
                      }
                      return Colors.transparent;
                    }),
                    child: Center(
                      child: Text(
                        count.isEven ? 'JA: ${ja[i]}' : 'EN: ${en[i]}',
                        style: const TextStyle(fontSize: 64),
                      ),
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

class Bubbles extends StatefulWidget {
  const Bubbles({super.key, required this.isPink});

  final bool isPink;

  @override
  State<Bubbles> createState() => _BubblesState();
}

class _BubblesState extends State<Bubbles> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: BubblePainter(controller, isPink: widget.isPink),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class BubblePainter extends CustomPainter {
  BubblePainter(this.animation, {required this.isPink})
    : super(repaint: animation);

  final Animation<double> animation;
  final bool isPink;

  static const blueColors = [
    Color(0x669EDFF2),
    Color(0x66CFEEF8),
    Color(0x66FFFFFF),
  ];

  static const pinkColors = [
    Color(0x66F2A9B8),
    Color(0x66F8D4DC),
    Color(0x66FFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final colors = isPink ? pinkColors : blueColors;

    for (var i = 0; i < 18; i++) {
      final phase = (animation.value + i / 18) % 1.0;
      final radius = 12.0 + (i % 5) * 7;
      final baseX = size.width * ((i * 37 % 100) / 100);
      final sway = math.sin(phase * math.pi * 2 + i) * 20;
      final center = Offset(
        baseX + sway,
        size.height + radius - phase * (size.height + radius * 2),
      );

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) => oldDelegate.isPink != isPink;
}
