import 'package:cyklze/Provider/pickup_provider.dart';
import 'package:cyklze/screens/address.dart';
import 'package:flutter/material.dart';
import 'package:cyklze/widgets/item_card.dart';
import 'package:cyklze/widgets/time_chip.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
class MassPickupPage extends StatefulWidget {
  const MassPickupPage({super.key});

  @override
  State<MassPickupPage> createState() => _MassPickupPagePageState();
}

class _MassPickupPagePageState extends State<MassPickupPage> {
  int plasticKg = 0;
  int glassKg = 0;
  int paperKg = 0;
  int metalKg = 0;
  int ewasteKg = 0;
  int cardKg = 0;


  String? selectedDate;
  String? selectedTimeRange;

Future<void> _pickDate() async {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final maxDate = tomorrow.add(const Duration(days: 7));

  final picked = await showDatePicker(
    context: context,
    firstDate: tomorrow,
    lastDate: tomorrow.add(const Duration(days: 7)),
    initialDate: tomorrow,
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
              foregroundColor: const Color(0xFF1D4D61),
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

    setState(() {
      selectedDate = formatted;
    });
  }
}


  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                        fontWeight: FontWeight.w800, color: Colors.black)),
          if (subtitle != null) ...[
          
            Text(subtitle,
                  style: TextStyle(
    color: Colors.grey[600],      
    fontWeight: FontWeight.w400,   
    height: 1.3,                   
  )),
          ],
        ],
      ),
    );
  }


@override
Widget build(BuildContext context) {

   void confirmAction(BuildContext context) async{
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFF5F5F5),
      title: Semantics(
        label: 'confirmation',
        child: const Text(
          "Entered Maximum weight",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1D4D61),
          ),
        ),
      ),
      content: Semantics(
        label: 'Entered Maximum weight',
        child: const Text(
          "Weight is more than 400+ and thanks for your input.",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
       
        Semantics(
          label: 'ok',
          button: true,
          child: ElevatedButton(
            onPressed: () async{
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4D61),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("ok"),
          ),
        ),
      ],
    ),
  );
}

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
           colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        "Mass Pickup",
        style: TextStyle(color: Colors.white,  fontSize: 16,
                        fontWeight: FontWeight.w800,),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildSectionTitle(
            "Add Estimated Weight",
            subtitle:
                "Select the approximate weight of your recyclables to help us send the right vehicle.",
          ),
          const SizedBox(height: 12),

          ItemCard(
            label: "Plastic",
            value: plasticKg,
            icon: Icons.recycling,
            onAdd: () => {
              
               if (plasticKg > 400) {
               confirmAction(context)
 
    } else{
      setState(() => plasticKg += 10)
    }
             },
            onRemove: () => setState(() {
              if (plasticKg > 0) plasticKg -= 10;
            }),
          ),
          ItemCard(
            label: "Glass",
            value: glassKg,
            icon: Icons.local_drink,
            onAdd: () => {
              
               if (glassKg > 400) {
               confirmAction(context)
 
    }else{setState(() => glassKg += 10)}},
            onRemove: () => setState(() {
              if (glassKg > 0) glassKg -= 10;
            }),
          ),
          ItemCard(
            label: "Paper",
            value: paperKg,
            icon: Icons.menu_book,
            onAdd: () => {
              
              if (paperKg > 400) {
               confirmAction(context)
 
    } else{setState(() => paperKg += 10)}},
            onRemove: () => setState(() {
              if (paperKg > 0) paperKg -= 10;
            }),
          ),
          ItemCard(
            label: "Metal",
            value: metalKg,
            icon: Icons.build,
            onAdd: () => {
              
              
               if (metalKg > 400) {
               confirmAction(context)
 
    } else{ setState(() => metalKg += 10)}},
            onRemove: () => setState(() {
              if (metalKg > 0) metalKg -= 10;
            }),
          ),
          ItemCard(
            label: "E-Waste",
            value: ewasteKg,
            icon: Icons.computer,
            onAdd: () => {
              
              if (ewasteKg > 400) {
               confirmAction(context)
 
    }else { setState(() => ewasteKg += 10)}},
            onRemove: () => setState(() {
              if (ewasteKg > 0) ewasteKg -= 10;
            }),
          ),
          ItemCard(
            label: "Cardboard",
            value: cardKg,
            icon: Icons.inventory,
            onAdd: () => {
              
             if (cardKg > 400) {
               confirmAction(context)
 
    }  
              else{setState(() => cardKg += 10)}},
            onRemove: () => setState(() {
              if (cardKg > 0) cardKg -= 10;
            }),
          ),

          const SizedBox(height: 28),

         Semantics(
            label: 'Select pickup date',
            child: InkWell(
              onTap: () async{
               await _pickDate();
              },
              child: Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(  decoration: BoxDecoration(
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
                          : "$selectedDate",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing:const Icon(Icons.chevron_right_rounded)
                  
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          _buildSectionTitle("Select Time Slot"),
        
          Text(
            "Select your preferred time slot.",
            style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 10),

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

          const SizedBox(height: 40),

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
                   if (selectedTimeRange == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please select a time slot")),
                    );
                    return;
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

                  final List<String> selectedItems = [];
                  if (plasticKg > 0) selectedItems.add("Plastic: $plasticKg Kg");
                  if (glassKg > 0) selectedItems.add("Glass: $glassKg Kg");
                  if (paperKg > 0) selectedItems.add("Paper: $paperKg Kg");
                  if (metalKg > 0) selectedItems.add("Metal: $metalKg Kg");
                  if (ewasteKg > 0) selectedItems.add("E-Waste: $ewasteKg Kg");
                  if (cardKg > 0) selectedItems.add("Cardboard: $cardKg Kg");
 if (selectedItems.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter the estimated weight of recycables.")),
                    );
                    return;
                  }
                  await Provider.of<PickupProvider>(context, listen: false)
                      .setPickupDetails(
                    date: date,
                    time: time,
                    type: "Mass",
                    items: selectedItems,
                  );

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CreativeAddressPage(
      selectedTimeRange: selectedTimeRange.toString(),
      selectedDate: selectedDate.toString(),
      selectedType: "Mass", 
      selectedItems: selectedItems, 
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

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

}
