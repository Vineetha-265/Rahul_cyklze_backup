import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        "question": "How does the app work?",
        "answer":
            "You can sell your scrap by placing an order on our app. Once the order is placed, our team will come to pick it up and pay you on-site."
      },
      {
        "question": "What types of scrap can I sell?",
        "answer":
            "We accept various types of scrap including metals, paper, plastic, and electronics. If you're unsure, contact us for more details."
      },
      {
        "question": "How do I get paid for my scrap?",
        "answer":
            "The scrap will be weighed on-site, and the amount payable will be based on the actual weight and the locked price per kilogram from the day of booking. The final payment is completed on-site at the time of pickup."
      },
      {
        "question": "How do I place an order for pickup?",
        "answer":
            "Simply open the app, select Pickup type, fill in the details about the scrap you're selling, and confirm the pickup time and enter the address."
      },
      {
        "question": "Can I schedule a pickup at any date?",
        "answer":
            "You can schedule a pickup at your convenience. Our team operates during normal business hours, but we do offer flexible scheduling based on availability."
      },
      {
        "question": "What happens if I change my mind after placing an order?",
        "answer":
            "You can cancel your pickup order through the app before our team arrives. If the pickup is already in progress, please contact customer support."
      },
      {
        "question": "How do I contact customer support?",
        "answer":
            "You can contact our customer support team directly through the app or by emailing at support@cyklze.com."
      },
      {
        "question": "Are there any hidden charges?",
        "answer":
            "No, there are no hidden charges. You will receive the payment based on the current prices for the scrap you provide, and there are no extra fees for the pickup service."
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar:      AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("FAQs",
            style: TextStyle(color: Colors.white,   fontSize: 16,
                        fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return AnimatedFAQCard(
            question: faq["question"]!,
            answer: faq["answer"]!,
            icon: Icons.help_outline_rounded,
            color: Colors.green.shade400,
          );
        },
      ),
    );
  }
}

class AnimatedFAQCard extends StatefulWidget {
  final String question;
  final String answer;
  final IconData icon;
  final Color color;

  const AnimatedFAQCard({
    super.key,
    required this.question,
    required this.answer,
    required this.icon,
    required this.color,
  });

  @override
  State<AnimatedFAQCard> createState() => _AnimatedFAQCardState();
}

class _AnimatedFAQCardState extends State<AnimatedFAQCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Expandable FAQ item. Tap to ${_isExpanded ? 'collapse' : 'expand'} the answer.',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _toggle,
            splashColor: widget.color.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: _isExpanded ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.icon,
                        color:  const Color(0xFF1D4D61),
                        size: 35,
                        semanticLabel: 'Question icon',
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.question,
                          style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                        ),
                      ),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF1D4D61),
                          size: 28,
                          semanticLabel: _isExpanded
                              ? 'Collapse answer'
                              : 'Expand to see answer',
                        ),
                      ),
                    ],
                  ),

                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    axisAlignment: -1.0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Semantics(
                        label: _isExpanded ? 'Answer is visible' : 'Answer is hidden',
                        child: Text(
                          widget.answer,
                          style: const TextStyle(
                                color: Colors.black,
                                height: 1.5,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


