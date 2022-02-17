import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:primera_app_curso/expenses_repository.dart';
import 'package:primera_app_curso/login_state.dart';
import 'package:primera_app_curso/month_widge.dart';
import 'package:primera_app_curso/utils.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:rect_getter/rect_getter.dart';

class Inicio extends StatefulWidget {
  Inicio({Key key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var globalKey = RectGetter.createGlobalKey();

  Rect buttonRect;

  PageController _controller;
  int currentPage = DateTime.now().month - 1;
  Stream<QuerySnapshot> _query;
  GraphType currentType = GraphType.LINES;

  @override
  void initState() {
    super.initState();
    /* eliminar esta parte 
    _query = FirebaseFirestore.instance
        .collection('expenses')
        .where("month", isEqualTo: currentPage + 1)
        .snapshots(); */

    _controller = PageController(
      initialPage: currentPage,
      viewportFraction: 0.4,
    );

    setupNotificationPlugin();
    tz.initializeTimeZones();
  }

  Widget _botonAction(IconData icon, Function callback) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
      onTap: callback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesRepository>(
        builder: (BuildContext context, ExpensesRepository db, Widget child) {
      // var user = Provider.of<LoginState>(context, listen: false).currentUser();
      _query = db.queryByMonth(currentPage + 1);
      return Scaffold(
        bottomNavigationBar: BottomAppBar(
          notchMargin: 8.0,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _botonAction(FontAwesomeIcons.chartLine, () {
                setState(() {
                  currentType = GraphType.LINES;
                });
              }),
              _botonAction(FontAwesomeIcons.chartPie, () {
                setState(() {
                  currentType = GraphType.PIE;
                });
              }),
              SizedBox(width: 32.0),
              _botonAction(FontAwesomeIcons.wallet, () {}),
              _botonAction(Icons.settings, () {
                Provider.of<LoginState>(context, listen: false).logout();
              }),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: RectGetter(
          key: globalKey,
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            child: Icon(Icons.add),
            onPressed: () {
              buttonRect = RectGetter.getRectFromKey(globalKey);

              Navigator.of(context).pushNamed('/add', arguments: buttonRect);
            },
          ),
        ),
        body: _body(),
      );
    });
  }

  Widget _body() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          _selector(),
          StreamBuilder<QuerySnapshot>(
            stream: _query,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data) {
              if (data.connectionState == ConnectionState.active) {
                if (data.data.docs.length > 0) {
                  return MonthWidget(
                    days: daysInMonth(currentPage + 1),
                    documents: data.data.docs,
                    graphType: currentType,
                    month: currentPage,
                  );
                } else {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/no_data.png'),
                        SizedBox(height: 80),
                        Text(
                          "No hay ningun Registro, Tocar Simbolo '+' ",
                          style: Theme.of(context).textTheme.overline,
                        )
                      ],
                    ),
                  );
                }
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _pageItem(String nombre, int position) {
    var _alignment;
    final selected = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey,
    );
    final unselected = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.normal,
      color: Colors.blueGrey.withOpacity(0.4),
    );
    if (position == currentPage) {
      _alignment = Alignment.center;
    } else if (position > currentPage) {
      _alignment = Alignment.centerRight;
    } else {
      _alignment = Alignment.centerLeft;
    }

    return Align(
        alignment: _alignment,
        child: Text(
          nombre,
          style: position == currentPage ? selected : unselected,
        ));
  }

  Widget _selector() {
    return SizedBox.fromSize(
      size: Size.fromHeight(70.0),
      child: PageView(
        onPageChanged: (newPage) {
          setState(() {
            var db = Provider.of<ExpensesRepository>(context, listen: false);
            currentPage = newPage;
            _query = db.queryByMonth(currentPage + 1);
          });
        },
        controller: _controller,
        children: <Widget>[
          _pageItem("ENERO", 0),
          _pageItem("FEBRERO", 1),
          _pageItem("MARZO", 2),
          _pageItem("ABRIL", 3),
          _pageItem("MAYO", 4),
          _pageItem("JUNIO", 5),
          _pageItem("JULIO", 6),
          _pageItem("AGOSTO", 7),
          _pageItem("SEPTIEMBRE", 8),
          _pageItem("OCTUBRE", 9),
          _pageItem("NOVIEMBRE", 10),
          _pageItem("DICIEMBRE", 11),
        ],
      ),
    );
  }

  void setupNotificationPlugin() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');

    var iOS = new IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    var initializationSettings =
        new InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin
        .initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    )
        .then((init) {
      setupNotification();
    });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => Inicio()),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text("Don't forget to add your expenses"),
              actions: <Widget>[
                TextButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  } //FlatButton remplaso por textbton

  void setupNotification() async {
    // repetir cada minito
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'repeating channel id', 'repeating channel name',
            channelDescription: 'repeating description');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'Gasto Algo?',
        'Si es ASI, REGISTRALO PORFAVOR ',
        RepeatInterval.hourly,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }
}
