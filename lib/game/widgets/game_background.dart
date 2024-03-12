import 'package:flutter/material.dart';
import 'package:panic_of_plastic/gen/assets.gen.dart';

class GameBackground extends StatelessWidget {
  const GameBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Assets.images.gameBackground.image(
        fit: BoxFit.cover,
      ),
    );
  }
}
