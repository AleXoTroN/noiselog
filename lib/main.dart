import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiselog/classes.dart';
import 'package:noiselog/editentry.dart';
import 'package:noiselog/entrymanager.dart';
import 'package:noiselog/listWidgets.dart';
import 'package:noiselog/newentry.dart';
import 'package:animations/animations.dart';

void main() {
  runApp(const MyApp());
}

String selected = "";

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lärmprotokoll',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: GoogleFonts.getFont("Space Mono", color: Colors.white24),
        ),
        
        chipTheme: ChipThemeData(
          elevation: 0,
          pressElevation: 0,
          shape: RoundedRectangleBorder(side: const BorderSide(width: 0, color: Colors.white10), borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white10,
          selectedColor: Theme.of(context).colorScheme.background,
          labelStyle: GoogleFonts.getFont("Space Mono", color: Colors.white),
          secondaryLabelStyle: GoogleFonts.getFont("Space Mono", color: Colors.black87, fontWeight: FontWeight.w800),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          )
        ),
        textTheme: TextTheme(
          bodyMedium: GoogleFonts.getFont("Space Mono"),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.getFont("Space Mono", fontSize: 22, fontWeight: FontWeight.w600),
        ),
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MyHomePage(title: 'Ruhestörungen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void removeItem(List<Entry> list, int index) async {
    setState(() {
      deleteEntry(list, index);
    });
  }

  void editItem(Entry entry, int index) {

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditEntryPage(entry: entry, index: index,)),
      );
    }

    void commitDateToItem(List<Entry> list, int index) async {
      setState(() {
        commitEndDate(list, index);
      });
    }

    void reload() {
      setState(() {});
    }


    @override
    Widget build(BuildContext context) {
      Widget fab = OpenContainer(

        transitionType: ContainerTransitionType.fadeThrough,
        openColor: Colors.black,
        middleColor: HSLColor.fromColor(Theme
            .of(context)
            .colorScheme
            .primary).withLightness(0.3).withSaturation(0.2).toColor(),
        closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        closedColor: Theme
            .of(context)
            .colorScheme
            .primary,
        onClosed: (value) {
          reload.call();
        },
        closedBuilder: (context, action) =>
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(
            Icons.add_rounded, size: 32, color: Colors.black,),
        ),
        openBuilder: (context, action) => const NewEntryDialog(),
      );

      return Scaffold(
        floatingActionButton: fab,
        floatingActionButtonAnimator: NoScalingAnimation(),
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
          title: Text(widget.title, style: Theme
              .of(context)
              .appBarTheme
              .titleTextStyle,),
        ),
        body: FutureBuilder(
            future: getEntries(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Entry>> snapshot) {
              List<Entry>? items = snapshot.data;

              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 24),
                      Text("Lädt Einträge ...")
                    ],
                  ),
                );
              }
              if (items?.isEmpty == true || items == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Icon(Icons.do_disturb_alt_rounded),
                      SizedBox(height: 16,),
                      Text(
                        'Keine Einträge vorhanden',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null && snapshot.data!.isNotEmpty) {
                List<Entry> list = snapshot.data!;

                return ListView.builder(
                    key: GlobalKey(),
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return EntryWidget(entry: list.elementAt(index),
                        index: index,
                        onDelete: () {
                          removeItem(list, index);
                        },
                        onCommit: () async {
                          commitDateToItem(list, index);
                        },
                      onEdit: (){
                        editItem(list.elementAt(index), index);
                      },);
                    });
              }
              return Container();
            }

        ),
      );
    }
  }

  class NoScalingAnimation extends FloatingActionButtonAnimator {
  @override
  Offset getOffset({required Offset begin, required Offset end, required double progress}) {
  return end;
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
  return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
  return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }
  }


