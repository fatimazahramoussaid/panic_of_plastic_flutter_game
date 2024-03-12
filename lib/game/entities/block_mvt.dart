import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:leap/leap.dart';
import 'package:panic_of_plastic/game/panic_of_plastic_game.dart';



class BlockMvt extends PhysicalEntity<PanicGame> {
  BlockMvt({
    required this.tiledObject,
  }) : super(static: true, collisionType: CollisionType.standard);

  late final TiledObject tiledObject;

  @override
  int get priority => 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.array([300,60]);
    //tiledObject.y = tiledObject.y -64;

    var type = (tiledObject.properties.byName['Type'] as StringProperty?)?.value;

    position = Vector2(tiledObject.x, tiledObject.y);
    var img = 'objects/tretoir1.png';
    

    if(type == 'wall') {
      img = 'objects/wall-1.png'; 
    }
    if(type == 'barriere') {
      size = Vector2.array([121,91]);
      img = 'objects/barriere.png'; 
    }

    if(type == 'teleport') {
      size = Vector2.array([256,181]);
      img = 'objects/teleport.png'; 
    }
    final spriteBlock = await gameRef.loadSprite(
        img
      );
      add(
        SpriteComponent(
          sprite: spriteBlock,
          size: (size),
        ),
      );
  }
}
