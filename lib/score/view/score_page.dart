import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:panic_of_plastic/score/bloc/score_bloc.dart';
import 'package:panic_of_plastic/score/routes/routes.dart';

class ScorePage extends StatelessWidget {
  const ScorePage({
    required this.score,
    super.key,
  });

  static PageRoute<void> route({required int score}) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => ScorePage(score: score),
    );
  }

  final int score;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScoreBloc(
        score: score,
      ),
      child: const ScoreView(),
    );
  }
}

class ScoreView extends StatelessWidget {
  const ScoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<ScoreState>(
      state: context.select((ScoreBloc bloc) => bloc.state),
      onGeneratePages: onGenerateScorePages,
    );
  }
}
