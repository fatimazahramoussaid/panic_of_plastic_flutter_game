import 'package:flame/components.dart';
import 'package:leap/leap.dart';
import 'package:panic_of_plastic/game/components/unwalkable_component.dart';
import 'package:panic_of_plastic/game/game.dart';


mixin UnwalkableTerrainChecker
    on PositionComponent, HasGameReference<PanicGame> {
  void checkMovement({
    required Vector2 movementThisFrame,
    required Vector2 originalPosition,
  }) {
    if (movementThisFrame.y < 0) {
      final newTop = positionOfAnchor(Anchor.topCenter);
      for (final component in game.world.componentsAtPoint(newTop)) {
        if (! is_onGround(component)){
          movementThisFrame.y = 0;
          break;
        }
      }
    }
    if (movementThisFrame.y > 0) {
      final newBottom = positionOfAnchor(Anchor.bottomCenter);
      for (final component in game.world.componentsAtPoint(newBottom)) {
        if (! is_onGround(component)){
          movementThisFrame.y = 0;
          break;
        }
      }
    }
    
    if (movementThisFrame.x < 0) {
      final newLeft = positionOfAnchor(Anchor.centerLeft);
      for (final component in game.world.componentsAtPoint(newLeft)) {
        if (! is_onGround(component)){
          movementThisFrame.x = 0;
          break;
        }
      }
    }
    if (movementThisFrame.x > 0) {
      final newRight = positionOfAnchor(Anchor.centerRight);
      for (final component in game.world.componentsAtPoint(newRight)) {
        if (! is_onGround(component)) {
          movementThisFrame.x = 0;
          break;
        }
      }
    }
    position = originalPosition..add(movementThisFrame);
    final halfSize = size / 2;
    // map_size
    position.clamp(halfSize, Vector2(2556, 9984) - halfSize);
  }

  bool is_onGround(component) {
    return true;
    /*if (component.isOnGround) {
            return true;
        } else {
          return false;
        }
  }*/
  }
}
