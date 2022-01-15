import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:primera_app_curso/add_page_transicion.dart';
import 'package:primera_app_curso/login_state.dart';
import 'package:primera_app_curso/pages/add_page.dart';
import 'package:primera_app_curso/pages/home_page.dart';
import 'package:primera_app_curso/pages/login_page.dart';
import 'package:provider/provider.dart';

import 'pages/detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Miapp());
}

class Miapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginState>(
      create: (BuildContext context) => LoginState(),
      child: MaterialApp(
        title: 'pess_control',
        onGenerateRoute: (settings) {
          if (settings.name == '/details') {
            DetailsParams params = settings.arguments;
            return MaterialPageRoute(builder: (BuildContext context) {
              return DetailsPage(
                params: params,
              );
            });
          } else if (settings.name == '/add') {
            Rect buttonRect = settings.arguments;
            return AddPageTransition(
                page: AddPage(
              buttonRect: buttonRect,
            ));
          }
        },
        routes: {
          '/': (BuildContext context) {
            var state = Provider.of<LoginState>(context);
            if (state.isLoggedIn()) {
              return Inicio();
            } else {
              return LoginPage();
            }
          },
          // '/add': (BuildContext context) => AddPage(),
        },
      ),
    );
  }
}
