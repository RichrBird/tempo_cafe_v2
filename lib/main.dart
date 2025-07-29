import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tempo_cafe_v2/services/auth/auth_gate.dart';
import 'package:tempo_cafe_v2/utils/theme.dart'; // Add this import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vqziigaxxbgdntqcpwhn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxemlpZ2F4eGJnZG50cWNwd2huIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4MTE0MzQsImV4cCI6MjA2ODM4NzQzNH0.T1pf5Gh6dbtJxmPH2V1PN3JBpEDtIvCicft28d9OEqw',
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      theme: MaterialTheme(textTheme).light(),      // Sets the light theme
      darkTheme: MaterialTheme(textTheme).dark(), // Use your custom theme here
      themeMode: ThemeMode.system,
      home: const AuthStateListener(),
    );
  }
}
