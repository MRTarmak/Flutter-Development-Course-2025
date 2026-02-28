import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: PhysicsSandbox(),
    ),
  );
}

class PhysicsSandbox extends Forge2DGame with TapCallbacks {
  PhysicsSandbox()
      : super(
          gravity: Vector2(0, 50),
          zoom: 1,
        );

  final _rng = Random();

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    final w = size.x / camera.viewfinder.zoom;
    final h = size.y / camera.viewfinder.zoom;

    add(Wall(Vector2(0, h), Vector2(w, h)));
    add(Wall(Vector2(0, 0), Vector2(0, h)));
    add(Wall(Vector2(w, 0), Vector2(w, h)));
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final position = screenToWorld(event.localPosition);

    if (_rng.nextBool()) {
      add(Ball(position, radius: _rng.nextInt(25) + 10));
    } else {
      add(Box(position, halfSize: _rng.nextInt(25) + 10));
    }
  }
}

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape, friction: 0.5);
    final bodyDef = BodyDef(position: Vector2.zero());
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }
}

class Ball extends BodyComponent {
  final Vector2 initialPosition;
  final double radius;

  Ball(this.initialPosition, {this.radius = 1.0});

  late final Color _color;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final hue = Random().nextDouble() * 360;
    _color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      density: 1.0,
      restitution: 0.5,
      friction: 0.4,
    );
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      angularDamping: 0.8,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _color;
    canvas.drawCircle(Offset.zero, radius, paint);

    final linePaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset.zero, Offset(radius, 0), linePaint);
  }
}

class Box extends BodyComponent {
  final Vector2 initialPosition;
  final double halfSize;

  Box(this.initialPosition, {this.halfSize = 1.0});

  late final Color _color;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final hue = Random().nextDouble() * 360;
    _color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(halfSize, halfSize, Vector2.zero(), 0);
    final fixtureDef = FixtureDef(
      shape,
      density: 1.5,
      restitution: 0.3,
      friction: 0.6,
    );
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      angularDamping: 0.8,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _color;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: halfSize * 2,
      height: halfSize * 2,
    );
    canvas.drawRect(rect, paint);
  }
}
