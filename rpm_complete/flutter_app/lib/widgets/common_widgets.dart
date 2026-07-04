// widgets/common_widgets.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Section Card (like .sec-card in the web) ──
class SectionCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget body;
  final bool initiallyExpanded;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
    this.initiallyExpanded = true,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  widget.icon,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.ink)),
                        if (widget.subtitle.isNotEmpty)
                          Text(widget.subtitle,
                              style: const TextStyle(fontSize: 12, color: AppTheme.ink3)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.ink3),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.body,
            ),
        ],
      ),
    );
  }
}

// ── Section Icon (colored circle) ──
class SectionIcon extends StatelessWidget {
  final String emoji;
  final Color color;

  const SectionIcon({super.key, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
    );
  }
}

// ── Chip Group (radio button group) ──
class ChipGroup extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  const ChipGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = value == opt;
        return GestureDetector(
          onTap: () => onChanged(selected ? null : opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppTheme.teal : AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppTheme.teal : AppTheme.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.white : AppTheme.ink2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Multi-select Chip Group ──
class MultiChipGroup extends StatelessWidget {
  final List<String> options;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const MultiChipGroup({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = values.contains(opt);
        return GestureDetector(
          onTap: () {
            final newValues = List<String>.from(values);
            if (opt == 'None') {
              onChanged(['None']);
              return;
            }
            newValues.remove('None');
            if (selected) {
              newValues.remove(opt);
            } else {
              newValues.add(opt);
            }
            onChanged(newValues);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppTheme.teal : AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppTheme.teal : AppTheme.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.white : AppTheme.ink2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Step Indicator ──
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;
  final ValueChanged<int>? onTap;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: totalSteps,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, i) {
          final active = i == currentStep;
          final done = i < currentStep;
          return GestureDetector(
            onTap: onTap != null ? () => onTap!(i) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.teal
                    : done
                        ? const Color(0xFFEBF2FF)
                        : AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? AppTheme.teal
                      : done
                          ? AppTheme.tealLight
                          : AppTheme.border,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active
                      ? AppTheme.white
                      : done
                          ? AppTheme.tealLight
                          : AppTheme.ink2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Stat Card (Dashboard) ──
class StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppTheme.ink3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Form Label ──
class FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const FieldLabel({super.key, required this.text, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.ink2),
          children: required
              ? [const TextSpan(text: ' *', style: TextStyle(color: AppTheme.rose))]
              : [],
        ),
      ),
    );
  }
}

// ── Toast notification ──
void showToast(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.rose : AppTheme.teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}

// ── Loading overlay ──
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.teal),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message!, style: const TextStyle(color: AppTheme.ink2)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
