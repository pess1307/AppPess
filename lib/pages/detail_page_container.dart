import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:primera_app_curso/expenses_repository.dart';
import 'package:primera_app_curso/login_state.dart';
import 'package:primera_app_curso/pages/detail_page.dart';
import 'package:primera_app_curso/pages/ui/day_expense_list_tile.dart';
import 'package:provider/provider.dart';

class DetailsParams {
  final String categoryName;
  final int month;

  DetailsParams(this.categoryName, this.month);
}

class DetailsPageContainer extends StatefulWidget {
  final DetailsParams params;

  const DetailsPageContainer({Key key, this.params}) : super(key: key);

  @override
  _DetailsPageContainerState createState() => _DetailsPageContainerState();
}

class _DetailsPageContainerState extends State<DetailsPageContainer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesRepository>(
      builder: (BuildContext context, ExpensesRepository db, Widget child) {
        var user = Provider.of<LoginState>(context).currentUser();
        var db = ExpensesRepository(user.uid);
        var _query = db.queryByCategory(
            widget.params.month + 1, widget.params.categoryName);
        return StreamBuilder<QuerySnapshot>(
            stream: _query,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data) {
              if (data.hasData) {
                return DetailsPage(
                  categoryName: widget.params.categoryName,
                  documents: data.data.docs,
                  onDelete: (documentid) {
                    db.delete(documentid);
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            });
      },
    );
  }
}
