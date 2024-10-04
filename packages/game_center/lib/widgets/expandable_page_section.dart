import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class ExpandablePageSection extends StatelessWidget {
  ExpandablePageSection({
    required this.title,
    required this.children,
    this.expanded = false,
  });

  final String title;
  final List<Widget> children;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return YaruExpandable(
      expandButtonPosition: YaruExpandableButtonPosition.start,
      isExpanded: expanded,
      gapHeight: 24,
      // Text is surrounded with a Flex to allow toggling anywhere in the row
      header: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
