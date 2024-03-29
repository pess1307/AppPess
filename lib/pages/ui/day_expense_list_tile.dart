import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DayExpenseListTile extends StatelessWidget {
  const DayExpenseListTile({
    Key key,
    @required this.document,
  }) : super(key: key);

  final DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: <Widget>[
          Icon(
            Icons.calendar_today,
            size: 40,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Text(
              document["day"].toString(),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
      title: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "\S/.${document["value"]}" + " \ - ${document["Description"]}",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}
