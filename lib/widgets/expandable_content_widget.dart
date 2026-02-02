import 'package:flutter/material.dart';

class ExpandableContentWidget extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool withPadding;

  const ExpandableContentWidget({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.withPadding = true,
  });

  @override
  State<ExpandableContentWidget> createState() => _ExpandableContentWidgetState();
}

class _ExpandableContentWidgetState extends State<ExpandableContentWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.withPadding ? 20 : 0, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(
          widget.icon,
          color: const Color(0xFF8B4513),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B4513),
          ),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.content.isNotEmpty ? widget.content : 'Contenu vide',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF2C1810),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
