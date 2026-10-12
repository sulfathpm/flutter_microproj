import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/emergency.dart';
import 'providers/custom_scenarios_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/add_scenario_screen.dart';
import 'screens/home_screen.dart';
import 'screens/instructions_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..load()),
        ChangeNotifierProvider(create: (_) => CustomScenariosProvider()..load()),
      ],
      child: const FirstAidApp(),
    ),
  );
}

class FirstAidApp extends StatelessWidget {
  const FirstAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First-Aid Quick Guide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        AddScenarioScreen.routeName: (_) => const AddScenarioScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == InstructionsScreen.routeName) {
          final args = settings.arguments;
          if (args is EmergencyScenario) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => InstructionsScreen(scenario: args),
            );
          }
        }
        return null;
      },
    );
  }
}