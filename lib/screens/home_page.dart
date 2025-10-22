import 'package:cyklze/SecureStorage/securestorage.dart';
import 'package:cyklze/screens/confirmed.dart';
import 'package:cyklze/screens/faq_page.dart';
import 'package:cyklze/screens/general_pickup.dart';
import 'package:cyklze/screens/help_page.dart';
import 'package:cyklze/screens/instant_pickup.dart';
import 'package:cyklze/screens/mass_pickup.dart';
import 'package:cyklze/screens/price_page.dart';
import 'package:cyklze/screens/profile.dart';
import 'package:cyklze/screens/settings.dart';
import 'package:cyklze/screens/supermarket.dart';
import 'package:cyklze/screens/update_number.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
void initState() {
  super.initState();
 star();
}
  @override
Widget build(BuildContext context) {
  final media = MediaQuery.of(context);
  final width = media.size.width;




  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Cyklze',
        style: TextStyle(
          color: Color(0xFF1D4D61),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
    //  iconTheme: const IconThemeData(color: Color(0xFF1D4D61)),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
 
          buildModernPickupTypes(context),
          const SizedBox(height: 24),

          _buildToolsSection(context),

          const SizedBox(height: 30),

          _buildContactSection(context),

          const SizedBox(height: 30),

const  Padding(
  padding: EdgeInsets.only(top: 100, bottom: 100), 
  child: Text(
    'Sell your scrap with ❤️',
    textAlign: TextAlign.left,
    style: TextStyle(
      fontSize: 80, 
      fontWeight: FontWeight.w800,
      color: Color(0xFF8F8F92),
      letterSpacing: 0.5,
      height: 0.9,
    ),
  ),
)


        ],
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: 0,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProfilePage()),
);

        } else if (index == 2) {
        
          Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SettingsPage()),
);

        }
      },
    ),
  );
}

Widget buildModernPickupTypes(BuildContext context) {
  final items = [
    {
      'title': 'General Pickup',
      'subtitle': 'Ideal for households with up to 100kg of recyclable materials. Schedule a pickup at your convenience.',
      'icon': Icons.recycling,
      'color': const Color(0xFFE8F7ED),
      'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneralPickupPage())),
    },
    {
      'title': 'Instant Pickup',
      'subtitle': 'Our Instant Pickup Service offers a quick and efficient recycling process—schedule a pickup, and we\'ll call to confirm details and arrange a convenient collection.',
      'icon': Icons.flash_on,
      'color': const Color(0xFFFFF3E0),
      'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstantPickupPage())),
    },
    {
      'title': 'Supermarket Pickup',
      'subtitle': 'Our Supermarket Pickup Service is ideal for supermarkets',
      'icon': Icons.shopping_cart,
      'color': const Color(0xFFEFF7FF),
      'onTap': () {
     

         Navigator.push(context, MaterialPageRoute(builder: (_) => const SupermarketPickupPage()));

      },
    },
    {
      'title': 'Mass Pickup',
      'subtitle': 'Our Mass Pickup Service is ideal for factories, construction sites, and large-scale with around 300kg of recyclables',
      'icon': Icons.factory,
      'color': const Color(0xFFFFF1F0),
      'onTap': () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MassPickupPage()));

      },
    },
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final crossAxisCount = width >= 1000 ? 3 : width >= 600 ? 2 : 1;
      final itemWidth = width / crossAxisCount - 12; 

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Choose a Pickup Type Section',
            child: const Text(
              'Choose a Pickup Type',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            label: 'Description of available pickup types',
            child: Text(
              "Let's set up your pickup.\nSelect one of the following pickup types:",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
            ),
          ),
          const SizedBox(height: 6),
        
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((it) {
              return Semantics(
                label: '${it['title']} Pickup Type Card',
                child: SizedBox(
                  width: itemWidth.clamp(0, 400), 
                  child: ModernPickupCard(
                    title: it['title'] as String,
                    subtitle: it['subtitle'] as String,
                    icon: it['icon'] as IconData,
                    accentColor: it['color'] as Color,
                    onTap: it['onTap'] as void Function(),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    },
  );
}

void _showWelcomeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4D61),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Scrap, Easily with Cyklze!\n\n'
                'Got paper, plastic, metal, e-waste, or cardboard?\n'
                'Cyklze makes scrap selling simple and convenient.\n\n'
                '📦 Book a Pickup: Choose items, date & time.\n'
                '📍 We Collect: Scrap is weighed at your location.\n'
                '💵 Get Paid: Quick and transparent payments.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4D61),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildToolsSection(BuildContext context) {
  const accent = Color(0xFF2E7D32);
  
  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_outlined, size: 22, color: Colors.black87),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  label: 'Tools Section Title',
                  child: const Text(
                    'Tools',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)
                  ),
                ),
              ),
            ],
          ),
  
          
          InkWell(
            onTap: () {
              Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const PricePage()));
             },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
                color: Colors.white
              ),
               padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.price_check, color: accent),
                title:  Semantics(
                  label: 'Current Prices',
                  child: const Text('Current Prices', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                subtitle: Semantics(
                  label: 'View latest scrap prices',
                  child: Text(
                    'View latest scrap prices',
                    style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded)
              ),
            ),
          ),
       
        InkWell(
          onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQPage()));
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black), 
              borderRadius: BorderRadius.circular(12),
              color: Colors.white, 
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.question_mark, color: Colors.deepOrange),
              title: Semantics(
                label: 'FAQs',
                child: const Text(
          'FAQs',
          style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              subtitle: Semantics(
                label: 'Quick answers to common questions',
                child: Text(
          'Quick answers to common questions',
          style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded)
            ),
          ),
        ),

         ],
      ),
    ),
  );
}

Widget _buildContactSection(BuildContext context) {
  return Semantics(
    button: true,
    label: 'Contact support button',
    child: InkWell(
      onTap: () {

 Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpPage()),
    );

      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
          colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
          ),
          borderRadius: BorderRadius.circular(14),
      
        ),
        child: Row(
          children: [
            const Icon(Icons.support_agent, size: 36, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Semantics(
                label: 'Need help? Chat with support team',
                child: const Text(
                  'Need help? Chat with our support team — fast responses.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    ),
  );
}

 void star() async {

  final token = await SecureStorage.getAccessToken();
  if (token == null) {
    _showWelcomeDialog(context);
  }
}
}

class ModernPickupCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const ModernPickupCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1D4D61),
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: accentColor,
                      child: Icon(
                        icon,
                        color: const Color(0xFF1D4D61),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            label: title,
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white, 
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Semantics(
                            label: subtitle,
                            child: Text(
                              subtitle,
                              style: const TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.w400,
                                    height: 1.3,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white, 
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class PickupSection extends StatelessWidget {
  final String title, description, buttonText;
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;

  const PickupSection({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  @override
Widget build(BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Icon(icon, color: Colors.black87, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  label: title,  
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Semantics(
            label: description,
            child: Text(
              description,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              button: true,
              label: 'Action Button: $buttonText',
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


}
