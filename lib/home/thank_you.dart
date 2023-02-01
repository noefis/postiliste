import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//TODO add translations
Future<void> thankYou(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: const Color.fromARGB(83, 0, 0, 0),
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).indicatorColor,
        contentPadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        title: Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            margin: const EdgeInsets.all(0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF4776E6),
                    Color(0xFF8E54E9),
                  ],
                )),
            child: Text("Thank You for Downloading!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5?.copyWith(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w700))),
        titlePadding: const EdgeInsets.only(top: 0),
        actionsPadding: const EdgeInsets.only(right: 9, bottom: 9),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  "I'm glad that you decided to try my app. I hope you find it helpful and enjoyable. If you have any questions or feedback, don't hesitate to reach out.",
                  textAlign: TextAlign.justify,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 18)),
              const Padding(padding: EdgeInsets.all(10)),
              Text("Noel",
                  textAlign: TextAlign.justify,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 18)),
              Text("Creator of Posti-Liste",
                  textAlign: TextAlign.justify,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).disabledColor, fontSize: 11)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Close",
                style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
