import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 700;
        final horizontalPadding = isDesktop ? 24.0 : 16.0;
        final contentWidth = constraints.maxWidth > 1200 ? 1200.0 : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: contentWidth,
            height: constraints.maxHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isDesktop ? 24 : 16,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: ResponsivePage(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
