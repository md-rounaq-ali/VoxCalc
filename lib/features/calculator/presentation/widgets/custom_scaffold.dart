import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/calc_provider.dart';

/// Elite visual wrapper providing glassmorphic background gradients dynamically.
class CustomScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  const CustomScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalcProvider>(
      builder: (context, provider, _) {
        final themeName = provider.activeTheme;
        final gradients = AppTheme.getBgGradient(themeName);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradients,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: body,
                ),
              ),
            ),
            drawer: drawer,
            bottomNavigationBar: bottomNavigationBar,
          ),
        );
      },
    );
  }
}
