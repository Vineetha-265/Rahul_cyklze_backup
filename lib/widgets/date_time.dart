import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/screens/address.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PickupDateTimeSelector extends StatefulWidget {
   final List<String> names;
  const PickupDateTimeSelector({Key? key, required this.names}) : super(key: key,);

  @override
  _PickupDateTimeSelectorState createState() => _PickupDateTimeSelectorState();
}

class _PickupDateTimeSelectorState extends State<PickupDateTimeSelector> {
  String? selectedDate;
  String? selectedTimeRange;

  bool isTomorrow = false; 
Future<void> _pickDate() async {
  final now = DateTime.now();

  // Determine if the current time is after 2 PM
  final isAfter2PM = now.hour >= 14;

  // Define today and tomorrow
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  // If after 2 PM, only allow tomorrow and onward; otherwise, today and onward
  final firstDate = isAfter2PM ? tomorrow : today;

  // Set a maximum date (e.g., 7 days from tomorrow)
  final maxDate = tomorrow;

  final picked = await showDatePicker(
    context: context,
    firstDate: firstDate,
    lastDate: maxDate,
    initialDate: firstDate,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1D4D61),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF1D4D61),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    final dateOnly = DateTime(picked.year, picked.month, picked.day);
    final formatted = DateFormat('dd MMM yyyy').format(dateOnly);
final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);
    setState(() {
      selectedDate = formatted;

      if(picked.isAfter(today)){
 isTomorrow = true;
      }else{
        isTomorrow = false;
      }
    });
  }
}

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Select a Pickup Date"),
        const SizedBox(height: 5),
        Text(
          "Select an appropriate date that suits you best.",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                height: 1.3,
              ),
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Select pickup date',
          child: InkWell(
            onTap: _pickDate,
            child: Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1D4D61),
                    child: Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  title: Text(
                    selectedDate == null
                        ? "Choose a date"
                        : selectedDate!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
       if (isTomorrow) 

_buildPickupSlotSection(), 
   Semantics(
            button: true,
            label: 'Continue to enter address with selected date and time',
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
                ),
                borderRadius: BorderRadius.circular(12),
  
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: () async {
                  if (isTomorrow) {
  if (selectedTimeRange == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please select a time slot")),
                    );
                    return;
                  }
                  }
                

 if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please a pickup select date")),
                    );
                    return;
                  }



                  final date = selectedDate.toString();
                  final time = selectedTimeRange.toString();

                  // final List<String> selectedItems = [];
                  // if (plasticKg > 0) selectedItems.add("Plastic: $plasticKg Kg");
                  // if (glassKg > 0) selectedItems.add("Glass: $glassKg Kg");
                  // if (paperKg > 0) selectedItems.add("Paper: $paperKg Kg");
                  // if (metalKg > 0) selectedItems.add("Metal: $metalKg Kg");
                  // if (ewasteKg > 0) selectedItems.add("E-Waste: $ewasteKg Kg");
                  // if (cardKg > 0) selectedItems.add("Cardboard: $cardKg Kg");
                  // if (bookskg > 0) selectedItems.add("Books: $bookskg Kg");
                  // if (cwirekg > 0) selectedItems.add("Copper : $cwirekg Kg");
                  // if (wirekg > 0) selectedItems.add("Copper wire: $wirekg Kg");
                  // if (silverkg > 0) selectedItems.add("Silver: $silverkg Kg");
                  // if (brasskg > 0) selectedItems.add("Silver: $brasskg Kg");
                  //  if (fridgekg > 0) selectedItems.add("Fridge: $fridgekg Qty");
                  //  if (ackg > 0) selectedItems.add("Ac: $ackg Qty");
                  //  if (mixedkg > 0) selectedItems.add("mixed waste: $mixedkg Kg");
                   



  // int bookskg = 0;
  // int cwirekg = 0;
  // int wirekg = 0;
  // int silverkg = 0;
  // int brasskg = 0;
  // int fridgekg = 0;
  // int ackg = 0;
  // int mixedkg = 0;

 if (widget.names.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter the estimated weight of recycables.")),
                    );
                    return;
                  }
               await Provider.of<PickupProvider>(context, listen: false).setPickupDetails(
  date: date,
  time: (time.isEmpty || time.toString().contains("null")) ? "today" : time,
  type: "General",
  items: widget.names,
);


Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CreativeAddressPage(
      selectedTimeRange: (selectedTimeRange == null || selectedTimeRange.toString().isEmpty)
          ? "today"
          : selectedTimeRange.toString(),
      selectedDate: selectedDate.toString(),
      selectedType: "General",
      selectedItems: widget.names,
    ),
  ),
);





                },
                child: const Text(
                  "Continue to Address",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ),
          ),

         ],
    );
  }
  Widget _buildPickupSlotSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 28),
      _buildSectionTitle("Select a Pickup slot"),
      Text(
        "Select your preferred time slot.",
        style: TextStyle(
          color: Colors.grey[600],
          height: 1.3,
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          TimeChip(
            label: "8 AM - 11 AM",
            selectedTimeRange: selectedTimeRange,
            onSelected: (value) =>
                setState(() => selectedTimeRange = value),
          ),
          TimeChip(
            label: "11 AM - 1 PM",
            selectedTimeRange: selectedTimeRange,
            onSelected: (value) =>
                setState(() => selectedTimeRange = value),
          ),
          TimeChip(
            label: "1 PM - 3 PM",
            selectedTimeRange: selectedTimeRange,
            onSelected: (value) =>
                setState(() => selectedTimeRange = value),
          ),
          TimeChip(
            label: "3 PM - 6 PM",
            selectedTimeRange: selectedTimeRange,
            onSelected: (value) =>
                setState(() => selectedTimeRange = value),
          ),
        ],
      ),
    ],
  );
}

}

/// Simple reusable TimeChip widget
class TimeChip extends StatelessWidget {
  final String label;
  final String? selectedTimeRange;
  final ValueChanged<String> onSelected;

  const TimeChip({
    Key? key,
    required this.label,
    required this.selectedTimeRange,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedTimeRange == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(label),
      selectedColor: const Color(0xFF1D4D61),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
