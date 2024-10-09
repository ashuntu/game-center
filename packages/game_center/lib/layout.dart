import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const kPagePadding = 24.0;

extension TextStyleToMono on TextStyle {
  /// Create a `TextStyle` of the same type, but with its `fontFamily` replaced
  /// with UbuntuMono.
  ///
  /// This function exists because using `copyWith` with the `TextStyle` results
  /// in inheriting the `package` field of the parent style, which breaks any
  /// custom local fonts. As of writing, there is no way to "unset" a field of a
  /// `TextStyle` object, so a new one must be manually created.
  TextStyle toMono() {
    return TextStyle(
      color: color,
      decoration: decoration,
      decorationStyle: decorationStyle,
      background: background,
      backgroundColor: backgroundColor,
      debugLabel: debugLabel,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
      fontFamily: 'UbuntuMono',
      fontFamilyFallback: fontFamilyFallback,
      fontFeatures: fontFeatures,
      fontSize: fontSize,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      fontVariations: fontVariations,
      foreground: foreground,
      height: height,
      leadingDistribution: leadingDistribution,
      letterSpacing: letterSpacing,
      locale: locale,
      overflow: overflow,
      // `package` is purposely not set here
      shadows: shadows,
      textBaseline: textBaseline,
      wordSpacing: wordSpacing,
      inherit: false, // this must be set to prevent inheriting `package`
    );
  }
}

class AppScrollView extends StatelessWidget {
  const AppScrollView({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(kPagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
