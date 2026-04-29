import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';

class ResultSection extends StatelessWidget {
  final MainViewModel vm;
  final bool embedded;

  const ResultSection({super.key, required this.vm, this.embedded = false});

  double _parseProgress(String result) {
    if (result.isEmpty) return 0.0;
    return (double.tryParse(result.replaceAll('%', '').trim()) ?? 0.0) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final isCalculating = vm.myCards.length == 2 && vm.result.isEmpty;
    final progress = _parseProgress(vm.result);

    return _WinGauge(
      progress: progress,
      label: vm.result,
      isCalculating: isCalculating,
      hasCards: vm.myCards.isNotEmpty,
    );
  }
}

class _WinGauge extends StatefulWidget {
  final double progress;
  final String label;
  final bool isCalculating;
  final bool hasCards;

  const _WinGauge({
    required this.progress,
    required this.label,
    required this.isCalculating,
    required this.hasCards,
  });

  @override
  State<_WinGauge> createState() => _WinGaugeState();
}

class _WinGaugeState extends State<_WinGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    if (widget.progress > 0) _controller.forward();
  }

  @override
  void didUpdateWidget(_WinGauge old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _animation = Tween<double>(
        begin: old.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = math.min(constraints.maxWidth, 280.0);
        const strokeWidth = 13.0;
        const padding = 14.0;
        final radius = maxW / 2 - strokeWidth / 2 - padding;
        final arcCenterY = radius + strokeWidth / 2 + padding;
        final totalHeight = arcCenterY + 56.0;

        return Center(
          child: SizedBox(
            width: maxW,
            height: totalHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(maxW, totalHeight),
                      painter: _GaugePainter(
                        progress: widget.isCalculating ? 0.0 : _animation.value,
                        arcCenterY: arcCenterY,
                        radius: radius,
                        strokeWidth: strokeWidth,
                        dim: !widget.hasCards,
                      ),
                    );
                  },
                ),
                if (widget.isCalculating)
                  Positioned(
                    top: arcCenterY - 10,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.withOpacity(AppColors.textSecondary, 0.7),
                        ),
                      ),
                    ),
                  )
                else if (widget.label.isNotEmpty)
                  Positioned(
                    top: arcCenterY - 4,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        widget.label,
                        key: ValueKey(widget.label),
                        style: TextStyle(
                          color: _gaugeColor(widget.progress),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  child: Text(
                    widget.hasCards ? 'WIN PROBABILITY' : 'Select your cards',
                    style: TextStyle(
                      color: widget.hasCards
                          ? AppColors.withOpacity(AppColors.textSecondary, 0.8)
                          : AppColors.withOpacity(AppColors.textSecondary, 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Color _gaugeColor(double p) {
  if (p <= 0) return AppColors.textSecondary;
  if (p < 0.5) {
    return Color.lerp(const Color(0xFFE53935), const Color(0xFFFF9800), p * 2)!;
  }
  return Color.lerp(const Color(0xFFFF9800), const Color(0xFF43A047), (p - 0.5) * 2)!;
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final double arcCenterY;
  final double radius;
  final double strokeWidth;
  final bool dim;

  const _GaugePainter({
    required this.progress,
    required this.arcCenterY,
    required this.radius,
    required this.strokeWidth,
    required this.dim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, arcCenterY);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(
      rect,
      math.pi,
      -math.pi,
      false,
      Paint()
        ..color = AppColors.withOpacity(Colors.white, dim ? 0.04 : 0.09)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    final color = _gaugeColor(progress);
    final sweep = -math.pi * progress.clamp(0.0, 1.0);

    // Glow
    canvas.drawArc(
      rect,
      math.pi,
      sweep,
      false,
      Paint()
        ..color = AppColors.withOpacity(color, 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Arc
    canvas.drawArc(
      rect,
      math.pi,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.dim != dim;
}
