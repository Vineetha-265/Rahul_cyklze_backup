// // main.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cyklze/provider/pickup_provider.dart';
// import 'package:cyklze/screens/home_page.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   runApp(const CyklzeApp());
// }

// class CyklzeApp extends StatelessWidget {
//   const CyklzeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => PickupProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Cyklze',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home: const HomePage(),
//       ),
//     );
//   }
// }


import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:flutter/material.dart';
import 'package:cyklze/screens/home_page.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PickupProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
 scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'cyklze',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D4D61)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
