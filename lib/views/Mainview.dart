// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';
import '../widgets/deck_picker.dart';
import '../widgets/hand_section.dart';
import '../widgets/main_header.dart';
import '../widgets/table_section.dart';

// Provider dla MainViewModel (Riverpod)
final mainViewModelProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(mainViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            MainHeader(vm: vm),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Your hand + win probability (single section)
                    HandSection(vm: vm, isSmallScreen: isSmallScreen),

                    const SizedBox(height: 20),

                    // Table cards section
                    TableSection(vm: vm, isSmallScreen: isSmallScreen),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Card deck picker
            DeckPicker(vm: vm, isSmallScreen: isSmallScreen),
          ],
        ),
      ),
    );
  }
}
