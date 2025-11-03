import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/footer_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Profile Page Content',
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
