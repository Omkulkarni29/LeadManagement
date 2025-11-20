import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/lead_list_screen.dart';
import 'providers/leads_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LeadsNotifier(),
      child: Consumer<LeadsNotifier>(
        builder: (context, leadsNotifier, _) {
          return MaterialApp(
            title: 'Lead Manager',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.grey.shade900,
            ),
            themeMode:
                leadsNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const LeadListScreen(),
          );
        },
      ),
    );
  }
}
