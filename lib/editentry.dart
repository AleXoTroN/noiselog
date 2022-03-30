import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noiselog/classes.dart';
import 'package:noiselog/listWidgets.dart';

class EditEntryPage extends StatefulWidget {
  const EditEntryPage({Key? key, required this.entry, required this.index}) : super(key: key);
  final Entry entry;
  final int index;

  @override
  State<EditEntryPage> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            child: const Divider(), preferredSize: Size(MediaQuery
            .of(context)
            .size
            .width, 0)),
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarColor: Colors.transparent
        ),
        title: Text("Eintrag bearbeiten", style: Theme
            .of(context)
            .appBarTheme
            .titleTextStyle,),
      ),
    );
  }
}
