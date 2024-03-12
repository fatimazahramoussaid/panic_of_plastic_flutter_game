import 'dart:async';

import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:panic_of_plastic/game/game.dart';

class PlayerControllerBehavior extends Behavior<Player> {

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    parent.gameRef.addInputListener(_handleInput);
  }

  @override
  void onRemove() {
    super.onRemove();

    parent.gameRef.removeInputListener(_handleInput);
  }

  void _handleInput() {
    if (parent.isDead) {
      return;
    }

    // If is no walking, start walking
    if (!parent.running) {
      parent.running = true;
      return;
    }

  
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (parent.isDead) {
      return;
    }

    parent.setRunningState();
    

  }

  
}
