import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';

void main() {
  runApp(GameWidget(game: TapGame()));
}

class TapGame extends FlameGame with TapCallbacks {
  final Random _rng = Random();

  final double _radius = 32;

  final TextComponent _scoreText = TextComponent(
    text: 'Score: 0',
    position: Vector2(16, 12),
    anchor: Anchor.topLeft,
    textRenderer: TextPaint(style: TextStyle(fontSize: 20)),
  );

  final TextComponent _timeText = TextComponent(
    text: 'Time: 10.0',
    position: Vector2(16, 40),
    anchor: Anchor.topLeft,
    textRenderer: TextPaint(style: TextStyle(fontSize: 20)),
  );

  final TextComponent _statusText = TextComponent(
    text: '',
    anchor: Anchor.center,
    position: Vector2.zero(),
    textRenderer: TextPaint(style: TextStyle(fontSize: 28)),
  );

  late final CircleComponent _target = CircleComponent(
    radius: _radius,
    anchor: Anchor.center,
    position: Vector2.zero(),
  );

  int _score = 0;
  double _timeLeft = 10.0;
  bool _isOver = false;

  @override
  Future<void> onLoad() async {
    _target.position = _randomTargetPosition();
    add(_target);
    add(_scoreText);
    add(_timeText);
    add(_statusText);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _statusText.position = size / 2;
    if (!_isOver) {
      _target.position = _clampToBounds(_target.position);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isOver) return;

    _timeLeft -= dt;
    if (_timeLeft <= 0) {
      _timeLeft = 0;
      _isOver = true;
      _statusText.text = 'Game Over\nScore: $_score\nTap to restart';
      _timeText.text = 'Time: 0.0';
      return;
    }

    _timeText.text = 'Time: ${_timeLeft.toStringAsFixed(1)}';
  }

  @override
  void onTapDown(TapDownEvent event) {
    final p = event.localPosition;

    if (_isOver) {
      _restart();
      return;
    }

    if (_hitTarget(p)) {
      _score++;
      _scoreText.text = 'Score: $_score';
      _target.position = _randomTargetPosition();
    }
  }

  bool _hitTarget(Vector2 p) {
    return p.distanceTo(_target.position) <= _radius;
  }

  void _restart() {
    _score = 0;
    _timeLeft = 10.0;
    _isOver = false;
    _statusText.text = '';
    _scoreText.text = 'Score: 0';
    _timeText.text = 'Time: 10.0';
    _target.position = _randomTargetPosition();
  }

  Vector2 _randomTargetPosition() {
    final w = size.x;
    final h = size.y;
    if (w <= 0 || h <= 0) return Vector2.zero();

    final r = _radius;
    final x = r + _rng.nextDouble() * max(1.0, w - 2 * r);
    final y = r + _rng.nextDouble() * max(1.0, h - 2 * r);
    return Vector2(x, y);
  }

  Vector2 _clampToBounds(Vector2 p) {
    final r = _radius;
    final x = p.x.clamp(r, max(r, size.x - r)).toDouble();
    final y = p.y.clamp(r, max(r, size.y - r)).toDouble();
    return Vector2(x, y);
  }
}
