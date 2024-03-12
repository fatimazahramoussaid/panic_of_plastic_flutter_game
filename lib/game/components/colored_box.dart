import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:panic_of_plastic/game/entities/player.dart';

class ColoredSquare extends PositionComponent with CollisionCallbacks {
  ColoredSquare(Vector2 position, [this.color = const Color(0xFF000000)])
      : super(
          anchor: Anchor.center,
          position: position,
          priority: 100,
          size: Vector2.all(10),
        );

  factory ColoredSquare.red(Vector2 position) => ColoredSquare(
        position,
        Color.fromARGB(255, 0, 17, 255),
      );

  factory ColoredSquare.green(Vector2 position) => ColoredSquare(
        position,
        const Color(0xFF00FF00),
      );

  factory ColoredSquare.blue(Vector2 position) => ColoredSquare(
        position,
        Color.fromARGB(255, 179, 255, 0),
      );

  final Color color;

  @override
  void onLoad() {
    add(
      RectangleComponent(
        paint: Paint()..color = color,
        size: size,
      ),
    );
  }

  
}


