import 'dart:ui';


import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:panic_of_plastic/audio/audio.dart';
import 'package:panic_of_plastic/game/game.dart';
import 'package:panic_of_plastic/game/utilities/movement.dart';
import '../../constants.dart';

import 'package:leap/leap.dart';


class Unwalk {
  double x1;
  double x2;
  double y1;
  double y2;
  double newX, newY;

   Unwalk({required this.x1, required this.x2, required this.y1, required this.y2, required this.newX, required this.newY}) {
      x1 = x1;
      x2 = x2;
      y1 = y1;
      y2 = y2;
      newX = newX;
      newY = newY;
   }
   
     bool collide(double x, double y) {
      return (x <= x2 && x >= x1 && y <= y2 && y >= y1 ) ;
     }

}

class Player extends PhysicalEntity<PanicGame>
    with
        CollisionCallbacks,
        KeyboardHandler,
        HasGameReference<PanicGame>,
        UnwalkableTerrainChecker {
  Player({required this.levelSize,required this.cameraViewport }) {
    halfSize = size / 2;
  }

  // final CollisionInfo collisionInfo = CollisionInfo();
  final Vector2 levelSize;
  final Vector2 cameraViewport;
  final int health = 1;
  late Vector2 halfSize;
  late Vector2 maxPosition = levelSize - halfSize;
  Vector2 movement = Vector2.zero();
  // ignore: non_constant_identifier_names
  final bloc_list = <Unwalk>[];
  Vector2  prec_movement = Vector2.zero();
  double speed = worldTileSize * 4;
  AssetBundle? customBundle;
  bool running = false;
  bool hasStarted = false;
  double? _gameOverTimer;
  
  double get_value(object, value) {
    return double.parse((object.properties.byName[value] as StringProperty?)!.value);
  }

  void  add_bloc_list(TiledObject object){
     double newX = get_value(object, 'newX');
     double newY = get_value(object, 'newY');
     bloc_list.add(Unwalk(x1: object.x, x2: object.height + object.x, y1: object.y, y2: object.width + object.y, newX : newX, newY : newY));
  }

  late final PlayerStateBehavior stateBehavior = findBehavior<PlayerStateBehavior>();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world.gravity = 0;
    var cameraAnchor = PlayerCameraAnchor(
      cameraViewport: cameraViewport,
      levelSize: levelSize,
      showCameraBounds: false,
    );
    add(cameraAnchor);
    game.camera.follow(cameraAnchor);

    add(PlayerStateBehavior());
    add(PlayerControllerBehavior());

    position.x = 1000;
    position.y = 500;
    
  }

  bool had_collide() {
    for (final bloc in bloc_list) {
      if (bloc.collide(position.x, position.y)) {
        position.x = bloc.newX;
        position.y = bloc.newY;
       return true;
      }
    }
    return false;
  }

  @override
  void update(double dt) {
    if (movement == Vector2.zero() && ! hasStarted) {
      return;
    }
    hasStarted = true;
    
    final originalPosition = position.clone();
    bool iscollide = had_collide();

    final collisions = collisionInfo.otherCollisions ?? const [];

    if (_gameOverTimer != null) {
      _gameOverTimer = _gameOverTimer! - dt;
      if (_gameOverTimer! <= 0) {
        _gameOverTimer = null;
        gameRef.gameOver();
      }
      return;
    }


    for (final collision in collisions) {
      if (collision is Item) {
        switch (collision.type) {
          case ItemType.acorn || ItemType.egg:
            gameRef.audioController.playSfx(
              collision.type == ItemType.acorn
                  ? Sfx.acornPickup
                  : Sfx.acornPickup,
            );
            gameRef.gameBloc.add(
              GameScoreIncreased(by: collision.type.points),
            );
          case ItemType.goldenFeather:
            print('not implemented');
        }
        gameRef.world.add(
          ItemEffect(
            type: collision.type,
            position: collision.position.clone(),
          ),
        );
        collision.removeFromParent();
      }

      if (collision is Enemy) {
        // If player has no golden feathers, game over.
        health -= collision.enemyDamage;
        return _animateToGameOver();
      }
    
    
    }

   
   if(iscollide) {
      position.x =  position.x + movement.x * (-5);
      position.y =  position.y + movement.y * (-5);
      gameRef.audioController.playSfx(Sfx.botTeleported);
   } else {
      final movementThisFrame = movement * 5 * dt;
      checkMovement(
        movementThisFrame: movementThisFrame,
        originalPosition: originalPosition,
      );
      position.add(movementThisFrame);
      
      if (prec_movement.x == -1 && prec_movement.y == 0) {
        position.x -= 10;
      }
      if (prec_movement.x == 1 && prec_movement.y == 0) {
        position.x += 10;
      }
      if (prec_movement.x == 0 && prec_movement.y == -1) {
        position.y -= 10;
      }
      if (prec_movement.x == 0 && prec_movement.y == 1) {
        position.y += 10;
      }
      if (prec_movement.x == 0 && prec_movement.y == 0) {
        position.y += 10;
      }

   }
    
    
}


  void _animateToGameOver([DashState deathState = DashState.deathFaint]) {
    stateBehavior.state = deathState;
    _gameOverTimer = 1.4;
    gameRef.audioController.playSfx( Sfx.dead );
  }



  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    prec_movement = movement.clone();
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        hasStarted = true;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        movement = Vector2(movement.x, -1);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        movement = Vector2(movement.x, 1);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        movement = Vector2(-1, movement.y);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        movement = Vector2(1, movement.y);
      }
      return false;
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        movement.y = keysPressed.contains(LogicalKeyboardKey.arrowDown) ? 1 : 0;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        movement.y = keysPressed.contains(LogicalKeyboardKey.arrowUp) ? -1 : 0;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        movement.x = keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        movement.x = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
      }
      return false;
    }
    return true;
  }


  void setRunningState() {
    stateBehavior.state = DashState.running;
  }

}
