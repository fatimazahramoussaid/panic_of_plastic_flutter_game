import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart' as col;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leap/leap.dart';
import 'package:panic_of_plastic/audio/audio.dart';
import 'package:panic_of_plastic/game/components/line_component.dart';
import 'package:panic_of_plastic/game/components/unwalkable_component.dart';
import 'package:panic_of_plastic/game/game.dart';
import 'package:panic_of_plastic/game/utilities/line.dart';
import 'package:panic_of_plastic/score/score.dart';

bool _tsxPackingFilter(Tileset tileset) {
  return !(tileset.source ?? '').startsWith('anim');
}

Paint _layerPaintFactory(double opacity) {
  return Paint()
    ..color = Color.fromRGBO(255, 255, 255, opacity)
    ..isAntiAlias = false;
}

class PanicGame extends LeapGame
    with TapDetector, HasCollisionDetection, HasKeyboardHandlerComponents {
  PanicGame({
    required this.gameBloc,
    required this.audioController,
    this.customBundle,
    this.inMapTester = true,
  }) : super(
          tileSize: 64,
          configuration: const LeapConfiguration(
            tiled: TiledOptions(
              slopeLeftTopProperty: 'LeftTop',
              atlasMaxX: 4048,
              atlasMaxY: 4048,
              tsxPackingFilter: _tsxPackingFilter,
              layerPaintFactory: _layerPaintFactory,
              atlasPackingSpacingX: 4,
              atlasPackingSpacingY: 4,
            ),
          ),
        );

  static final _cameraViewport = Vector2(592, 1024);
  static const prefix = 'assets/map/';
  static const _sections = [
    'flutter_runnergame_map_A.tmx',
    'flutter_runnergame_map_B.tmx',
    'flutter_runnergame_map_C.tmx',
  ];
  static const _sectionsBackgroundColor = [
    (Color(0xFFDADEF6), Color(0xFFEAF0E3)),
    (Color(0xFFEBD6E1), Color(0xFFC9C8E9)),
    (Color(0xFF002052), Color(0xFF0055B4)),
  ];

  //late final SimpleCombinedInput input;
  final GameBloc gameBloc;
  final AssetBundle? customBundle;
  final AudioController audioController;
  final List<VoidCallback> _inputListener = [];
  late final SimpleCombinedInput input;

  late final SpriteSheet itemsSpritesheet;
  final bool inMapTester;

  final unwalkableComponentEdges = <Line>[];

  GameState get state => gameBloc.state;

  Player? get player => world.firstChild<Player>();

  List<Tileset> get tilesets => leapMap.tiledMap.tileMap.map.tilesets;

  Tileset get itemsTileset {
    return tilesets.firstWhere(
      (tileset) => tileset.name == 'plastic_bags',
    );
  }

  Tileset get enemiesTileset {
    return tilesets.firstWhere(
      (tileset) => tileset.name == 'enemies',
    );
  }

  Tileset get blockTileset {
    return tilesets.firstWhere(
      (tileset) => tileset.name == 'tretoir1',
    );
  }

  void addInputListener(VoidCallback listener) {
    _inputListener.add(listener);
  }

  void removeInputListener(VoidCallback listener) {
    _inputListener.remove(listener);
  }

  void _triggerInputListeners() {
    for (final listener in _inputListener) {
      listener();
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    _triggerInputListeners();
    overlays.remove('tapToJump');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (inMapTester) {
      _addMapTesterFeatures();
    }

    if (kIsWeb && audioController.isMusicEnabled) {
      audioController.startMusic();
    }

    camera = CameraComponent.withFixedResolution(
      width: _cameraViewport.x,
      height: _cameraViewport.y,
    )..world = world;

    images = Images(
      prefix: prefix,
      bundle: customBundle,
    );

    itemsSpritesheet = SpriteSheet(
      image: await images.load('objects/plastic_bags.png'),
      srcSize: Vector2.all(128),
    );

    await loadWorldAndMap(
      images: images,
      prefix: prefix,
      bundle: customBundle,
      tiledMapPath: _sections.first,
    );
    _setSectionBackground();
    final player = Player(
      levelSize: leapMap.tiledMap.size.clone(),
      cameraViewport: _cameraViewport,
    );

    final objectLayer = leapMap.tiledMap.tileMap.getLayer<ObjectGroup>('blocks_mvt')!;
    for (final TiledObject object in objectLayer.objects) {
       player.add_bloc_list(object);
    }
    unawaited(
      world.addAll([player]),
    );

    await _addSpawners();

    
   
   add(
      KeyboardListenerComponent(
        keyDown: {
          LogicalKeyboardKey.space: (_) {
            _triggerInputListeners();
            overlays.remove('tapToJump');
            return false;
          },
        },
        keyUp: {
          LogicalKeyboardKey.space: (_) {
            return false;
          },
        },
      ),
    );



   /*final objectLayer = leapMap.tiledMap.tileMap.getLayer<ObjectGroup>('blocks')!;
    for (final TiledObject object in objectLayer.objects) {
      if (!object.isPolygon) continue;
      if (!object.properties.byName.containsKey('blocksMovement')) return;
      final vertices = <Vector2>[];
      Vector2? lastPoint;
      Vector2? nextPoint;
      Vector2? firstPoint;
      for (final point in object.polygon) {
        nextPoint = Vector2((point.x + object.x) * 64,
            (point.y + object.y) * 64);
        firstPoint ??= nextPoint;
        vertices.add(nextPoint);

        // If there is a last point, or this is the end of the list, we have a
        // line to add to our cached list of lines
        if (lastPoint != null) {
          unwalkableComponentEdges.add(Line(lastPoint, nextPoint));
        }
        lastPoint = nextPoint;
      }
      unwalkableComponentEdges.add(Line(lastPoint!, firstPoint!));
      print('----------------------------------------------------------------------');
      add(UnwalkableComponent(vertices));
    }

    for (final line in unwalkableComponentEdges) {
      add(LineComponent.red(line: line, thickness: 3));
    }
*/

    //addCameraDebugger();

    // showHitBoxes();
  }





  void _setSectionBackground() {
    final colors = _sectionsBackgroundColor[state.currentSection];
    camera.backdrop = RectangleComponent(
      size: size.clone(),
      paint: Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.x, size.y),
          [
            colors.$1,
            colors.$2,
          ],
        ),
    );
  }

  void gameOver() {
    gameBloc.add(const GameOver());
    // Removed since the result didn't ended up good.
    // Leaving in comment if we decide to bring it back.
    // audioController.stopBackgroundSfx();

    world.firstChild<Player>()?.removeFromParent();

    _resetEntities();

    Future<void>.delayed(
      const Duration(seconds: 1),
      () async {
        await loadWorldAndMap(
          images: images,
          prefix: prefix,
          bundle: customBundle,
          tiledMapPath: _sections.first,
        );
        final newPlayer = Player(
          levelSize: leapMap.tiledMap.size.clone(),
          cameraViewport: _cameraViewport,
        );
        await world.add(newPlayer);

        await newPlayer.mounted;
        await _addSpawners();
       // overlays.add('tapToJump');
      },
    );

    if (buildContext != null) {
      final score = gameBloc.state.score;
      Navigator.of(buildContext!).push(
        ScorePage.route(score: score),
      );
    }
  }

  void _resetEntities() {
    children.whereType<ObjectGroupProximityBuilder<Player>>().forEach(
          (spawner) => spawner.removeFromParent(),
        );
    leapMap.children
        .whereType<Enemy>()
        .forEach((enemy) => enemy.removeFromParent());
    leapMap.children
        .whereType<Item>()
        .forEach((enemy) => enemy.removeFromParent());
  }

  Future<void> _addSpawners() async {
    await addAll([
      ObjectGroupProximityBuilder<Player>(
        proximity: _cameraViewport.y * 1.5,
        tileLayerName: 'items',
        tileset: itemsTileset,
        componentBuilder: Item.new,
      ),
      ObjectGroupProximityBuilder<Player>(
        proximity: _cameraViewport.y * 1.5,
        tileLayerName: 'enemies',
        tileset: enemiesTileset,
        componentBuilder: Enemy.new,
      ),
      ObjectGroupProximityBuilder<Player>(
        proximity: _cameraViewport.y * 1.5,
        tileLayerName: 'blocks_mvt',
        tileset: blockTileset,
        componentBuilder: BlockMvt.new,
      )
    ]);
  }

  Future<void> _loadNewSection() async {
    final nextSectionIndex = state.currentSection + 1 < _sections.length
        ? state.currentSection + 1
        : 0;

    final nextSection = _sections[nextSectionIndex];

    _resetEntities();

    await loadWorldAndMap(
      images: images,
      prefix: prefix,
      bundle: customBundle,
      tiledMapPath: nextSection,
    );

    await _addSpawners();
  }

  @override
  void onMapUnload(LeapMap map) {
     player?.velocity.setZero();
    _addSpawners();
  }

  /*@override
  void onMapLoaded(LeapMap map) {
    player?.loadSpawnPoint();
    player?.loadRespawnPoints();
    player?.walking = true;
    player?.spritePaintColor(Colors.white);
    player?.isPlayerTeleporting = false;

    _setSectionBackground();
  }*/

  void sectionCleared() {
   /* if (isLastSection) {
      player?.spritePaintColor(Colors.transparent);
      player?.walking = false;
    }
*/
    _loadNewSection();

    gameBloc
      ..add(GameScoreIncreased(by: 1000 * state.currentLevel))
      ..add(GameSectionCompleted(sectionCount: _sections.length));
  }

  bool get isLastSection => state.currentSection == _sections.length - 1;
  bool get isFirstSection => state.currentSection == 0;


  void toggleInvincibility() {
    //player?.isPlayerInvincible = !(player?.isPlayerInvincible ?? false);
  }

  void teleportPlayerToEnd() {
    player?.y = leapMap.tiledMap.size.y - (player?.size.y ?? 0) * 10 * 4;
    if (state.currentSection == 2) {
      player?.y = (player?.y ?? 0) - (tileSize * 4);
    }
  }

  void showHitBoxes() {
    void show() {
      descendants()
          .whereType<PhysicalEntity>()
          .where(
            (element) =>
                element is Player || element is Item || element is Enemy,
          )
          .forEach((entity) => entity.debugMode = true);
    }

    show();
    add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: show,
      ),
    );
  }

  void _addMapTesterFeatures() {
    add(FpsComponent());
    add(
      FpsTextComponent(
        position: Vector2(0, 0),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
