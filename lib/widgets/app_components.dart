import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isLoading;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isLoading = false,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null ? BorderSide(color: borderColor!) : BorderSide.none,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.white,
                ),
              ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      margin: margin ?? const EdgeInsets.all(8),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class ProgressRingWidget extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? child;

  const ProgressRingWidget({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 12,
    this.backgroundColor,
    this.progressColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Center content
          if (child != null) child!,
        ],
      ),
    );
  }
}

class AnimatedBottleWidget extends StatefulWidget {
  final double fillLevel;
  final double size;
  final Color? bottleColor;
  final Color? waterColor;

  const AnimatedBottleWidget({
    super.key,
    required this.fillLevel,
    this.size = 100,
    this.bottleColor,
    this.waterColor,
  });

  @override
  State<AnimatedBottleWidget> createState() => _AnimatedBottleWidgetState();
}

class _AnimatedBottleWidgetState extends State<AnimatedBottleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.fillLevel,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBottleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fillLevel != widget.fillLevel) {
      _animation = Tween<double>(
        begin: oldWidget.fillLevel,
        end: widget.fillLevel,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: BottlePainter(
            fillLevel: _animation.value,
            bottleColor: widget.bottleColor ?? Colors.blue[100]!,
            waterColor: widget.waterColor ?? Colors.blue[400]!,
          ),
        );
      },
    );
  }
}

class BottlePainter extends CustomPainter {
  final double fillLevel;
  final Color bottleColor;
  final Color waterColor;

  BottlePainter({
    required this.fillLevel,
    required this.bottleColor,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Draw bottle outline
    paint.color = bottleColor;
    final bottlePath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.1)
      ..lineTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.1)
      ..close();
    canvas.drawPath(bottlePath, paint);

    // Draw water
    if (fillLevel > 0) {
      paint.color = waterColor;
      final waterPath = Path()
        ..moveTo(size.width * 0.25, size.height * 0.8)
        ..lineTo(size.width * 0.25, size.height * (0.8 - fillLevel * 0.6))
        ..lineTo(size.width * 0.75, size.height * (0.8 - fillLevel * 0.6))
        ..lineTo(size.width * 0.75, size.height * 0.8)
        ..close();
      canvas.drawPath(waterPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 