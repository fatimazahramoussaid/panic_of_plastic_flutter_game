import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:leap/leap.dart';
import 'package:pathxp/pathxp.dart';
import 'package:panic_of_plastic/game/game.dart';

enum EnemyType {
  unknown, hole;

  static EnemyType fromValue(String value) {
    if (value == 'hole') {
      return EnemyType.hole;
    } 
    return EnemyType.unknown;
  }
}

class Enemy extends PhysicalEntity<PanicGame> {
  Enemy({
    required this.tiledObject,
    this.enemyDamage = 1,
  })  : type = EnemyType.fromValue(
          (tiledObject.properties.byName['Type'] as StringProperty?)?.value ??
              '',
        ),
        super(
          collisionType: CollisionType.standard,
          static: tiledObject.properties.byName['Fly']?.value as bool? ?? false,
        );

  final int enemyDamage;
  late final EnemyType type;
  late final TiledObject tiledObject;

  @override
  int get priority => 1;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(gameRef.tileSize * 4);
    position = Vector2(tiledObject.x, tiledObject.y);

    final path =
        (tiledObject.properties.byName['Path'] as StringProperty?)?.value;

    if (path != null) {
      final pathXp = Pathxp(path);
      add(FollowPathBehavior(pathXp));
    }

    final spritePosition = size / 2 - Vector2(0, size.y / 2);

     if (type == EnemyType.hole) {
     
    size = Vector2.array([243,251]);
    

    final spriteBlock = await gameRef.loadSprite(
        'objects/black_hole.png'
      );
      add(
        SpriteComponent(
          sprite: spriteBlock,
          size: (size),
        ),
      );
    }   else {
      add(
        RectangleComponent(
          size: Vector2.all(gameRef.tileSize),
          paint: Paint()..color = Colors.pink,
          anchor: Anchor.center,
          position: spritePosition,
        ),
      );
    }

    return super.onLoad();
  }
}
