import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/footer_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Settings Page Content',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
