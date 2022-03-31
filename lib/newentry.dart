import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiselog/classes.dart';
import 'package:noiselog/entrymanager.dart';
import 'package:noiselog/main.dart';

class NewEntryDialog extends StatefulWidget {
  const NewEntryDialog({Key? key}) : super(key: key);

  @override
  State<NewEntryDialog> createState() => _NewEntryDialogState();
}
TextEditingController sourceController = TextEditingController();

var selectedStartDateDisplay = "Zeitpunkt auswählen";
var selectedStartDate = DateTime.now();
bool customStartDate = false;

var selectedEndDateDisplay = "Zeitpunkt auswählen";
var selectedEndDate = DateTime.now();
bool customEndDate = false;

DateTime firstStartDate = DateTime(2010);
DateTime lastStartDate = DateTime.now();

DateTime firstEndDate = DateTime(2010);
DateTime lastEndDate = DateTime.now();

bool error_endDate_before_startDate = false;
bool customEndDateEnabled = true;

Map<int,bool> time = {
  15:false,
  30:false,
  45:false,
  60:false
};

Map<int,bool> timeEnabled = {
  15:true,
  30:true,
  45:true,
  60:true,
  0:true
};

Map<int,bool> timestamp = {
  0:false,
  15:false,
  30:false,
  60:false
};

bool durationUntilNow = false;

bool durationSelectionEnabled = true;

var time_fifteenminutes = false;
var time_thirtynminutes = false;
var time_fourtyfiveminutes = false;
var time_sixtyminutes = false;

class _NewEntryDialogState extends State<NewEntryDialog> {
  void resetCustomStartDateChip(){
    setState(() {
      selectedStartDateDisplay = "Zeitpunkt auswählen";
      selectedStartDate = DateTime.now();
      customStartDate = false;
    });
  }

  void resetCustomEndDateChip(){
    setState(() {
      error_endDate_before_startDate = false;
      selectedEndDateDisplay = "Zeitpunkt auswählen";
      selectedEndDate = DateTime.now();
      customEndDate = false;

    });
  }

  void updateStartChoiceChips(DateTime endDate){
  }

  void updateEndChoiceChips(DateTime startDate){
    setState(() {
      timeEnabled.updateAll((key, value){
        if(DateTime.now().difference(startDate).inMinutes <= key){
          return false;
        }else{
          return true;
        }
      });
    });

  }

  bool checkIfDatesAreCorrect(DateTime start, DateTime end){
    if(customStartDate && !customEndDate){
      setState(() {
        error_endDate_before_startDate = false;
      });
      return true;
    }else if(!customStartDate && customEndDate){
      if(timestamp.values.contains(true)) {
        if (selectedEndDate.isAfter(DateTime.now().subtract(Duration(minutes: timestamp.keys.elementAt(timestamp.values.toList().indexWhere((element) => true))))) || selectedEndDate == DateTime.now()) {
          setState(() {
            error_endDate_before_startDate = false;
          });
          return true;
        }else{
          return false;
        }
      }else{
        return true;
      }
      }else if (customStartDate && customEndDate) {
        if(selectedStartDate.isBefore(selectedEndDate)){
          setState(() {
            error_endDate_before_startDate = false;
          });
          return true;
        }else{
          setState(() {
            error_endDate_before_startDate = true;
          });
          return false;
        }
      }else if (!customStartDate && !customEndDate){
        setState(() {
          error_endDate_before_startDate = false;
        });
        return true;
      }
    return false;
  }

  Future<DateTime> _selectStartDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: selectedStartDate,
      firstDate: firstStartDate,
      lastDate: lastStartDate,
    );
    final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: selectedStartDate.hour, minute: selectedStartDate.minute));
    if(selected != null && selectedTime != null){
      DateTime finalDateTime = DateTime(selected.year, selected.month, selected.day, selectedTime.hour, selectedTime.minute);

      String finalMinute = "";
      if(finalDateTime.minute < 10){
        finalMinute = "0" + finalDateTime.minute.toString();
      }else{
        finalMinute = finalDateTime.minute.toString();
      }
      if(finalDateTime.difference(DateTime.now()).inDays == 0 && finalDateTime.day == DateTime.now().day){
        setState(() {
          selectedStartDateDisplay = "Heute, " + finalDateTime.hour.toString() + ":" + finalMinute + " Uhr";
          customStartDate = true;
          timestamp.updateAll((key, value) => false);
        });
      }else if (DateTime.now().subtract(const Duration(days: 1)).day == finalDateTime.day){
        setState(() {
          selectedStartDateDisplay = "Gestern, " + finalDateTime.hour.toString() + ":" + finalMinute + " Uhr";
          customStartDate = true;
          timestamp.updateAll((key, value) => false);
        });
      }else if(DateTime.now().subtract(const Duration(days: 2)).day == finalDateTime.day) {
        setState(() {
          selectedStartDateDisplay = "Vorgestern, " + finalDateTime.hour.toString() + ":" + finalMinute + " Uhr";
          customStartDate = true;
          timestamp.updateAll((key, value) => false);
        });
      }else{
        setState(() {
          selectedStartDateDisplay = finalDateTime.day.toString() + "." + finalDateTime.month.toString() + "." + finalDateTime.year.toString() + ", " + finalDateTime.hour.toString() + ":" + finalMinute + " Uhr";
          customStartDate = true;
          timestamp.updateAll((key, value) => false);
        });
      }
      setState(() {
        firstEndDate = finalDateTime.add(const Duration(minutes: 1));
      });
      selectedStartDate = finalDateTime;
      updateEndChoiceChips(finalDateTime);
      if(selectedStartDate.isAfter(selectedEndDate)){
        resetCustomEndDateChip();
      }
      return finalDateTime;
    }
    return DateTime.now();
  }

  Future<DateTime> _selectEndDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: selectedEndDate,
      firstDate: firstEndDate,
      lastDate: lastEndDate,
    );
    final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: selectedEndDate.hour, minute: selectedEndDate.minute));
    if(selected != null && selectedTime != null){
      DateTime finalDateTime = DateTime(selected.year, selected.month, selected.day, selectedTime.hour, selectedTime.minute);
      String finalMinute = "";
      if(finalDateTime.minute < 10){
        finalMinute = "0" + finalDateTime.minute.toString();
      }else{
        finalMinute = finalDateTime.minute.toString();
      }

      setState(() {
        customEndDate = true;
        time.updateAll((key, value) => false);
        durationUntilNow = false;
      if(finalDateTime.difference(DateTime.now()).inDays == 0 && finalDateTime.day == DateTime.now().day){
          selectedEndDateDisplay = "Heute, " + finalDateTime.hour.toString() + ":" + finalMinute + " Uhr";
      }else if (DateTime.now().subtract(const Duration(days: 1)).day == finalDateTime.day){
          selectedEndDateDisplay = "Gestern, " + finalDateTime.hour.toString() + ":" + finalMinute + " Uhr";
      }else if(DateTime.now().subtract(const Duration(days: 2)).day == finalDateTime.day) {
          selectedEndDateDisplay = "Vorgestern, " + finalDateTime.hour.toString() + ":" + finalMinute + " Uhr";
      }else{
          selectedEndDateDisplay = finalDateTime.day.toString() + "." + finalDateTime.month.toString() + "." + finalDateTime.year.toString() + ", " + finalDateTime.hour.toString() + ":" + finalMinute + " Uhr";
      }
      });
      selectedEndDate = finalDateTime;
      return finalDateTime;
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(onPressed: ()async{

                    if(checkIfDatesAreCorrect(selectedStartDate, selectedEndDate)) {
                      await submitEntry().then((value) {
                        Navigator.of(context).pop();
                      });
                    }
              }, icon: Icon(Icons.check, color: Theme.of(context).colorScheme.primary,))
            ],
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: IconButton(onPressed: (){
              Navigator.of(context).pop();
            }, icon: const Icon(Icons.close)),
            title: Text("Neuer Eintrag", style: Theme.of(context).appBarTheme.titleTextStyle,),
          ),
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.background,
              child: Column(
                children: [
                  const SizedBox(height: 32,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const Text("Störungsart")),
                      const SizedBox(height: 16,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(width: 1, color: Colors.white24)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                borderRadius: BorderRadius.circular(16),
                                dropdownColor: Colors.grey[900],
                                hint: Text("wähle", style: GoogleFonts.getFont("Space Mono"),),
                                value: selected == "" ? null : selected,
                                items: <String>['Lautes Gerümpel', 'Lautes Singen', 'Lautes Singen2', 'Lautes Singen3', 'Lautes Singen4'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: GoogleFonts.getFont("Space Mono", fontWeight: selected == value ? FontWeight.w700 : FontWeight.w600, color: selected == value ? Theme.of(context).colorScheme.primary : null),),
                                    );
                                    }).toList(),
                                    onChanged: (newvalue) {
                                      setState(() {
                                        selected = newvalue!;
                                      });
                                    },
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: const Text("Beginn")),
                      const SizedBox(height: 8,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(label: Text("Jetzt", style: TextStyle(fontWeight: timestamp[0] == true ? FontWeight.w900 : FontWeight.normal),), selected: timestamp[0]!, onSelected: (newvalue) {
                              setState(() {
                                if(timestamp[0]! == false){
                                  timeEnabled.updateAll((key, value) => false);
                                  durationUntilNow = false;
                                  time.updateAll((key, value) => false);
                                  timestamp.updateAll((key, value) => false);
                                  timestamp[0] = newvalue;
                                  customEndDateEnabled = false;
                                }
                              });
                              resetCustomEndDateChip();
                              resetCustomStartDateChip();
                            }),
                            ChoiceChip(label: Text("vor 15 Min.", style: TextStyle(fontWeight: timestamp[15] == true ? FontWeight.w900 : FontWeight.normal),), selected: timestamp[15]!, onSelected: (newvalue) {
                              setState(() {
                                if(timestamp[15]! == false){
                                  timeEnabled.update(15, (value) => true);
                                  timeEnabled.update(30, (value) => false);
                                  timeEnabled.update(45, (value) => false);
                                  timeEnabled.update(60, (value) => false);
                                  timeEnabled.update(0, (value) => true);
                                  customEndDateEnabled = true;
                                  time.update(30, (value) => false);
                                  time.update(45, (value) => false);
                                  time.update(60, (value) => false);
                                  durationSelectionEnabled = true;
                                  timestamp.updateAll((key, value) => false);
                                  timestamp[15] = newvalue;
                                }
                              });
                              resetCustomStartDateChip();
                            }),
                            ChoiceChip(label: Text("vor 30 Min.", style: TextStyle(fontWeight: timestamp[30] == true ? FontWeight.w900 : FontWeight.normal),), selected: timestamp[30]!, onSelected: (newvalue) {
                              setState(() {
                                if(timestamp[30]! == false){
                                  timeEnabled.update(15, (value) => true);
                                  timeEnabled.update(30, (value) => true);
                                  timeEnabled.update(45, (value) => false);
                                  timeEnabled.update(60, (value) => false);
                                  timeEnabled.update(0, (value) => true);
                                  customEndDateEnabled = true;
                                  time.update(45, (value) => false);
                                  time.update(60, (value) => false);

                                  durationSelectionEnabled = true;
                                  timestamp.updateAll((key, value) => false);
                                  timestamp[30] = newvalue;
                                }
                              });
                              resetCustomStartDateChip();
                            }),
                            ChoiceChip(label: Text("vor 60 Min.", style: TextStyle(fontWeight: timestamp[60] == true ? FontWeight.w900 : FontWeight.normal),), selected: timestamp[60]!, onSelected: (newvalue) {
                              setState(() {
                                if(timestamp[60]! == false){
                                  timeEnabled.update(15, (value) => true);
                                  timeEnabled.update(30, (value) => true);
                                  timeEnabled.update(45, (value) => true);
                                  timeEnabled.update(60, (value) => true);
                                  timeEnabled.update(0, (value) => true);

                                  customEndDateEnabled = true;
                                  durationSelectionEnabled = true;
                                  timestamp.updateAll((key, value) => false);
                                  timestamp[60] = newvalue;
                                }
                              });
                              resetCustomStartDateChip();
                            }),
                            ChoiceChip(
                                label: customStartDate ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(selectedStartDateDisplay, style: TextStyle(fontWeight: customStartDate == true ? FontWeight.w900 : FontWeight.normal,),),
                                    const SizedBox(width: 4,),
                                    const Icon(Icons.edit, size: 18, color: Colors.black,)
                                  ],
                                ) : Text(selectedStartDateDisplay, style: TextStyle(fontWeight: customStartDate == true ? FontWeight.w900 : FontWeight.normal),), selected: customStartDate, onSelected: (newvalue) {
                              _selectStartDate(context);
                              setState(() {
                                customEndDateEnabled = true;
                              });
                            }),
                          ],
                        ),
                      )
                    ],),
                  const SizedBox(height: 32,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dauer / Ende"),
                            const SizedBox(width: 8,),
                            if(timestamp[0]!) IconButton(
                              visualDensity: VisualDensity.adaptivePlatformDensity,
                              splashColor: Colors.white10,
                              enableFeedback: true,
                              color: Theme.of(context).colorScheme.primary,
                              constraints: BoxConstraints.loose(const Size(64.0,64.0)),
                              padding: const EdgeInsets.all(4),
                              iconSize: 16,
                              onPressed: (){
                              showDialog(context: context, builder: (BuildContext context){
                                return AlertDialog(
                                  contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                                  actionsPadding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: Text("Dauer / Ende", style: GoogleFonts.getFont("Space Mono", fontWeight: FontWeight.w800),),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Du kannst aktuell für die Dauer keinen Wert festlegen, da du ausgewählt hast, dass die Störung 'Jetzt' begonnen hat.", style: GoogleFonts.getFont("Space Mono", fontSize: 14), textAlign: TextAlign.justify,),
                                      const SizedBox(height: 16,),
                                      Text("Du kannst den Eintrag aber später noch bearbeiten, wenn die Störung vorüber ist!", style: GoogleFonts.getFont("Space Mono", fontWeight: FontWeight.w700), textAlign: TextAlign.justify,)
                                    ],
                                  ),
                                  actions: [TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Verstanden", style: GoogleFonts.getFont("Space Mono", fontWeight: FontWeight.w900, fontSize: 14),))],
                                );
                              });
                            }, icon: const Icon(Icons.info_outline_rounded,),),
                            if(!checkIfDatesAreCorrect(selectedStartDate, selectedEndDate)) IconButton(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                splashColor: Colors.white10,
                                enableFeedback: true,
                                color: Theme.of(context).colorScheme.primary,
                                constraints: BoxConstraints.loose(const Size(64.0,64.0)),
                                padding: const EdgeInsets.all(4),
                                iconSize: 16,
                                onPressed: (){
                                  showDialog(context: context, builder: (BuildContext context){
                                    return AlertDialog(
                                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                                      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: Text("Dauer / Ende", style: GoogleFonts.getFont("Space Mono", fontWeight: FontWeight.w800),),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Den Eintrag kannst du so aktuell nicht speichern, da das eingeträgene Ende der Störung vor dem Anfang liegt.", style: GoogleFonts.getFont("Space Mono", fontSize: 14,), textAlign: TextAlign.justify,),
                                          const SizedBox(height: 16,),
                                          Text("Passe den Eintrag an, um ihn speichern zu können. Falls die Störung noch andauert, kannst du den Wert 'Dauer / Ende' auf 'noch Aktiv' setzen und später ändern.", style: GoogleFonts.getFont("Space Mono", fontWeight: FontWeight.w700), textAlign: TextAlign.justify,)
                                        ],
                                      ),
                                      actions: [TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Verstanden", style: GoogleFonts.getFont("Space Mono", fontWeight: FontWeight.w900, fontSize: 14),))],
                                    );
                                  });
                                }, icon: Icon(Icons.info_outline_rounded, color: Colors.red[400],))
                          ],
                        )),
                        const SizedBox(height: 8,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Wrap(
                            spacing: 8,
                            children: [
                            ChoiceChip(
                                label: Text("15 Min.", style: TextStyle(fontWeight: time[15] == true ? FontWeight.w900 : FontWeight.normal),),
                                selected: time[15]!,
                                disabledColor: Colors.white.withOpacity(0.20),
                                onSelected: !timeEnabled[15]! ? null : (newvalue) {
                          setState(() {
                            if(time[15]! == false){
                              time.updateAll((key, value) => false);
                              durationUntilNow = false;
                              time[15] = newvalue;
                            }
                          });
                          resetCustomEndDateChip();
                            }),
                            ChoiceChip(
                                label: Text("30 Min.", style: TextStyle(fontWeight: time[30] == true ? FontWeight.w900 : FontWeight.normal),),
                                selected: time[30]!,
                                disabledColor: Colors.white.withOpacity(0.20),
                                onSelected: !timeEnabled[30]! ? null : (newvalue) {
                          setState(() {
                            if(time[30]! == false){
                              time.updateAll((key, value) => false);
                              durationUntilNow = false;
                              time[30] = newvalue;
                            }
                          });
                          resetCustomEndDateChip();
                            }),
                            ChoiceChip(
                                label: Text("45 Min.", style: TextStyle(fontWeight: time[45] == true ? FontWeight.w900 : FontWeight.normal),),
                                selected: time[45]!,
                                disabledColor: Colors.white.withOpacity(0.20),
                                onSelected: !timeEnabled[45]! ? null : (newvalue) {
                          setState(() {
                            if(time[45]! == false){
                              time.updateAll((key, value) => false);
                              durationUntilNow = false;
                              time[45] = newvalue;
                            }
                          });
                          resetCustomEndDateChip();
                            }),
                            ChoiceChip(
                                label: Text("60 Min.", style: TextStyle(fontWeight: time[60] == true ? FontWeight.w900 : FontWeight.normal),),
                                selected: time[60]!,
                                disabledColor: Colors.white.withOpacity(0.20),
                                onSelected: !timeEnabled[60]! ? null : (newvalue) {
                          setState(() {
                            if(time[60]! == false){
                              time.updateAll((key, value) => false);
                              durationUntilNow = false;
                              time[60] = newvalue;
                            }
                          });
                          resetCustomEndDateChip();
                            }),
                              ChoiceChip(
                                  label: Text("bis jetzt", style: TextStyle(fontWeight: durationUntilNow ? FontWeight.w900 : FontWeight.normal),),
                                  selected: durationUntilNow,
                                  disabledColor: Colors.white.withOpacity(0.20),
                                  onSelected: timestamp[0]! == false ? (newvalue) {
                                    setState(() {
                                        time.updateAll((key, value) => false);
                                        durationUntilNow = true;
                                    });
                                    resetCustomEndDateChip();
                                  } : null),
                              ChoiceChip(
                                  disabledColor: Colors.white.withOpacity(0.20),
                                  selectedColor: checkIfDatesAreCorrect(selectedStartDate, selectedEndDate) ? null : Colors.white.withOpacity(0.05),
                                  label: customEndDate ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(selectedEndDateDisplay, style: TextStyle(fontWeight: customEndDate == true ? checkIfDatesAreCorrect(selectedStartDate, selectedEndDate) ? FontWeight.w900 : FontWeight.normal : FontWeight.normal, color: checkIfDatesAreCorrect(selectedStartDate, selectedEndDate) ? null : Colors.redAccent, decoration: checkIfDatesAreCorrect(selectedStartDate, selectedEndDate) ? null : TextDecoration.lineThrough),),
                                      const SizedBox(width: 4,),
                                      Icon(Icons.edit, size: 18, color: checkIfDatesAreCorrect(selectedStartDate, selectedEndDate) ? Colors.black : Colors.redAccent,)
                                    ],
                                  ) : Text(selectedEndDateDisplay, style: TextStyle(fontWeight: customEndDate == true ? FontWeight.w900 : FontWeight.normal),), selected: customEndDate, onSelected: customEndDateEnabled ? (newvalue) {
                                _selectEndDate(context);
                              } : null),
                            ],
                          ),
                        )
                  ],),
                  const SizedBox(height: 32,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const Text("Quelle der Störung")),
                      const SizedBox(height: 16,),
                      TextField(
                        controller: sourceController,
                        style: GoogleFonts.getFont("Space Mono", fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                        decoration: InputDecoration(
                          fillColor: Colors.grey[900],
                          filled: true,
                          contentPadding: const EdgeInsets.all(12),
                          isDense: true,
                          hintText: "Nachbar, Party etc.",
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary), borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 1, color: Colors.white24), borderRadius: BorderRadius.circular(16)
                          )
                        ),

                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
  }
}

Future<Entry> submitEntry() async{
  String enteredType = selected;
  String enteredSource = sourceController.text;
  late Entry newEntry;
  if(customStartDate && !customEndDate){

    if((durationUntilNow && selectedStartDate.isBefore(DateTime.now())) || (durationUntilNow && selectedStartDate == DateTime.now())){
      newEntry = Entry(type: enteredType, startDate: selectedStartDate.toString(), endDate: DateTime.now().toString(), source: enteredSource);
    }else{
      int enteredDuration = time.keys.toList().elementAt(time.values.toList().indexWhere((element) => element == true));
      newEntry = Entry(type: enteredType, startDate: selectedStartDate.toString(), endDate: selectedEndDate.add(Duration(minutes: enteredDuration)).toString(), source: enteredSource);
    }
  }else if (!customStartDate && customEndDate){
    DateTime enteredStartTime = DateTime.now().subtract(Duration(minutes: timestamp.keys.elementAt(timestamp.values.toList().indexWhere((element) => element == true))));
    newEntry = Entry(type: enteredType, startDate: enteredStartTime.toString(), endDate: selectedEndDate.toString(), source: enteredSource);

  }else if (customStartDate && customEndDate){

    newEntry = Entry(type: enteredType, startDate: selectedStartDate.toString(), endDate: selectedEndDate.toString(), source: enteredSource);

  }else if(!customStartDate && !customEndDate){
    if(!time.values.toList().contains(true) && timestamp[0] == true){
      DateTime now = DateTime.now();
      newEntry = Entry(type: enteredType, startDate: now.toString(), endDate: now.toString(), source: enteredSource);
    }else{
      DateTime enteredStartTime = DateTime.now().subtract(Duration(minutes: timestamp.keys.elementAt(timestamp.values.toList().indexWhere((element) => element == true))));
      if(durationUntilNow){
        newEntry = Entry(type: enteredType, startDate: enteredStartTime.toString(), endDate: DateTime.now().toString(), source: enteredSource);
      }else{
        int enteredDuration = time.keys.toList().elementAt(time.values.toList().indexWhere((element) => element == true));
        newEntry = Entry(type: enteredType, startDate: enteredStartTime.toString(), endDate: enteredStartTime.add(Duration(minutes: enteredDuration)).toString(), source: enteredSource);
    }
      }
  }

  List<Entry> tempEntries = await getEntries();
  tempEntries.add(newEntry);

  if(await saveEntries(tempEntries)){
    return newEntry;
  }
  return Entry(type: "", startDate: "", endDate: "", source: "");
}


