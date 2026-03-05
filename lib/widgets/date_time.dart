import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/Views/error.dart';
import 'package:cyklze/Views/loading.dart';
import 'package:cyklze/Views/loginrequird.dart';
import 'package:cyklze/Views/offline.dart';
import 'package:cyklze/enums/page_state.dart';
import 'package:cyklze/screens/address.dart';
import 'package:cyklze/screens/verification.dart';
import 'package:cyklze/widgets/tiltanimation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostalCodeRange {
  final int min;
  final int max;

  PostalCodeRange({
    required this.min,
    required this.max,
  });

  factory PostalCodeRange.fromJson(Map<String, dynamic> json) {
    return PostalCodeRange(
      min: json['min'],
      max: json['max'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }

  bool contains(int postalCode) {
    return postalCode >= min && postalCode <= max;
  }
}


class AvailableDatesResponse {
  final String message;
  final List<String> dates;
  final List<String> areas;
  final List<String> cities;
    final List<String> slots;
    final List<PostalCodeRange> postalCodeRanges;
     final String regx;

  AvailableDatesResponse({
    required this.message,
    required this.dates,
     required this.areas,
      required this.cities,
      required this.slots,
       required this.postalCodeRanges,
          required this.regx,
  });

  // Factory constructor to parse JSON
  factory AvailableDatesResponse.fromJson(Map<String, dynamic> json) {
    return AvailableDatesResponse(
      message: json['message'] as String,
         regx: json['regx'] as String,
      dates: List<String>.from(json['dates'] as List<dynamic>),
        areas: List<String>.from(json['areas'] as List<dynamic>),
          cities: List<String>.from(json['cities'] as List<dynamic>),
              slots: List<String>.from(json['slots'] as List<dynamic>),
     postalCodeRanges: (json['postalCodeRanges'] as List<dynamic>)
          .map((e) => PostalCodeRange.fromJson(e))
          .toList(),
    );
  }

  // Convert back to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'dates': dates,
      'areas': areas,
      'cities': cities,
      'slots': slots,
      'regx': regx,
       'postalCodeRanges':
          postalCodeRanges.map((e) => e.toJson()).toList(),
    };
  }
}

class PickupDateTimeSelector extends StatefulWidget {
  final List<String> names;

  const PickupDateTimeSelector({
    Key? key,
    required this.names,
  }) : super(key: key);

  @override
  State<PickupDateTimeSelector> createState() =>
      _PickupDateTimeSelectorState();
}

class _PickupDateTimeSelectorState
    extends State<PickupDateTimeSelector> {
  String selectedDate = "Today";
  String? selectedTimeRange;
  int? selectedIndex;

  String apiMessage = '';
  Pagestate _state = Pagestate.loading;

  List<String> availableDates = [];
  List<String> slots = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final provider =
        Provider.of<PickupProvider>(context, listen: false);

    if (!await provider.hasInternetConnection()) {
      setState(() => _state = Pagestate.offline);
      return;
    }

    setState(() => _state = Pagestate.loading);

    const apiUrl =
        'https://api.cyklze.com/cyklzee/dateandaddress';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        final data = AvailableDatesResponse.fromJson(jsonMap);

        setState(() {
          apiMessage = data.message;
          availableDates = data.dates;
          slots = data.slots;
          _state = Pagestate.loggedIn;
        });

        await SecureStorage.saveAreas(data.areas);
        await SecureStorage.saveCities(data.cities);
        await SecureStorage.savePostalRange(
            data.postalCodeRanges);
        await SecureStorage.saveRegx(data.regx);
      } else {
        setState(() => _state = Pagestate.error);
      }
    } catch (_) {
      setState(() => _state = Pagestate.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case Pagestate.loading:
        return const ElegantLoadingOverlay();

      case Pagestate.offline:
        return OfflineRetry(onRetry: getData);

      case Pagestate.error:
        return ErrorRetry(
          message: "Something went wrong",
          onRetry: getData,
        );

      case Pagestate.notLogged:
        return LoginRequired(
          message: "Please log in to confirm pickup",
          onLogin: () {},
        );

      case Pagestate.loggedIn:
      default:
        return _buildMainUI();
    }
  }

  Widget _buildMainUI() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Pickup Date",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose a date that suits you.",
              style: TextStyle(
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            /// DATE CHIPS
            if (availableDates.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  availableDates.length,
                  (index) {
                    final date =
                        availableDates[index];
                    final isSelected =
                        selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                          selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(
                                  0xFF1D4D61)
                              : Colors.grey[200],
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 28),

            /// HIGH TRAFFIC UI
            if (apiMessage.contains("surge"))
              Center(
                child: Column(
                  children: const [
                    Icon(Icons.trending_up,
                        size: 80,
                        color:
                            Colors.deepPurple),
                    SizedBox(height: 16),
                    Text(
                      "High Traffic Right Now",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "We're experiencing heavy demand.\nPlease try again shortly.",
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),

            /// TIME SLOTS
            if (slots.isNotEmpty &&
                selectedDate != "Today")
              _buildSlotSection(),

            const SizedBox(height: 40),

            /// CONTINUE BUTTON
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Select a Pickup Slot",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((slot) {
            final isSelected =
                selectedTimeRange == slot;

            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              selectedColor:
                  const Color(0xFF1D4D61),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.black,
              ),
              onSelected: (_) {
                setState(() {
                  selectedTimeRange = slot;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF1D4D61),
          minimumSize:
              const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          if (selectedDate.isEmpty) {
            _showSnack(
                "Please select a pickup date");
            return;
          }

          if (selectedDate != "Today" &&
              selectedTimeRange == null) {
            _showSnack(
                "Please select a time slot");
            return;
          }

          if (widget.names.isEmpty) {
            _showSnack(
                "Please enter the estimated weight of recyclables.");
            return;
          }

          await Provider.of<PickupProvider>(
                  context,
                  listen: false)
              .setPickupDetails(
            date: selectedDate,
            time:
                selectedTimeRange ?? "today",
            type: "General",
            items: widget.names,
          );

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) =>
          //         CreativeAddressPage(
          //       selectedTimeRange:
          //           selectedTimeRange ??
          //               "today",
          //       selectedDate:
          //           selectedDate,
          //       selectedType:
          //           "General",
          //       selectedItems:
          //           widget.names,
          //     ),
          //   ),
          // );
        },
        child: const Text(
          "Continue to Address",
          style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
