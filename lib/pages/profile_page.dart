import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../providers/stats_provider.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/footer_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final stats = Provider.of<StatsProvider>(context); // <-- GET TOTALS

    return Scaffold(
      appBar: const CustomAppBar(title: "Profile"),
      body: FutureBuilder<AppUser?>(
        future: auth.getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : const AssetImage("assets/images/profile.png")
                          as ImageProvider,
                ),
                const SizedBox(height: 12),

                Text(
                  user.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // 🔥 INCOME + SPENDING BOX
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Income",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "\$${stats.totalIncome.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Spending",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "\$${stats.totalSpending.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                _buildSectionTitle("Settings"),
                _buildSettingItem(Icons.person, "Edit Profile"),
                _buildSettingItem(Icons.notifications, "Notifications"),
                _buildSettingItem(Icons.lock, "Privacy & Security"),
                _buildSettingItem(Icons.wallet, "Connected Accounts"),
                _buildSettingItem(Icons.cloud_upload, "Backup & Restore"),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                const Footer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.teal),
          title: Text(label),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        Divider(color: Colors.teal.shade100),
      ],
    );
  }
}