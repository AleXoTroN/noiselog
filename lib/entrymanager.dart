import 'package:noiselog/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<List<Entry>> getEntries() async{
  final prefs = await SharedPreferences.getInstance();
  final List<String>? entryList = prefs.getStringList("entryList");
  if(entryList == null){
    saveEntries([]);
    return [];
  }

  List<Entry> entries = List<Entry>.empty(growable: true);
  for (var element in entryList) {
    Map<String, dynamic> dataMap = jsonDecode(element);
    Entry entryToAdd = Entry.fromJson(dataMap);
    entries.add(entryToAdd);
  }

  return entries;
}

Future<bool> saveEntries(List<Entry> listToSave) async{
  final prefs = await SharedPreferences.getInstance();
  List<Entry> list = listToSave;
  List<String> finalListToSave = List<String>.empty(growable: true);

  for (var element in list) {
    finalListToSave.add(jsonEncode(element));
  }

  prefs.setStringList("entryList", finalListToSave);
  return true;
}

Future<bool> updateEntry(List<Entry> list, int index, Entry newEntry)async{
  list[index] = newEntry;
  saveEntries(list);
  return true;
}

Future<bool> deleteEntry(List<Entry> listToEdit, int indexOfEntryToRemove) async{
  List<Entry> newList = listToEdit;
  newList.removeAt(indexOfEntryToRemove);
  saveEntries(newList);
  return true;
}

Future<bool> commitEndDate(List<Entry> listToEdit, int indexOfEntryToEdit) async{
  List<Entry> tempList = listToEdit;
  tempList.elementAt(indexOfEntryToEdit).endDate = DateTime.now().toString();
  saveEntries(tempList);
  return true;
}