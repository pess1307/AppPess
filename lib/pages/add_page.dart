import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:primera_app_curso/category_select_widget.dart';
import 'package:primera_app_curso/expenses_repository.dart';
import 'package:provider/provider.dart';

class AddPage extends StatefulWidget {
  final Rect buttonRect;

  const AddPage({Key key, this.buttonRect}) : super(key: key);
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _buttonAnimation;
  Animation _pageAnimation;

  String category;
  double value = 0;

  String dateStr = "HOY";
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 730),
    );

    _buttonAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _pageAnimation = Tween<double>(begin: -1, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        Navigator.of(context).pop();
      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, h * (1 - _pageAnimation.value)),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              title: GestureDetector(
                onTap: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(Duration(hours: 24 * 30)),
                          lastDate: DateTime.now())
                      .then((newDate) {
                    if (newDate != null) {
                      setState(() {
                        date = newDate;
                        dateStr =
                            "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                      });
                    }
                  });
                },
                child: Text(
                  "CATEGORIAS ($dateStr)",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              centerTitle: false,
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      _controller.reverse();
                    })
              ],
            ),
            body: _body(),
          ),
        ),
        _submit(),
      ],
    );
  }

  Widget _body() {
    var h = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        _categorySelector(),
        _currentValue(),
        _numpad(),
        SizedBox(
          height: h - widget.buttonRect.top,
        )
      ],
    );
  }

  Widget _categorySelector() {
    return Container(
      height: 80.0,
      child: CategorySelectionWidget(
        categories: {
          "Shopping": Icons.shopping_cart,
          "Alcohol": FontAwesomeIcons.beer,
          "Fast Food": FontAwesomeIcons.hamburger,
          "bills": FontAwesomeIcons.wallet,
          "Transport": FontAwesomeIcons.carAlt,
          "Other": FontAwesomeIcons.infinity,
        },
        onValueChange: (newCategory) => category = newCategory,
      ),
    );
  }

  Widget _currentValue() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Text(
        "\S/.${value.toStringAsFixed(2)}",
        style: TextStyle(
          fontSize: 50.0,
          color: Colors.lightGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _num(String text, double height) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          value = value * 10 + int.parse(text);
        });
      },
      child: Container(
        height: height,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 40,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _numpad() => Expanded(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var height = constraints.biggest.height / 4;
          return Table(
            border: TableBorder.all(
              color: Colors.grey,
              width: 1.0,
            ),
            children: [
              TableRow(children: [
                _num("1", height),
                _num("2", height),
                _num("3", height),
              ]),
              TableRow(children: [
                _num("4", height),
                _num("5", height),
                _num("6", height),
              ]),
              TableRow(children: [
                _num("7", height),
                _num("8", height),
                _num("9", height),
              ]),
              TableRow(children: [
                _num(",", height),
                _num("0", height),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      value = value ~/ 10 + (value - value.toInt());
                    });
                  },
                  child: Container(
                    height: height,
                    child: Center(
                      child: Icon(
                        Icons.backspace,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          );
        },
      ));

  Widget _submit() {
    if (_controller.value < 1) {
      var buttonWidth = widget.buttonRect.right - widget.buttonRect.left;
      var w = MediaQuery.of(context).size.width;
      return Positioned(
        top: widget.buttonRect.top,
        left: widget.buttonRect.left * (1 - _buttonAnimation.value),
        right: (w - widget.buttonRect.right) * (1 - _buttonAnimation.value),
        bottom:
            (MediaQuery.of(context).size.height - widget.buttonRect.bottom) *
                (1 - _buttonAnimation.value),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                buttonWidth * (1 - _buttonAnimation.value)),
            color: Colors.green,
          ),
          child: MaterialButton(
            child: Text(
              "Gastos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),
            ),
          ),
        ),
      );
    } else {
      return Positioned(
        top: widget.buttonRect.top,
        bottom: 0,
        left: 0,
        right: 0,
        child: Builder(
          builder: (BuildContext context) {
            return Container(
              //eliminar height: widget.buttonRect.top,
              // eliminar  width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: MaterialButton(
                color: Colors.green,
                child: Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () {
                  var db =
                      Provider.of<ExpensesRepository>(context, listen: false);
                  if (value > 0 && category != '') {
                    db.add(category, value, date);
                    _controller.reverse();
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text(
                                  "Falta Seleccionar Categoria o Monto. Muchas GRACIAS!"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('aceptar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ));
                  }
                },
              ),
            );
          },
        ),
      );
    }
  }
}
