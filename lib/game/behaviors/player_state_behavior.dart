import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:panic_of_plastic/game/game.dart';

enum DashState {
  idle,
  running,
  deathFaint
}

class PlayerStateBehavior extends Behavior<Player> {
  DashState? _state;

  DashState get state => _state ?? DashState.idle;

  late final Map<DashState, PositionComponent> _stateMap;

  static const _needResetStates = {
    DashState.deathFaint
  };

  void updateSpritePaintColor(Color color) {
    for (final component in _stateMap.values) {
      if (component is HasPaint) {
        (component as HasPaint).paint.color = color;
      }
    }
  }

  void fadeOut({VoidCallback? onComplete}) {
    final component = _stateMap[state];
    if (component != null && component is HasPaint) {
      component.add(
        OpacityEffect.fadeOut(
          EffectController(duration: .5),
          onComplete: onComplete,
        ),
      );
    }
  }

  void fadeIn({VoidCallback? onComplete}) {
    final component = _stateMap[state];
    if (component != null && component is HasPaint) {
      component.add(
        OpacityEffect.fadeIn(
          EffectController(duration: .5, startDelay: .8),
          onComplete: onComplete,
        ),
      );
    }
  }

  set state(DashState state) {
    if (state != _state) {
      final current = _stateMap[_state];

      if (current != null) {
        current.removeFromParent();

        if (current is SpriteAnimationComponent) {
            current.animationTicker?.reset();
         }
      }

      final replacement = _stateMap[state];
      if (replacement != null) {
        parent.add(replacement);
      }
      _state = state;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final [
      idleAnimation,
      runningAnimation,
      deathFaintAnimation
    ] = await Future.wait(
      [
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_dash_idle.png',
          SpriteAnimationData.sequenced(
            amount: 18,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/mybot-running.png',
          SpriteAnimationData.sequenced(
            amount: 5,
            stepTime: 0.042,
            textureSize: Vector2.all(100),
          ),
        ),
        parent.gameRef.loadSpriteAnimation(
          'anim/spritesheet_dash_deathFaint.png',
          SpriteAnimationData.sequenced(
            amount: 24,
            stepTime: 0.042,
            textureSize: Vector2.all(parent.gameRef.tileSize),
            amountPerRow: 8,
            loop: false,
          ),
        ),
      ],
    );

    final paint = Paint()..isAntiAlias = false;

    final centerPosition = parent.size / 2 - Vector2(0, parent.size.y / 2);
    _stateMap = {
      DashState.idle: SpriteAnimationComponent(
        animation: idleAnimation,
        anchor: Anchor.center,
        position: centerPosition.clone(),
        paint: paint,
      ),
      DashState.running: SpriteAnimationComponent(
        animation: runningAnimation,
        anchor: Anchor.center,
        position: centerPosition.clone(),
        paint: paint,
      ),
      DashState.deathFaint: SpriteAnimationComponent(
        animation: deathFaintAnimation,
        anchor: Anchor.center,
        position: centerPosition.clone(),
        paint: paint,
      ),

    };

    state = DashState.idle;
  }
}
