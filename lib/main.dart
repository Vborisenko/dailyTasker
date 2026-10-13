import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/category_provider.dart';
import 'providers/task_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await StorageService.init();
  
  runApp(const DailyTaskerApp());
}

class DailyTaskerApp extends StatefulWidget {
  const DailyTaskerApp({super.key});

  @override
  State<DailyTaskerApp> createState() => _DailyTaskerAppState();
}

class _DailyTaskerAppState extends State<DailyTaskerApp> {
  // Removed WidgetsBindingObserver to let Hive handle data persistence automatically

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Daily Tasker',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
