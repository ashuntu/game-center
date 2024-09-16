import 'package:flutter/widgets.dart';

const kPagePadding = 24.0;

class AppScrollView extends StatelessWidget {
  AppScrollView({required this.slivers});

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: slivers
          .map(
            (s) => SliverPadding(
              padding: EdgeInsets.all(kPagePadding),
              sliver: s,
            ),
          )
          .toList(),
    );
  }
}
