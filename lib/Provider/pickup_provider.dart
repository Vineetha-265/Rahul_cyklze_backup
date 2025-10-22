import 'dart:io';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';

import 'package:cyklze/enums/page_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


const String _tokenUrl =
    "https://20pnz6cr8e.execute-api.ap-south-1.amazonaws.com/cyklzee/cyklzee/handletoken";
class PickupProvider with ChangeNotifier {
  String? _selectedDate;
  String? _selectedTimeRange;
  String? _selectedType;
  List<String> _selectedItems = [];

  // Getters
  String? get selectedDate => _selectedDate;
  String? get selectedTimeRange => _selectedTimeRange;
  String? get selectedType => _selectedType;
  List<String> get selectedItems => List.unmodifiable(_selectedItems);

  set selectedDate(String? date) {
    _selectedDate = date;
    notifyListeners();
  }

  set selectedTimeRange(String? timeRange) {
    _selectedTimeRange = timeRange;
    notifyListeners();
  }

  set selectedType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  set selectedItems(List<String> items) {
    _selectedItems = List.from(items); // Defensive copy
    notifyListeners();
  }

  // Combined method for setting all pickup details at once
Future<void> setPickupDetails({
  required String date,
  required String time,
  required String type,
  required List<String> items,
}) async {
  _selectedDate = date;
  _selectedTimeRange = time;
  _selectedType = type;
  _selectedItems = List.from(items);

  // Example: pretend you're saving to local storage
  // await SomeStorage.savePickupDetails(...);

  notifyListeners();
}

    Pagestate _state = Pagestate.loading;
  Pagestate get state => _state;

  void _setState(Pagestate newState) {
    _state = newState;
    notifyListeners(); 
  }

Future<bool> hasInternetConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();

  // No network at all
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }

  // Network is ON, test actual internet
  try {
    final result = await InternetAddress.lookup('example.com')
        .timeout(const Duration(seconds: 3));

    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true; // ✅ real internet
    }
    return false;
  } on SocketException catch (_) {
    return false;
  } on Exception catch (_) {
    return false;
  }
}


Future<Pagestate> refreshAccessToken(Function Done,String nam) async {
  String refreshToken = (await SecureStorage.getRefreshToken()).toString();

  try {
    final resp = await http.put(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);

      await SecureStorage.saveAccessToken(body['accessToken']);
      await SecureStorage.saveRefreshToken(body['refreshToken']);
      if(nam == "exe")
      {
Done();
      }

       // trigger the callback
      return Pagestate.loggedIn; // ✅ return state
    } else {
      return Pagestate.notLogged;
    }
  } catch (e) {
    return Pagestate.error;
  }
}
  // Getter methods for each property
  String? get getSelectedDate => selectedDate;
  String? get getSelectedTimeRange => selectedTimeRange;
  String? get getSelectedType => selectedType;
  List<String> get getSelectedItems => selectedItems;
}
