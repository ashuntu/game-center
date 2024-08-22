import 'package:flutter/widgets.dart';

const kPagePadding = 24.0;

class AppScrollView extends StatelessWidget {
  AppScrollView({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(kPagePadding),
          sliver: SliverList.list(
            children: children,
          ),
        )
      ],
    );
  }
}
