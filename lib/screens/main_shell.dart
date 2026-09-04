import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/nav_bar.dart';
import 'capture_screen.dart';
import 'records_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentIndex = appState.currentTabIndex;

    final screens = const [
      CaptureScreen(),
      RecordsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex.clamp(0, screens.length - 1),
        children: screens,
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: currentIndex.clamp(0, screens.length - 1),
        onTap: (navIndex) => appState.setTab(navIndex),
      ),
    );
  }
}
