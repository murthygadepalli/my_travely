import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/repository/hotel_repository.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/hotels/bloc/hotel_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => HotelBloc(HotelRepository())),
      ],
      child: MaterialApp(
        title: 'MyTravaly',
        debugShowCheckedModeBanner: false,
        routes: Routes.getAll(),
        initialRoute: Routes.splash, // ✅ splash starts first
      ),
    );
  }
}
