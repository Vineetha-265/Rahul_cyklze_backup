import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPopupContent extends StatefulWidget {
  final List<String> list;
  final Function(String) onSelected;

  const SearchPopupContent({
    Key? key,
    required this.list,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<SearchPopupContent> createState() => _SearchPopupContentState();
}

class _SearchPopupContentState extends State<SearchPopupContent> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> filteredList;

  @override
  void initState() {
    super.initState();
    filteredList = widget.list;
  }

  @override
  void dispose() {
    _searchController.dispose(); // ✅ important
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Drag Indicator
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search locality...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    filteredList = widget.list
                        .where((e) =>
                            e.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            /// 📋 LIST OR EMPTY STATE
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            // color: Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_searching_rounded,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                               Text(
                                "Location Not Found",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "We are striving to add new locations.\nPlease check back soon.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(
                              Icons.location_on_outlined),
                          title: Text(filteredList[index] ,style: GoogleFonts.poppins(),),
                          onTap: () {
                            widget.onSelected(
                                filteredList[index]);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}