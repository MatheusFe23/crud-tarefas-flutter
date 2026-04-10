import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/item_controller.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    // ChangeNotifierProvider disponibiliza ItemController para toda a árvore
    ChangeNotifierProvider(
      create: (_) => ItemController(),
      child: const MyApp(),
    ),
  );
}

/// Widget raiz da aplicação.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6FA5), // Azul acinzentado
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // A aplicação sempre começa pela tela de login
      home: const LoginScreen(),
    );
  }
}
