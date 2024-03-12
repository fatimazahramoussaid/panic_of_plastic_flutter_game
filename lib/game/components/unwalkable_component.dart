import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:panic_of_plastic/game/entities/player.dart';

class UnwalkableComponent extends PolygonComponent  with CollisionCallbacks {
  UnwalkableComponent(super._vertices);

}
