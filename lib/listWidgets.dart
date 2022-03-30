import 'dart:math';

import 'package:flutter/material.dart';
import 'package:noiselog/classes.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:animations/animations.dart';
import 'package:noiselog/editentry.dart';

late Entry entryData;

class EntryWidget extends StatefulWidget {
  const EntryWidget({Key? key, required this.entry, required this.index, required this.onDelete, required this.onCommit, required this.onEdit}) : super(key: key);
  final VoidCallback onDelete;
  final VoidCallback onCommit;
  final VoidCallback onEdit;
  final Entry entry;
  final int index;

  @override
  State<EntryWidget> createState() => _EntryWidgetState();
}

class _EntryWidgetState extends State<EntryWidget>{

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

  }

  String getTimeStringFromDouble(double value) {
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);

    return '$hourValue:$minuteString';
  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {

    Entry entry = widget.entry;
    DateTime date = DateTime.parse(entry.startDate);
    String dateString = "";
    String timeString = "";
    DateTime dateOfEnd = DateTime.parse(entry.endDate);
    if(date.minute < 10){
      timeString = date.hour.toString() + ":0" + date.minute.toString() + " Uhr";
    }else{
      timeString = date.hour.toString() + ":" + date.minute.toString() + " Uhr";
    }
    String dateOfEndString = "";
    if(dateOfEnd.minute < 10){
      dateOfEndString = dateOfEnd.hour.toString() + ":0" + dateOfEnd.minute.toString() + " Uhr";
    }else{
      dateOfEndString = dateOfEnd.hour.toString() + ":" + dateOfEnd.minute.toString() + " Uhr";
    }

    if(date.day != dateOfEnd.day && dateOfEnd.day == DateTime.now().day){
      dateOfEndString = "Heute, " + dateOfEndString;
    }else if(date.day != dateOfEnd.day && dateOfEnd.add(const Duration(days: 1)).day == DateTime.now().day){
      dateOfEndString = "Gestern, " + dateOfEndString;
    }else if(date.day != dateOfEnd.day && dateOfEnd.add(const Duration(days: 2)).day == DateTime.now().day){
      dateOfEndString = "Vorgestern, " + dateOfEndString;
    }

    if(date.day == DateTime.now().day){
      dateString = "Heute, " + timeString;
    }else if(DateTime.now().difference(date).inDays >= 0 && DateTime.now().difference(date).inDays < 2 && DateTime.now().subtract(const Duration(days: 1)).day == date.day){
      dateString = "Gestern, " + timeString;
    }else if(DateTime.now().difference(date).inDays >= 2 && DateTime.now().difference(date).inDays < 3 && DateTime.now().subtract(const Duration(days: 2)).day == date.day){
      dateString = "Vorgestern, " + timeString;
    }else{
      dateString = date.day.toString() + "." + date.month.toString() + "." + date.year.toString() + ", " + date.hour.toString() + ":" + date.minute.toString() + " Uhr";
    }

    String durationString;
    int durationInMinutes = DateTime.parse(entry.endDate).difference(DateTime.parse(entry.startDate)).inMinutes;

    if(durationInMinutes >= 90){
      int durationInHours = Duration(minutes: durationInMinutes).inHours;
      int restMinutes = durationInMinutes-Duration(hours: Duration(minutes: durationInMinutes).inHours).inMinutes;
      if(restMinutes > 0){
        durationString = durationInHours.toString() + " Std., " + restMinutes.toString() + " Min.";
      }else{
        durationString = durationInHours.toString() + " Std.";
      }
      dateString = dateString + " - ";
    }else{
      if(durationInMinutes == 0 && entry.startDate == entry.endDate){
        durationString = "dauert an";
        dateOfEndString = "nicht beendet";
        dateString = dateString + " - ";
      }else if (durationInMinutes == 0 && entry.startDate != entry.endDate){
        int durationInSeconds = DateTime.parse(entry.endDate).difference(DateTime.parse(entry.startDate)).inSeconds;
        durationString = durationInSeconds.toString() + " Sek.";
        dateOfEndString = "";
      }else{
        durationString = "~" +durationInMinutes.toString() + " Min.";
        dateString = dateString + " - ";
      }

    }

    return Slidable(
      closeOnScroll: true,
      enabled: true,
      endActionPane: ActionPane(
        openThreshold: 0.1,
        closeThreshold: 0.1,
        motion: const BehindMotion(),
        children: [
          if(entry.startDate == entry.endDate) Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                color: Colors.white12,
                shape: BoxShape.circle

              ),
                child: IconButton(
                    splashRadius: 24,
                    padding: EdgeInsets.zero,
                    onPressed: (){
                      widget.onCommit.call();
                    }, icon: const Icon(Icons.stop_rounded))),
          ),
          Expanded(
            flex: 1,
            child: OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              closedColor: Colors.transparent,
              openColor: Colors.transparent,
              closedBuilder: (context, _) => Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      color: Colors.white12,
                      shape: BoxShape.circle

                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.edit_rounded,),
                  )),
              openBuilder: (context, _) => EditEntryPage(entry: widget.entry, index: widget.index),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    color: Colors.red.shade500.withAlpha(100),
                    shape: BoxShape.circle

                ),
                child: IconButton(
                  splashRadius: 24,
                  padding: EdgeInsets.zero,

                    onPressed: (){
                    widget.onDelete.call();
                    }, icon: const Icon(Icons.delete_outline_outlined))),
          ),
          const SizedBox(width: 16,)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 1),
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(entry.type, style: const TextStyle(fontSize: 16),),
                      Text(" (" + durationString + ")", style: TextStyle(fontWeight: FontWeight.w900, color: entry.startDate == entry.endDate ? Colors.yellow : Theme.of(context).colorScheme.primary, fontSize: 12),)
                    ],
                  ),
                  Text(entry.source, style: const TextStyle(fontSize: 12, color: Colors.white54, ),),
                  Row(children: [
                    Text(dateString, style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.bold),),
                    Text(dateOfEndString, style: TextStyle(fontSize: 12, color: entry.startDate == entry.endDate ? Colors.yellow : Colors.white54, fontWeight: FontWeight.bold))

                  ],),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}

RectTween createRectTween(Rect begin, Rect end) {
return CustomRectTween(begin: begin, end: end);
}

class CustomRectTween extends RectTween {
  CustomRectTween({Rect? begin, Rect? end})
      : super(begin: begin, end: end) {}

  @override
  Rect lerp(double t) {

    double height = end!.top - begin!.top;
    double width = end!.left - begin!.left;

    double animatedX = begin!.left + (t * width);
    double animatedY = begin!.top + (t * height);

    return Rect.fromLTWH(animatedX, animatedY, 1, 1);
  }
}