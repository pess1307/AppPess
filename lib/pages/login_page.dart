import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:primera_app_curso/login_state.dart';
import 'package:provider/provider.dart';

import '../login_state.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TapGestureRecognizer _recognizer1;
  TapGestureRecognizer _recognizer2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Text(
              "Control De Gastos",
              style: Theme.of(context).textTheme.headline4,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Image.asset('assets/login_background.png'),
            ),
            Text(
              "Tu asesor de finanzas personal",
              style: Theme.of(context).textTheme.overline,
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Consumer<LoginState>(
              builder: (BuildContext context, LoginState value, Widget child) {
                if (value.isLoading()) {
                  return CircularProgressIndicator();
                } else {
                  return child;
                }
              },
              child: ElevatedButton(
                child: Text("Iniciar Sesion con Google"),
                onPressed: () {
                  Provider.of<LoginState>(context, listen: false).login();
                },
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    text: "Para utilizar esta aplicación, debe aceptar nuestra",
                    children: [
                      TextSpan(
                        text: "Terms of Service",
                        recognizer: _recognizer1,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " y "),
                      TextSpan(
                        text: "Privacy Policy",
                        recognizer: _recognizer2,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _recognizer1 = TapGestureRecognizer()
      ..onTap = () {
        showHelp(
            "Este servicio se proporciona TAL CUAL y no tiene garantía actual sobre cómo"
            " se gestionan los datos y el tiempo de actividad. Los términos finales se publicarán cuando la versión final de la aplicación"
            " será realizado.");
      };
    _recognizer2 = TapGestureRecognizer()
      ..onTap = () {
        showHelp(
            "Todos sus datos se guardan de forma anónima en la base de datos de Firebase y permanecerán así."
            " Ningún otro usuario tendrá acceso a él.");
      };
  }

  @override
  void dispose() {
    super.dispose();
    _recognizer1.dispose();
    _recognizer2.dispose();
  }

  void showHelp(String s) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(s),
              actions: <Widget>[
                TextButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }
}

/* eliminar una vez que este lito ya 
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<LoginState>(
          builder: (BuildContext context, LoginState value, Widget child) {
            if (value.isLoading()) {
              return CircularProgressIndicator();
            } else {
              return child;
            }
          },
          child: RaisedButton(
            child: Text("Sing In"),
            onPressed: () {
              Provider.of<LoginState>(context, listen: false).login();
            },
          ),
        ),
      ),
    );
  }
}*/
